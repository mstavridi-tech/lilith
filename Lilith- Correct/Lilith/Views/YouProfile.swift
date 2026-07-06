import SwiftUI

// MARK: - THE FILE ON YOU (July 5, Maria's spec: a profile that reads out who she is and
// everything the app has figured out about her)
//
// Assembled entirely from what's already on the phone: her chart, her logs, her rhythms. The more
// she logs, the thicker the file gets, and the page says so. All on-device, like everything.

struct YouProfileSheet: View {
    let chart: NatalChart?
    @ObservedObject private var store = CycleStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("THE FILE ON YOU")
                    .displayCaps(26, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(26, em: 0.14))
                    .padding(.top, 44)
                Text("Everything I've learned. So far.")
                    .font(Theme.body(15).italic()).foregroundStyle(Theme.gold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)

                if let chart {
                    skySection(chart)
                } else {
                    Text("No chart yet. Add your birth data in YOU and this file starts writing itself.")
                        .font(Theme.body(15)).foregroundStyle(Theme.ember)
                        .lineSpacing(6)
                        .padding(.top, 28)
                }

                bodySection

                Text("This file sharpens every time you log. I'm taking notes, lovingly.")
                    .font(Theme.body(12).italic()).foregroundStyle(Theme.gold.opacity(0.65))
                    .padding(.top, 28)

                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 44)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: "", accent: Theme.gold)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.control(11)).tracking(1.1)
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
    }

    // MARK: Who the sky says you are

    private func skySection(_ chart: NatalChart) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            label("WHO THE SKY SAYS YOU ARE")
            entry("You're a \(chart.bigThree). That's the headline; the fine print is the fun part.")
            entry(elementLine(chart))
            if let lilith = chart.lilith {
                entry("Your Lilith, the namesake, sits in \(lilith.sign.name): that's where your zero-apologies side lives, and this app was named after her for a reason.")
            }
        }
        .padding(.top, 4)
    }

    /// Which element dominates her placements, said like a friend, not an almanac.
    private func elementLine(_ chart: NatalChart) -> String {
        var counts = [0, 0, 0, 0] // fire, earth, air, water
        for p in chart.placements { counts[p.sign.rawValue % 4] += 1 }
        let names = ["fire", "earth", "air", "water"]
        let lines = [
            "Your chart runs hot with fire: instinct first, apology later, and honestly it usually works out.",
            "Your chart is earth-heavy: you build things, you keep receipts, and you actually finish what you start.",
            "Air dominates your chart: words, ideas, and the group chat are your natural habitat.",
            "Water leads your chart: you feel everything first and think it second, which is a superpower with a learning curve."
        ]
        let top = counts.firstIndex(of: counts.max() ?? 0) ?? 0
        let _ = names // element names kept for future breakdowns
        return lines[top]
    }

    // MARK: What your body taught me

    private var bodySection: some View {
        let starts = CycleMath.periodStarts(store.entries)
        let length = CycleMath.averageLength(starts)
        let bleed = CycleMath.averagePeriodLength(store.entries)
        let logged = store.entries.count
        let since = store.entries.map(\.date).min()

        return VStack(alignment: .leading, spacing: 0) {
            label("WHAT YOUR BODY TAUGHT ME").padding(.top, 24)
            if starts.isEmpty {
                entry("Nothing yet: log your first period and the biography starts. Chapter one writes fast.")
            } else {
                entry("Your cycle runs about \(length) days, with roughly \(bleed) days of bleeding. \(starts.count == 1 ? "One cycle logged so far, so this is a first impression, not a verdict." : "That's from \(starts.count) logged cycles, so it's getting real.")")
                if let since {
                    entry("You've trusted me with \(logged) logged days since \(Self.month.string(from: since)). Every one made the picture sharper.")
                }
                if let state = store.today {
                    entry("Right now you're on day \(state.cycleDay), in your \(state.phase.rawValue) era: \(state.phase.tagline).")
                }
            }
        }
    }

    // MARK: Pieces

    private func label(_ text: String) -> some View {
        Text(text)
            .font(Theme.control(10)).tracking(1.1)
            .foregroundStyle(Theme.ember)
            .padding(.top, 24)
    }

    private func entry(_ text: String) -> some View {
        Text(text)
            .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.88))
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 12)
    }

    private static let month: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; return f
    }()
}
