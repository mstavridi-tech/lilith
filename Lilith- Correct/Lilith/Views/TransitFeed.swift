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

/// The feed, restructured July 5 (the card-density verdict): ONE hero card for the loudest
/// transit, then the rest as quiet hairline rows. Six identical boxes read as noise; one headline
/// plus a list reads as a page. `limit` trims it for Today; Chart shows the lot.
struct TransitFeed: View {
    let transits: [Transit]
    var limit: Int? = nil

    private var shown: [Transit] {
        if let limit { return Array(transits.prefix(limit)) }
        return transits
    }

    // July 5 v3 (Maria: one thing in a card and the rest not read as inconsistent, and she's
    // right: mixed containment breaks the gestalt). Now NOTHING is boxed; the hero leads by
    // scale and weight alone (bigger glyph, serif title, fuller line), the rest follow smaller
    // on hairlines. One visual system, three sizes: how a magazine does hierarchy.
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let hero = shown.first {
                heroRow(hero)
            }
            ForEach(Array(shown.dropFirst().enumerated()), id: \.element.id) { index, transit in
                Rectangle().fill(Theme.gold.opacity(0.12)).frame(height: 0.5)
                compactRow(transit)
            }
            if transits.isEmpty {
                Text("The sky is quiet on your chart today. Rare. Enjoy it, or cause something yourself.")
                    .font(Theme.body(14).italic())
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .shadow(color: .black.opacity(0.35), radius: 8, y: 1) // legible straight on the plate
    }

    private func heroRow(_ transit: Transit) -> some View {
        let hard = transit.type == .square || transit.type == .opposition
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(transit.transiting.body.glyph)
                    .font(Theme.display(24))
                    .foregroundStyle(Theme.gold)
                Text(transit.title)
                    .font(Theme.display(20).weight(.medium))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(transit.tag)
                    .font(Theme.label(8.5))
                    .tracking(1.0)
                    .foregroundStyle(hard ? Theme.ember : Theme.gold)
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Capsule().fill((hard ? Theme.ember : Theme.gold).opacity(0.12)))
            }
            Text(transit.line)
                .font(Theme.body(15))
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 14)
    }

    private func compactRow(_ transit: Transit) -> some View {
        let hard = transit.type == .square || transit.type == .opposition
        return VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 10) {
                Text(transit.transiting.body.glyph)
                    .font(Theme.display(15))
                    .foregroundStyle(Theme.gold.opacity(0.85))
                    .frame(width: 22)
                Text(transit.title)
                    .font(Theme.body(15))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text(transit.tag)
                    .font(Theme.label(8))
                    .tracking(0.9)
                    .foregroundStyle((hard ? Theme.ember : Theme.gold).opacity(0.85))
            }
            Text(transit.line)
                .font(Theme.body(13))
                .foregroundStyle(Theme.textTertiary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 32)
        }
        .padding(.vertical, 13)
    }
}
