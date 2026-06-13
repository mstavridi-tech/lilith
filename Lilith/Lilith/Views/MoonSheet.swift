import SwiftUI

/// Tap the moon on the Today card and this opens: tonight's real phase, the sign it's in, and
/// what that actually means for HER chart (the house it's transiting, whether it's home in her
/// natal moon sign). Real data, house voice. No medical or doom claims, ever.
struct MoonSheet: View {
    let chart: NatalChart
    @Environment(\.dismiss) private var dismiss

    @State private var phase: MoonPhase = .fullMoon
    @State private var moon: Placement?
    @State private var elongation: Double = 180

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MoonView(diameter: 150, elongation: elongation)
                    .frame(height: 150)
                    .padding(.top, 40)

                Text(phase.rawValue.uppercased())
                    .displayCaps(26, em: 0.16)
                    .multilineTextAlignment(.center)
                    .padding(.leading, Theme.tracking(26, em: 0.16))
                    .padding(.top, 26)

                if let moon {
                    Text("Moon in \(moon.sign.name) · \(Int(moon.degreeInSign))°")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.12))
                        .foregroundStyle(Theme.gold.opacity(0.85))
                        .padding(.top, 10)
                }

                HairlineDivider(width: 120).padding(.top, 22)

                Text(meaning)
                    .font(Theme.body(17))
                    .foregroundStyle(Theme.bone.opacity(0.92))
                    .lineSpacing(7)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 26)

                Wordmark().padding(.top, 44)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .cosmicScreen(bloomAlignment: .top, bloomIntensity: 0.6)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
        .task { load() }
    }

    private func load() {
        if let p = try? ChartEngine.moonPhase() { phase = p }
        if let e = try? ChartEngine.moonElongation() { elongation = e }
        moon = try? ChartEngine.currentSky().first { $0.body == .moon }
    }

    /// Built from real data: the house the transiting moon lands in for her, whether it's home in
    /// her natal moon sign, and the phase's energy. Stitched in voice, never generic.
    private var meaning: String {
        var lines: [String] = []

        if let moon {
            lines.append("Tonight the moon is \(phase.rawValue.lowercased()) in \(moon.sign.name).")

            if let cusps = chart.houseCusps {
                let h = ChartEngine.house(of: moon.longitude, cusps: cusps)
                lines.append("For you it's moving through your \(ordinal(h)) house, the part of your chart about \(Self.houseThemes[h - 1]). That's where the feelings want your attention right now.")
            }

            if let natal = chart.moon?.sign, natal == moon.sign {
                lines.append("And it's home in \(natal.name), your own natal moon sign, so this one lands closer than most. You're allowed to feel it fully.")
            }
        }

        lines.append(Self.phaseEnergy[phase] ?? "")
        return lines.filter { !$0.isEmpty }.joined(separator: " ")
    }

    private func ordinal(_ n: Int) -> String {
        switch n {
        case 1: "1st"; case 2: "2nd"; case 3: "3rd"
        default: "\(n)th"
        }
    }

    /// Whole-sign house meanings, plain language.
    private static let houseThemes = [
        "you, your body, the first impression you make",
        "money, worth, the things you actually value",
        "your mind, your words, the people closest by",
        "home, family, where you come from",
        "romance, play, the things you make for the joy of it",
        "work, health, the daily routine",
        "partnership, the one across the table from you",
        "intimacy, what you share, what transforms you",
        "travel, belief, the bigger picture",
        "career, reputation, what you're building in public",
        "friends, community, the future you're walking toward",
        "rest, the subconscious, the part only you see"
    ]

    /// Phase energy lines. Honest, in voice, never doom.
    private static let phaseEnergy: [MoonPhase: String] = [
        .newMoon: "New moon energy: plant the seed, don't expect the tree by morning. Set the intention and let it be quiet.",
        .waxingCrescent: "It's building. Small yeses now, the kind future-you thanks you for.",
        .firstQuarter: "A little tension is normal here, it's the push that gets things moving. Make the decision.",
        .waxingGibbous: "Almost there. Refine, don't restart. You're closer than the impatience says.",
        .fullMoon: "Everything's turned up, feelings included. It's not that deep, except where it fully is. Let it peak, then breathe.",
        .waningGibbous: "Time to share what you learned and loosen the grip on the rest.",
        .lastQuarter: "Release without a press conference. You don't owe anyone the announcement.",
        .waningCrescent: "Wind down. Rest is not the reward for the cycle, it's part of it."
    ]
}
