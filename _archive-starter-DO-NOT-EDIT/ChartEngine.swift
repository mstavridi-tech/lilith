import Foundation
// import SwiftAA  // ← add the SwiftAA package in Xcode: File > Add Package Dependencies
//                 //   https://github.com/onekiloparsec/SwiftAA (MIT license)

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
        let sunLon = try longitude(of: .sun, at: date)
        let moonLon = try longitude(of: .moon, at: date)
        var elongation = moonLon - sunLon
        if elongation < 0 { elongation += 360 }
        // 0° = new, 180° = full; 8 phases of 45° centered on the cardinal points
        let index = Int(((elongation + 22.5) / 45.0)) % 8
        return MoonPhase.allCases[index]
    }

    // MARK: - Planetary positions (SwiftAA boundary — verify against package docs)

    /// Geocentric apparent ecliptic longitude of a body, 0–360°.
    private static func longitude(of body: CelestialBody, at date: Date) throws -> Double {
        // TODO(Claude Code): implement with SwiftAA once the package is added. Pattern:
        //   let jd = JulianDay(date)
        //   Sun(julianDay: jd).eclipticCoordinates.celestialLongitude.value  // etc. per body
        // Moon: use Moon(julianDay: jd).eclipticCoordinates
        // North Node: Moon ascending node from SwiftAA's lunar functions (mean node)
        // Black Moon Lilith: mean lunar apogee — formula from Meeus, Astronomical
        //   Algorithms ch. 50, or derive from SwiftAA's lunar orbital elements.
        throw EngineError.notImplemented(
            "Add SwiftAA package, then implement longitude(of:at:) — see TODO above")
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
    private static func ascendant(at date: Date, latitude: Double, longitude geoLon: Double) throws -> Double {
        // TODO(Claude Code): with SwiftAA — apparent sidereal time at Greenwich, then:
        //   LST = GST + geographic longitude
        //   ASC = atan2(cos(LST), -(sin(LST) * cos(ε) + tan(φ) * sin(ε)))  [ε = obliquity, φ = latitude]
        // Normalize to 0–360. Verify against astro.com — off-by-quadrant errors are common.
        throw EngineError.notImplemented("Implement ascendant() after SwiftAA is added")
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
