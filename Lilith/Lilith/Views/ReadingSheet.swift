import SwiftUI

/// Which reading is open, as a sheet item. Works for any placement (and for rising, which is the
/// ascendant rather than a body), so every row on ChartView can open one.
struct ReadingSelection: Identifiable {
    let readingKey: String   // JSON key: "sun", "mercury", "northNode", "lilith", "rising"
    let title: String        // "LEO SUN", "MERCURY IN GEMINI", "BLACK MOON LILITH IN VIRGO"
    let glyph: String
    let sign: ZodiacSign
    let isLilith: Bool
    var house: Int? = nil    // the placement's house, for personalizing the generational bodies

    var id: String { "\(readingKey)-\(sign.rawValue)" }

    /// Build from a real placement (any body).
    init(placement p: Placement) {
        let sign = p.sign
        self.readingKey = p.body.readingKey
        self.glyph = p.body.glyph
        self.sign = sign
        self.isLilith = p.body == .blackMoonLilith
        self.house = p.house
        switch p.body {
        case .sun:  self.title = "\(sign.name.uppercased()) SUN"
        case .moon: self.title = "\(sign.name.uppercased()) MOON"
        default:    self.title = "\(p.body.readingDisplayName) IN \(sign.name.uppercased())"
        }
    }

    private init(readingKey: String, title: String, glyph: String, sign: ZodiacSign, isLilith: Bool) {
        self.readingKey = readingKey; self.title = title; self.glyph = glyph
        self.sign = sign; self.isLilith = isLilith
    }

    /// Build a big-three row selection (rising is the ascendant, not a placement body).
    static func bigThree(_ part: BigThreePart, sign: ZodiacSign) -> ReadingSelection {
        ReadingSelection(readingKey: part.key,
                         title: "\(sign.name.uppercased()) \(part.titleSuffix)",
                         glyph: part.glyph, sign: sign, isLilith: false)
    }
}

/// A reading, in the house style: cosmic backdrop, a glyph, the placement title in letterspaced
/// serif caps, then the explainer (what the placement is) followed by her personal sign reading.
/// Bodies the JSON has no sign set for (uranus, neptune, pluto, north node) show explainer only.
/// Lilith, the namesake, gets the ember treatment.
struct ReadingSheet: View {
    let selection: ReadingSelection
    @Environment(\.dismiss) private var dismiss

    private var accent: Color { selection.isLilith ? Theme.ember : Theme.gold }
    private var isAsc: Bool { selection.glyph == "ASC" }

    private var explainer: String? { ReadingStore.shared.explainer(forKey: selection.readingKey) }
    private var signReading: String? {
        ReadingStore.shared.signReading(forKey: selection.readingKey, sign: selection.sign)
    }

    /// The personal half of the sheet. For most bodies it's the sign reading. For the generational
    /// bodies (uranus, neptune, pluto, north node) the sign is shared by a whole generation, so the
    /// personal axis is the HOUSE: this builds her own house-based reading instead, when we have a
    /// birth time. Result: every sheet has a "FOR YOU", and none of them is generic.
    private var personalReading: String? {
        if let signReading { return signReading }
        if let house = selection.house {
            return Self.houseReading(key: selection.readingKey, house: house)
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text(selection.glyph)
                    .font(isAsc ? Theme.mono(15) : Theme.display(40))
                    .tracking(isAsc ? Theme.tracking(15, em: 0.2) : 0)
                    .foregroundStyle(accent)
                    .padding(.top, 44)

                Text(selection.title)
                    .displayCaps(26, em: 0.16, color: selection.isLilith ? Theme.ember : Theme.bone)
                    .multilineTextAlignment(.center)
                    .padding(.leading, Theme.tracking(26, em: 0.16))
                    .padding(.top, 18)

                if selection.isLilith {
                    Text("★ THE NAMESAKE")
                        .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.18))
                        .foregroundStyle(Theme.ember)
                        .padding(.top, 10)
                }

                HairlineDivider(width: 120).padding(.top, 22)

                if let explainer {
                    paragraph(explainer).padding(.top, 26)
                }

                if let personalReading {
                    Text("FOR YOU")
                        .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
                        .foregroundStyle(Theme.ember)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, explainer == nil ? 26 : 28)
                    paragraph(personalReading).padding(.top, 12)
                }

                if explainer == nil && personalReading == nil {
                    paragraph("This one's still being written in the stars. Check back in a bit, babe.")
                        .padding(.top, 26)
                }

                Wordmark().padding(.top, 44)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: selection.glyph, accent: accent)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
    }

    private func paragraph(_ text: String) -> some View {
        Text(text)
            .font(Theme.body(17))
            .foregroundStyle(Theme.bone.opacity(0.92))
            .lineSpacing(7)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - House-based personalization for the generational bodies

    /// Her own reading for a generational body, built from the HOUSE it falls in (the personal part)
    /// and what that body does there. Voice: warm, light roast, never doom, never medical. Returns
    /// nil for any body that isn't generational, so the personal slot stays empty rather than wrong.
    static func houseReading(key: String, house: Int) -> String {
        guard (1...12).contains(house) else { return "" }
        let area = houseAreas[house - 1]
        let ord = ordinal(house)
        switch key {
        case "uranus":
            return "Your Uranus lives in your \(ord) house, so \(area) is where you refuse to do it the way you were told. That's where you break the pattern, surprise people, and need the freedom to change your mind. The chaos there is usually the good kind."
        case "neptune":
            return "Your Neptune sits in your \(ord) house, so \(area) is where you dream, idealize, and chase something bigger than yourself. It's also where you're most likely to see what you want to see, so keep one foot on the ground and let the other one float."
        case "pluto":
            return "Your Pluto is in your \(ord) house, so \(area) is where you go deep, where power and control play out for you, and where you've probably already survived something that remade you. That's not damage. That's your forge."
        case "northNode":
            return "Your north node is in your \(ord) house, so \(area) is the direction your life keeps nudging you toward. It feels unfamiliar on purpose. Lean in anyway. That's where you grow into who you're becoming."
        default:
            return "" // not a generational body; its personal reading is the sign reading
        }
    }

    /// Plain-language meaning of each house, matched to the MoonSheet's language.
    private static let houseAreas = [
        "your body and the first impression you make",
        "money, worth, and the things you actually value",
        "your mind, your words, and the people closest by",
        "home, family, and where you come from",
        "romance, play, and the things you make for joy",
        "work, health, and the daily routine",
        "partnership and the one across the table from you",
        "intimacy, what you share, and what transforms you",
        "travel, belief, and the bigger picture",
        "career, reputation, and what you build in public",
        "friends, community, and the future you're walking toward",
        "rest, the subconscious, and the part only you see"
    ]

    private static func ordinal(_ n: Int) -> String {
        switch n {
        case 1: "1st"; case 2: "2nd"; case 3: "3rd"
        default: "\(n)th"
        }
    }
}
