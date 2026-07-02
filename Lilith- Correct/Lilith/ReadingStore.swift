import Foundation

/// The three placements a girl quotes about herself first. Used to render the big-three highlight
/// rows on ChartView; the readings themselves come from ReadingStore by key, same as every body.
enum BigThreePart: String, CaseIterable, Identifiable {
    case sun, moon, rising
    var id: String { rawValue }

    /// Key into ChartReadings.json.
    var key: String { rawValue }

    /// The word after the sign in a title: "LEO SUN", "SCORPIO MOON", "CAPRICORN RISING".
    var titleSuffix: String { rawValue.uppercased() }

    /// Glyph for the row mark. Rising has no planet glyph, so it gets the "ASC" tick.
    var glyph: String {
        switch self {
        case .sun: "☉"
        case .moon: "☽"
        case .rising: "ASC"
        }
    }
}

extension CelestialBody {
    /// Key into ChartReadings.json. Matches rawValue for most bodies; the node and Lilith differ
    /// (rawValue carries display spellings). Decoded dynamically, so a body the JSON doesn't yet
    /// cover simply returns nil readings rather than stranding the UI.
    var readingKey: String {
        switch self {
        case .northNode: "northNode"
        case .blackMoonLilith: "lilith"
        default: rawValue // sun, moon, mercury, venus, mars, jupiter, saturn, uranus, neptune, pluto
        }
    }

    /// Title-cased name for a reading sheet: "SUN", "NORTH NODE", "BLACK MOON LILITH".
    var readingDisplayName: String {
        switch self {
        case .northNode: "NORTH NODE"
        case .blackMoonLilith: "BLACK MOON LILITH"
        default: displayName.uppercased()
        }
    }
}

/// Loads the voice-approved readings from ChartReadings.json (in the app bundle) and serves them
/// by key. The whole file is decoded dynamically as nested string maps, so when Maria adds a new
/// body or explainer the UI picks it up with no code change. Two kinds of entry live in the file:
/// per-body sign sets (`body -> sign -> text`) and the shared `explainers` map (`body -> text`).
/// Tone is warm with a light roast on purpose: do not punch it up.
struct ReadingStore {
    static let shared = ReadingStore()

    private let data: [String: [String: String]]

    init() {
        guard let url = Bundle.main.url(forResource: "ChartReadings", withExtension: "json"),
              let raw = try? Data(contentsOf: url),
              let parsed = try? JSONDecoder().decode([String: [String: String]].self, from: raw)
        else {
            data = [:]
            return
        }
        data = parsed
    }

    /// The general "what this placement is" explainer for a body key, or nil if absent.
    func explainer(forKey key: String) -> String? {
        data["explainers"]?[key]
    }

    /// Her personal reading for a body key in a given sign, or nil if the JSON has no set for it.
    func signReading(forKey key: String, sign: ZodiacSign) -> String? {
        data[key]?[sign.name.lowercased()]
    }
}
