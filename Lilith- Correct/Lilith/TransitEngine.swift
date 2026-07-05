import Foundation

/// One live transit: a planet in today's sky making an exact-enough aspect to one of HER natal
/// placements. The Kimi reference faked this feed with hardcoded strings; ours is computed from
/// SwiftAA, so every card is real astrology (docs rule 5). Pure local math, no network.
struct Transit: Identifiable {
    let transiting: Placement   // today's sky
    let natal: Placement        // hers, from the verified ChartEngine
    let type: AspectType
    let orb: Double             // degrees off exact; smaller = louder

    var id: String { "\(transiting.body.rawValue)-\(type.rawValue)-\(natal.body.rawValue)" }
    var tag: String { type.rawValue.uppercased() }
    var title: String { "\(transiting.body.displayName) in \(transiting.sign.name)" }
    var line: String { TransitEngine.line(for: self) }
}

enum TransitEngine {
    /// Transit orbs are tight on purpose: a transit is only "on" when it's close. (Natal aspect
    /// orbs are wider; that's a different job, handled in ChartEngine.)
    private static let orbs: [AspectType: Double] = [
        .conjunction: 5, .opposition: 5, .square: 4, .trine: 4, .sextile: 3
    ]

    /// Drama ranking. Hard aspects lead the feed because that's what she can feel.
    private static let weight: [AspectType: Double] = [
        .square: 5, .opposition: 4.5, .conjunction: 4, .trine: 3, .sextile: 2
    ]

    /// Today's transits against her chart, strongest first, at most one per transiting planet (the
    /// loudest it makes). The transiting Moon is excluded: it aspects everything for a few hours at
    /// a time and would drown everyone else out; the Moon already has the sky card.
    static func current(for chart: NatalChart) -> [Transit] {
        guard let sky = try? ChartEngine.currentSky() else { return [] }
        var results: [Transit] = []
        for t in sky where t.body != .moon {
            var best: Transit?
            for n in chart.placements {
                let sep = separation(t.longitude, n.longitude)
                for type in AspectType.allCases {
                    let orb = abs(sep - type.angle)
                    guard orb <= (orbs[type] ?? 0) else { continue }
                    let candidate = Transit(transiting: t, natal: n, type: type, orb: orb)
                    if best == nil || score(candidate) > score(best!) { best = candidate }
                }
            }
            if let best { results.append(best) }
        }
        return results.sorted { score($0) > score($1) }
    }

    /// Angular separation on the ecliptic circle, 0...180.
    private static func separation(_ a: Double, _ b: Double) -> Double {
        let d = abs(a - b).truncatingRemainder(dividingBy: 360)
        return d > 180 ? 360 - d : d
    }

    private static func score(_ t: Transit) -> Double {
        (weight[t.type] ?? 0) * 10 - t.orb
    }

    // MARK: The voice layer (docs/03: plain-language astrology, affirm first, NO em dashes)

    /// What each natal body means to her, in plain girl. The natal side of every sentence.
    private static func domain(_ body: CelestialBody) -> String {
        switch body {
        case .sun: "your whole personality"
        case .moon: "your feelings"
        case .mercury: "your words"
        case .venus: "your love life"
        case .mars: "your drive"
        case .jupiter: "your luck"
        case .saturn: "your rules"
        case .uranus: "your rebel streak"
        case .neptune: "your daydreams"
        case .pluto: "your power"
        case .northNode: "your path"
        case .blackMoonLilith: "your untamed side"
        }
    }

    /// One sentence per aspect flavor, best-friend register. The retrograde PS only fires for
    /// Mercury because that's the one everyone actually feels in their texts.
    static func line(for t: Transit) -> String {
        let T = t.transiting.body.displayName
        let d = domain(t.natal.body)
        // Three variants per flavor (July 5, Maria: identical phrasing three cards running was an
        // AI tell). Picked deterministically from the planet pair so a transit keeps its sentence
        // all day instead of shuffling per scroll.
        let variants: [String]
        switch t.type {
        case .conjunction:
            variants = [
                "\(T) is sitting right on \(d) today. Whatever gets loud is information, not an attack.",
                "\(T) has pulled up a chair right on top of \(d). Pay attention to what it stirs up.",
                "\(T) and \(d) are in the same room all day. Intense, but you run the thermostat."
            ]
        case .square:
            variants = [
                "\(T) is squaring up against \(d). Friction, but the useful kind. You don't have to attend every argument you're invited to.",
                "\(T) is testing \(d) today. Annoying, and also exactly how the growth happens.",
                "\(T) keeps poking at \(d). Breathe before you bite. It's not that deep."
            ]
        case .opposition:
            variants = [
                "\(T) is pulling \(d) in the opposite direction. Tug of war day. Pick your side on purpose.",
                "\(T) sits across the table from \(d) today. Hear both sides out, then you decide.",
                "\(T) versus \(d), full standoff. Balance is the assignment, not victory."
            ]
        case .trine:
            variants = [
                "\(T) is flowing straight into \(d). Doors open easier than usual. Walk through one.",
                "\(T) is on \(d)'s side today. Things that usually take effort just work. Use it.",
                "Green light from \(T) straight to \(d). Ask for the thing while the sky's in the mood."
            ]
        case .sextile:
            variants = [
                "\(T) is flirting with \(d). A soft assist from the sky. Take the nudge.",
                "\(T) is slipping \(d) a little luck today. Small window, real one.",
                "A quiet yes from \(T) to \(d). Not fireworks, just ease. Take it."
            ]
        }
        let ti = CelestialBody.allCases.firstIndex(of: t.transiting.body) ?? 0
        let ni = CelestialBody.allCases.firstIndex(of: t.natal.body) ?? 0
        var line = variants[(ti + ni) % variants.count]
        if t.transiting.body == .mercury && t.transiting.isRetrograde {
            line += " And Mercury is retrograde, so read the text twice before you send it."
        }
        return line
    }
}
