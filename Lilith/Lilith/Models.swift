import Foundation

// MARK: - Zodiac

enum ZodiacSign: Int, CaseIterable, Codable {
    case aries, taurus, gemini, cancer, leo, virgo
    case libra, scorpio, sagittarius, capricorn, aquarius, pisces

    var name: String {
        ["Aries", "Taurus", "Gemini", "Cancer", "Leo", "Virgo",
         "Libra", "Scorpio", "Sagittarius", "Capricorn", "Aquarius", "Pisces"][rawValue]
    }

    var glyph: String {
        ["♈︎", "♉︎", "♊︎", "♋︎", "♌︎", "♍︎", "♎︎", "♏︎", "♐︎", "♑︎", "♒︎", "♓︎"][rawValue]
    }

    /// Which sign holds a given ecliptic longitude (0–360°). Each sign spans 30°.
    static func at(longitude: Double) -> ZodiacSign {
        let normalized = longitude.truncatingRemainder(dividingBy: 360)
        let positive = normalized < 0 ? normalized + 360 : normalized
        return ZodiacSign(rawValue: Int(positive / 30))!
    }
}

// MARK: - Bodies

enum CelestialBody: String, CaseIterable, Codable {
    case sun, moon, mercury, venus, mars, jupiter, saturn
    case uranus, neptune, pluto
    case northNode = "north node"
    case blackMoonLilith = "lilith" // our namesake — gets special treatment in UI

    var displayName: String { rawValue.capitalized }

    var glyph: String {
        switch self {
        case .sun: "☉"; case .moon: "☽"; case .mercury: "☿"; case .venus: "♀"
        case .mars: "♂"; case .jupiter: "♃"; case .saturn: "♄"; case .uranus: "♅"
        case .neptune: "♆"; case .pluto: "♇"; case .northNode: "☊"; case .blackMoonLilith: "⚸"
        }
    }
}

// MARK: - Chart pieces

/// One body's position in a chart: "Venus at 14°32' Scorpio in the 8th house, retrograde"
struct Placement: Codable, Identifiable {
    var id: String { body.rawValue }
    let body: CelestialBody
    let longitude: Double        // ecliptic longitude 0–360°
    let isRetrograde: Bool
    var house: Int?              // 1–12, nil if birth time unknown

    var sign: ZodiacSign { .at(longitude: longitude) }
    var degreeInSign: Double { longitude.truncatingRemainder(dividingBy: 30) }

    var formatted: String {
        let deg = Int(degreeInSign)
        let min = Int((degreeInSign - Double(deg)) * 60)
        let retro = isRetrograde ? " ℞" : ""
        return "\(body.glyph) \(deg)°\(String(format: "%02d", min))' \(sign.name)\(retro)"
    }
}

enum AspectType: String, Codable, CaseIterable {
    case conjunction, sextile, square, trine, opposition

    var angle: Double {
        switch self {
        case .conjunction: 0; case .sextile: 60; case .square: 90
        case .trine: 120; case .opposition: 180
        }
    }
    /// How many degrees off-exact still counts. Standard orbs, tighten later if needed.
    var orb: Double {
        switch self {
        case .conjunction, .opposition: 8
        case .square, .trine: 7
        case .sextile: 5
        }
    }
}

struct Aspect: Codable, Identifiable {
    var id: String { "\(a.rawValue)-\(type.rawValue)-\(b.rawValue)" }
    let a: CelestialBody
    let b: CelestialBody
    let type: AspectType
    let orb: Double // how exact (0 = perfect)
}

// MARK: - Birth data and chart

struct BirthData: Codable {
    var date: DateComponents      // year, month, day in local civil time
    var time: DateComponents?     // hour, minute — optional but onboarding pushes hard for it
    var placeName: String
    var latitude: Double
    var longitude: Double
    var timeZoneID: String        // IANA, e.g. "Europe/Athens" — resolve to UTC at calc time

    /// The exact UTC moment of birth. Noon is used when time is unknown (standard practice;
    /// chart still valid except houses/rising, which the UI then hides).
    var utcMoment: Date? {
        var components = date
        components.hour = time?.hour ?? 12
        components.minute = time?.minute ?? 0
        components.timeZone = TimeZone(identifier: timeZoneID)
        return Calendar(identifier: .gregorian).date(from: components)
    }

    var hasKnownTime: Bool { time != nil }
}

struct NatalChart: Codable {
    let birthData: BirthData
    let placements: [Placement]
    let ascendant: Double?        // nil when birth time unknown
    let houseCusps: [Double]?     // 12 cusps, whole-sign by default
    let aspects: [Aspect]

    var sun: Placement? { placements.first { $0.body == .sun } }
    var moon: Placement? { placements.first { $0.body == .moon } }
    var risingSign: ZodiacSign? { ascendant.map { .at(longitude: $0) } }
    var lilith: Placement? { placements.first { $0.body == .blackMoonLilith } }

    /// "Leo sun, Scorpio moon, Capricorn rising" — the holy trinity, used everywhere.
    var bigThree: String {
        var parts: [String] = []
        if let s = sun { parts.append("\(s.sign.name) sun") }
        if let m = moon { parts.append("\(m.sign.name) moon") }
        if let r = risingSign { parts.append("\(r.name) rising") }
        return parts.joined(separator: ", ")
    }

    /// The card footer line: "LEO SUN · SCO MOON · CAP RISING". Abbreviated so it never clips.
    var bigThreeShort: String {
        var parts: [String] = []
        if let s = sun { parts.append("\(s.sign.name.prefix(3).uppercased()) SUN") }
        if let m = moon { parts.append("\(m.sign.name.prefix(3).uppercased()) MOON") }
        if let r = risingSign { parts.append("\(r.name.prefix(3).uppercased()) RISING") }
        return parts.joined(separator: " · ")
    }
}

// MARK: - Moon phase

enum MoonPhase: String, Codable, CaseIterable {
    case newMoon = "New Moon", waxingCrescent = "Waxing Crescent"
    case firstQuarter = "First Quarter", waxingGibbous = "Waxing Gibbous"
    case fullMoon = "Full Moon", waningGibbous = "Waning Gibbous"
    case lastQuarter = "Last Quarter", waningCrescent = "Waning Crescent"

    /// One-word status for the Today card credit line ("WANING", "WAXING", "NEW", "FULL").
    var shortLabel: String {
        switch self {
        case .newMoon: "NEW"
        case .fullMoon: "FULL"
        case .waxingCrescent, .firstQuarter, .waxingGibbous: "WAXING"
        case .waningGibbous, .lastQuarter, .waningCrescent: "WANING"
        }
    }
}
