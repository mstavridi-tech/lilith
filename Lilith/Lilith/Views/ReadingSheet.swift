import SwiftUI

/// Which reading is open, as a sheet item. Works for any placement (and for rising, which is the
/// ascendant rather than a body), so every row on ChartView can open one.
struct ReadingSelection: Identifiable {
    let readingKey: String   // JSON key: "sun", "mercury", "northNode", "lilith", "rising"
    let title: String        // "LEO SUN", "MERCURY IN GEMINI", "BLACK MOON LILITH IN VIRGO"
    let glyph: String
    let sign: ZodiacSign
    let isLilith: Bool

    var id: String { "\(readingKey)-\(sign.rawValue)" }

    /// Build from a real placement (any body).
    init(placement p: Placement) {
        let sign = p.sign
        self.readingKey = p.body.readingKey
        self.glyph = p.body.glyph
        self.sign = sign
        self.isLilith = p.body == .blackMoonLilith
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

                if let signReading {
                    Text("FOR YOU")
                        .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
                        .foregroundStyle(Theme.ember)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, explainer == nil ? 26 : 28)
                    paragraph(signReading).padding(.top, 12)
                }

                if explainer == nil && signReading == nil {
                    paragraph("This one's still being written in the stars. Check back in a bit, babe.")
                        .padding(.top, 26)
                }

                Wordmark().padding(.top, 44)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .cosmicScreen(bloomAlignment: .top, bloomIntensity: selection.isLilith ? 0.9 : 0.6)
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
}
