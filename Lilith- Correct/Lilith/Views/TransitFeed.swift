import SwiftUI

/// The transit feed, ported from the Kimi reference's "Celestial Movements" section (the layout
/// Maria approved July 4, 2026): one card per transit, planet title, aspect tag chip on the right,
/// one line in voice underneath. Every card is computed by TransitEngine from the real sky against
/// her real chart; nothing here is canned.
struct TransitCard: View {
    let transit: Transit

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                Text(transit.transiting.body.glyph)
                    .font(Theme.display(17))
                    .foregroundStyle(Theme.gold)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Theme.surfaceHigh)
                            .overlay(Circle().strokeBorder(Theme.gold.opacity(0.25), lineWidth: 0.75))
                    )
                Text(transit.title)
                    .font(Theme.body(16).weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                tagChip
            }
            Text(transit.line)
                .font(Theme.body(14))
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(padding: 18)
    }

    /// SQUARE and OPPOSITION run ember (heat), the soft aspects run gold (gift).
    private var tagChip: some View {
        let hard = transit.type == .square || transit.type == .opposition
        let color = hard ? Theme.ember : Theme.gold
        return Text(transit.tag)
            .font(Theme.label(8.5))
            .tracking(1.0)
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Capsule().fill(color.opacity(0.12)))
    }
}

/// A titled stack of transit cards. `limit` trims it for Today; Chart shows the lot.
struct TransitFeed: View {
    let transits: [Transit]
    var limit: Int? = nil

    private var shown: [Transit] {
        if let limit { return Array(transits.prefix(limit)) }
        return transits
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(shown) { TransitCard(transit: $0) }
            if transits.isEmpty {
                Text("The sky is quiet on your chart today. Rare. Enjoy it, or cause something yourself.")
                    .font(Theme.body(14).italic())
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .softCard(padding: 18)
            }
        }
    }
}
