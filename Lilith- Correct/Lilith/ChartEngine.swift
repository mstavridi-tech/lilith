import Foundation
import SwiftAA
import AABridge  // ← Pluto only. SwiftAA exposes no geocentric API for Pluto, so we call the
//                 underlying C bridge directly. AABridge ships INSIDE the SwiftAA package, so
//                 there's no new dependency — but it must be linked to the Lilith target:
//                 Target > General > Frameworks, Libraries… > + > AABridge (from the SwiftAA package).
//                 If the build says "no such module 'AABridge'", that checkbox is the fix.

/// All astrology math lives here. Deterministic, on-device, works offline.
///
/// IMPORTANT FOR CLAUDE CODE: the planetary-position calls below are written against
/// SwiftAA's API surface. After adding the package, verify each call against the
/// package's current docs and fix signatures as needed. The astrology logic
/// (signs, houses, aspects, phases) is pure math and is already correct.
///
/// VERIFICATION (do before trusting any output): compute charts for 5 known birthdays
/// and compare every placement against astro.com's free chart. Include one southern
/// hemisphere city and one birth near midnight at a timezone boundary.
struct ChartEngine {

    // MARK: - Public API

    /// Compute a full natal chart from birth data.
    static func natalChart(for birth: BirthData) throws -> NatalChart {
        guard let moment = birth.utcMoment else { throw EngineError.invalidBirthData }

        let placements = try allPlacements(at: moment)
        let asc: Double? = birth.hasKnownTime
            ? try ascendant(at: moment, latitude: birth.latitude, longitude: birth.longitude)
            : nil
        let cusps = asc.map { wholeSignCusps(ascendant: $0) }

        // Assign houses to placements when we have them
        var housed = placements
        if let cusps {
            for i in housed.indices {
                housed[i].house = house(of: housed[i].longitude, cusps: cusps)
            }
        }

        return NatalChart(
            birthData: birth,
            placements: housed,
            ascendant: asc,
            houseCusps: cusps,
            aspects: aspects(in: housed)
        )
    }

    /// Today's sky — same placements structure, used for transits and the daily horoscope.
    static func currentSky() throws -> [Placement] {
        try allPlacements(at: Date())
    }

    /// Moon phase right now (or any date). Pure math, no library needed.
    static func moonPhase(at date: Date = Date()) throws -> MoonPhase {
        // 0° = new, 180° = full; 8 phases of 45° centered on the cardinal points
        let index = Int(((try moonElongation(at: date) + 22.5) / 45.0)) % 8
        return MoonPhase.allCases[index]
    }

    /// Sun-moon elongation in degrees, 0–360 (0 = new, 180 = full, <180 waxing).
    /// Drives both the phase label and the Today card's real terminator shadow.
    static func moonElongation(at date: Date = Date()) throws -> Double {
        let sunLon = try longitude(of: .sun, at: date)
        let moonLon = try longitude(of: .moon, at: date)
        let elongation = moonLon - sunLon
        return elongation < 0 ? elongation + 360 : elongation
    }

    // MARK: - Planetary positions (SwiftAA boundary — verify against package docs)

    /// Geocentric apparent ecliptic longitude of a body, 0–360°.
    private static func longitude(of body: CelestialBody, at date: Date) throws -> Double {
        let jd = JulianDay(date) // interpreted as UT; `date` is already the exact UTC moment of birth
        let degrees: Double
        switch body {
        case .sun:
            // Apparent longitude (light-time + aberration + nutation) — matches astro.com.
            degrees = Sun(julianDay: jd).apparentEclipticCoordinates.celestialLongitude.value
        case .moon:
            degrees = Moon(julianDay: jd).eclipticCoordinates.celestialLongitude.value
        case .mercury:
            degrees = geocentricEclipticLongitude(of: Mercury(julianDay: jd))
        case .venus:
            degrees = geocentricEclipticLongitude(of: Venus(julianDay: jd))
        case .mars:
            degrees = geocentricEclipticLongitude(of: Mars(julianDay: jd))
        case .jupiter:
            degrees = geocentricEclipticLongitude(of: Jupiter(julianDay: jd))
        case .saturn:
            degrees = geocentricEclipticLongitude(of: Saturn(julianDay: jd))
        case .uranus:
            degrees = geocentricEclipticLongitude(of: Uranus(julianDay: jd))
        case .neptune:
            degrees = geocentricEclipticLongitude(of: Neptune(julianDay: jd))
        case .pluto:
            // Pluto isn't a SwiftAA `CelestialBody`; computed geocentrically by hand. See below.
            degrees = plutoGeocentricLongitude(at: jd)
        case .northNode:
            // Osculating ("true") node, to match astro.com's default (Swiss Ephemeris true node).
            // The node always moves backwards through the zodiac, so isRetrograde() flags it ℞.
            degrees = trueNodeLongitude(at: jd)
        case .blackMoonLilith:
            // Mean Black Moon Lilith = the mean lunar apogee, projected onto the ecliptic.
            degrees = meanApogeeLongitude(at: jd)
        }
        return normalizeDegrees(degrees)
    }

    /// Geocentric apparent ecliptic longitude for the major planets (Mercury–Neptune).
    /// SwiftAA gives each planet's apparent geocentric *equatorial* coordinates; we rotate
    /// those onto the ecliptic. (Pluto is handled separately — it's a `DwarfPlanet` with no
    /// equatorial accessor.)
    private static func geocentricEclipticLongitude(of body: SwiftAA.CelestialBody) -> Double {
        body.equatorialCoordinates.makeEclipticCoordinates().celestialLongitude.value
    }

    /// Pluto's geocentric apparent ecliptic longitude.
    ///
    /// SwiftAA models Pluto as a `DwarfPlanet` and exposes only its *heliocentric* position
    /// (Meeus, Astronomical Algorithms ch. 37, referred to the standard equinox J2000.0) via
    /// the AABridge C functions. To get the geocentric longitude astrology needs, we:
    ///   1. precess Pluto's J2000 position to the mean equinox of date, so it shares Earth's frame,
    ///   2. subtract Earth's heliocentric position in rectangular ecliptic coordinates (Meeus ch. 33).
    /// Result is good to well under the arc-minute scale that matters for a horoscope. Verify against
    /// astro.com like every other body (Pluto moves ~1.4°/yr, so its sign rarely sits near a cusp).
    private static func plutoGeocentricLongitude(at jd: JulianDay) -> Double {
        let d2r = Double.pi / 180

        let plutoJ2000 = EclipticCoordinates(
            lambda: Degree(KPCAAPluto_EclipticLongitude(jd.value)),
            beta: Degree(KPCAAPluto_EclipticLatitude(jd.value)),
            epoch: .J2000)
        let pluto = plutoJ2000.precessedCoordinates(to: .epochOfTheDate(jd))
        let rP = KPCAAPluto_RadiusVector(jd.value)            // AU
        let lP = pluto.celestialLongitude.value * d2r
        let bP = pluto.celestialLatitude.value * d2r

        let earth = Earth(julianDay: jd)
        let earthCoord = earth.heliocentricEclipticCoordinates  // mean equinox of date
        let rE = earth.radiusVector.value                       // AU
        let lE = earthCoord.celestialLongitude.value * d2r
        let bE = earthCoord.celestialLatitude.value * d2r

        // Geocentric vector = heliocentric(Pluto) − heliocentric(Earth).
        let x = rP * cos(bP) * cos(lP) - rE * cos(bE) * cos(lE)
        let y = rP * cos(bP) * sin(lP) - rE * cos(bE) * sin(lE)
        return normalizeDegrees(atan2(y, x) / d2r)
    }

    /// Mean lunar apogee (mean Black Moon Lilith), projected onto the ecliptic — the value
    /// astro.com / Swiss Ephemeris report.
    ///
    /// SwiftAA (via Meeus) gives the apogee's longitude measured *along the lunar orbit*
    /// (`mean perigee + 180°`). Swiss Ephemeris instead reports it *projected onto the ecliptic*
    /// through the orbit's mean inclination, which is the bulk of the ~6' difference we saw — the
    /// shift depends on the apogee's distance from the node, so the error isn't constant. We do that
    /// projection here with plain spherical trig on SwiftAA's mean elements (no Swiss Ephemeris code,
    /// so LILITH stays license-clean). SE's small proprietary periodic corrections are not applied,
    /// so expect a residual on the order of an arc-minute.
    private static func meanApogeeLongitude(at jd: JulianDay) -> Double {
        let moon = Moon(julianDay: jd)
        let apogee = moon.longitudeOfMeanPerigee.value + 180  // empty focus of the mean orbit
        let node = moon.longitudeOfMeanAscendingNode.value
        let inclination = 5.145396 * .pi / 180                // mean inclination of the lunar orbit
        let u = (apogee - node) * .pi / 180                   // argument of latitude of the apogee
        let projected = atan2(cos(inclination) * sin(u), cos(u)) * 180 / .pi
        return normalizeDegrees(node + projected)
    }

    /// Osculating ("true") longitude of the Moon's ascending node — the value astro.com /
    /// Swiss Ephemeris report as the True Node.
    ///
    /// Meeus's short 5-term formula (what SwiftAA exposes) only approximates this and drifts a
    /// few arc-minutes. The node is just the orientation of the Moon's instantaneous orbit plane,
    /// so we take it straight from the orbital angular momentum r × v (velocity by central
    /// difference). Pure geometry on SwiftAA's lunar positions — no external tables.
    private static func trueNodeLongitude(at jd: JulianDay) -> Double {
        let dt = 0.2 // days; small enough to track the node's wobble, large enough to avoid noise
        let before = moonEclipticPosition(at: JulianDay(jd.value - dt))
        let here = moonEclipticPosition(at: jd)
        let after = moonEclipticPosition(at: JulianDay(jd.value + dt))
        // Velocity (per day) by central difference; only its direction matters here.
        let v = (x: (after.x - before.x) / (2 * dt),
                 y: (after.y - before.y) / (2 * dt),
                 z: (after.z - before.z) / (2 * dt))
        // Orbital angular momentum h = r × v; the ascending-node direction is ẑ × h = (−h.y, h.x, 0).
        let h = (x: here.y * v.z - here.z * v.y,
                 y: here.z * v.x - here.x * v.z,
                 z: here.x * v.y - here.y * v.x)
        return normalizeDegrees(atan2(h.x, -h.y) * 180 / .pi)
    }

    /// The Moon's geocentric position as a rectangular ecliptic vector (km), apparent / equinox of date.
    private static func moonEclipticPosition(at jd: JulianDay) -> (x: Double, y: Double, z: Double) {
        let moon = Moon(julianDay: jd)
        let coord = moon.apparentEclipticCoordinates
        let lambda = coord.celestialLongitude.value * .pi / 180
        let beta = coord.celestialLatitude.value * .pi / 180
        let r = moon.distance.value // km
        return (r * cos(beta) * cos(lambda), r * cos(beta) * sin(lambda), r * sin(beta))
    }

    /// Wrap any angle into 0–360°.
    private static func normalizeDegrees(_ degrees: Double) -> Double {
        let r = degrees.truncatingRemainder(dividingBy: 360)
        return r < 0 ? r + 360 : r
    }

    /// Retrograde check: is the body's longitude decreasing? Sample ±12h around the date.
    private static func isRetrograde(_ body: CelestialBody, at date: Date) throws -> Bool {
        guard body != .sun, body != .moon else { return false } // never retrograde
        let before = try longitude(of: body, at: date.addingTimeInterval(-43_200))
        let after = try longitude(of: body, at: date.addingTimeInterval(43_200))
        var delta = after - before
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }
        return delta < 0
    }

    private static func allPlacements(at date: Date) throws -> [Placement] {
        try CelestialBody.allCases.map { body in
            Placement(
                body: body,
                longitude: try longitude(of: body, at: date),
                isRetrograde: try isRetrograde(body, at: date),
                house: nil
            )
        }
    }

    /// Ascendant from local sidereal time and latitude — standard formula.
    /// `geoLon` is east-positive (the convention CLGeocoder returns), so LST = GST + longitude.
    private static func ascendant(at date: Date, latitude: Double, longitude geoLon: Double) throws -> Double {
        let jd = JulianDay(date)
        let d2r = Double.pi / 180

        // Local apparent sidereal time as an angle (the RAMC), in radians.
        let gstDegrees = jd.apparentGreenwichSiderealTime().value * 15 // sidereal hours → degrees
        let lst = normalizeDegrees(gstDegrees + geoLon) * d2r
        let eps = jd.obliquityOfEcliptic(mean: false).value * d2r      // true obliquity of date
        let lat = latitude * d2r

        // ASC = atan2(cos(LST), -(sin(LST)·cos ε + tan φ·sin ε)). atan2 keeps the correct quadrant
        // (a plain atan here is the classic off-by-180° bug). Verify against astro.com per the rule.
        let asc = atan2(cos(lst), -(sin(lst) * cos(eps) + tan(lat) * sin(eps)))
        return normalizeDegrees(asc / d2r)
    }

    // MARK: - Pure astrology math (already correct, no library needed)

    /// Whole-sign houses: house 1 is the whole rising sign, house 2 the next sign, etc.
    static func wholeSignCusps(ascendant: Double) -> [Double] {
        let firstCusp = Double(Int(ascendant / 30)) * 30 // start of rising sign
        return (0..<12).map { (firstCusp + Double($0 * 30)).truncatingRemainder(dividingBy: 360) }
    }

    static func house(of longitude: Double, cusps: [Double]) -> Int {
        let signIndex = Int(longitude / 30)
        let firstHouseSign = Int(cusps[0] / 30)
        return ((signIndex - firstHouseSign + 12) % 12) + 1
    }

    /// Find all major aspects between placements.
    static func aspects(in placements: [Placement]) -> [Aspect] {
        var result: [Aspect] = []
        for i in placements.indices {
            for j in placements.indices where j > i {
                var separation = abs(placements[i].longitude - placements[j].longitude)
                if separation > 180 { separation = 360 - separation }
                for type in AspectType.allCases {
                    let orb = abs(separation - type.angle)
                    if orb <= type.orb {
                        result.append(Aspect(
                            a: placements[i].body, b: placements[j].body,
                            type: type, orb: orb))
                    }
                }
            }
        }
        return result.sorted { $0.orb < $1.orb } // tightest aspects first, they matter most
    }

    enum EngineError: Error {
        case invalidBirthData
        case notImplemented(String)
    }
}
