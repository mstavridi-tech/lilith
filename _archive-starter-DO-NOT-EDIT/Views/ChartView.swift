import SwiftUI

/// The natal chart breakdown. Every placement, plain language, Lilith placement starred.
struct ChartView: View {
    let chart: NatalChart

    var body: some View {
        ZStack {
            Theme.void.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("YOUR CHART")
                        .font(Theme.display(36)).foregroundStyle(Theme.bone)
                    Text("Born \(chart.birthData.placeName). The sky kept receipts.")
                        .font(Theme.body()).foregroundStyle(Theme.gold)

                    if chart.risingSign == nil {
                        missingTimeNote
                    }

                    ForEach(chart.placements) { placement in
                        placementRow(placement)
                    }

                    aspectsSection
                }
                .padding(24)
            }
        }
    }

    private func placementRow(_ p: Placement) -> some View {
        let isLilith = p.body == .blackMoonLilith
        return HStack(alignment: .top, spacing: 16) {
            Text(p.body.glyph)
                .font(Theme.display(24))
                .foregroundStyle(isLilith ? Theme.ember : Theme.gold)
                .frame(width: 36)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(p.body.displayName.uppercased())
                        .font(Theme.mono(13)).foregroundStyle(Theme.bone.opacity(0.6))
                    if isLilith {
                        Text("★ THE NAMESAKE")
                            .font(Theme.mono(10)).foregroundStyle(Theme.ember)
                    }
                }
                Text(p.formatted)
                    .font(Theme.body(17)).foregroundStyle(Theme.bone)
                if let house = p.house {
                    Text("House \(house)")
                        .font(Theme.mono(12)).foregroundStyle(Theme.gold.opacity(0.7))
                }
                // Phase 1.1: tap → full AI-written interpretation of this placement
            }
            Spacer()
        }
        .lilithCard()
    }

    private var aspectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MAJOR ASPECTS")
                .font(Theme.display(20)).foregroundStyle(Theme.bone)
            ForEach(chart.aspects.prefix(8)) { aspect in
                HStack {
                    Text("\(aspect.a.glyph) \(aspect.type.rawValue) \(aspect.b.glyph)")
                        .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.85))
                    Spacer()
                    Text(String(format: "%.1f° orb", aspect.orb))
                        .font(Theme.mono(12)).foregroundStyle(Theme.gold.opacity(0.6))
                }
            }
        }
        .lilithCard()
    }

    private var missingTimeNote: some View {
        Text("No birth time = no rising sign or houses. Your mother knows. Ask her, then update in settings.")
            .font(Theme.body(14)).foregroundStyle(Theme.ember)
            .lilithCard()
    }
}
