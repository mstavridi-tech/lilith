import SwiftUI

/// The vibe ring (July 4, 2026): the synergy piece Maria asked for between LILITH's sky and the
/// health-app legibility she liked in the Kimi reference. One flat ring, filled to a plain-language
/// energy estimate computed from her cycle phase and tonight's moon. Never biometrics, never a
/// score pretending to be medicine: it's the best friend guessing how today probably feels, with
/// the receipts (phase + moon) stated right there. If she isn't tracking her cycle yet, the moon
/// carries the read alone. Wellness content, not diagnosis (docs/01 trust rules).
struct VibeCheck: View {
    let cycle: CycleState?
    let moon: MoonPhase
    let illumination: Double // 0...1, tonight's lit fraction

    private var vibe: (word: String, line: String, level: Double) {
        Self.vibe(cycle: cycle?.phase, moon: moon, illumination: illumination)
    }

    private var accent: Color { cycle?.phase.aura ?? Theme.gold }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Text("THE VIBE")
                    .font(Theme.label(10))
                    .tracking(1.4)
                    .foregroundStyle(Theme.gold.opacity(0.8))
                Spacer()
                Text(receipts)
                    .font(Theme.label(9))
                    .tracking(0.8)
                    .foregroundStyle(Theme.textTertiary)
            }

            HStack(spacing: 18) {
                ring
                VStack(alignment: .leading, spacing: 5) {
                    Text(vibe.word)
                        .font(Theme.display(19).weight(.medium))
                        .tracking(Theme.tracking(19, em: 0.08))
                        .foregroundStyle(Theme.textPrimary)
                    Text(vibe.line)
                        .font(Theme.body(14))
                        .foregroundStyle(Theme.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(padding: 20)
    }

    /// Where the estimate comes from, stated plainly. The anti-black-box move.
    private var receipts: String {
        if let cycle { return "\(cycle.phase.name.uppercased()) · \(moon.shortLabel) MOON" }
        return "\(moon.shortLabel) MOON"
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Theme.bone.opacity(0.10), style: StrokeStyle(lineWidth: 7))
            Circle()
                .trim(from: 0, to: max(0.04, vibe.level))
                .stroke(accent, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: accent.opacity(0.4), radius: 7)
        }
        .frame(width: 60, height: 60)
    }

    /// The vibe matrix: cycle phase sets the baseline, the moon bends it. Pure and testable.
    /// Every word and line is voice-guide copy (docs/03, docs/07): affirm first, never doom,
    /// no medical claims, NO em dashes.
    static func vibe(cycle: CyclePhase?, moon: MoonPhase, illumination: Double)
        -> (word: String, line: String, level: Double) {

        // The moon bends the baseline: fuller sky, louder day. Small on purpose.
        func bend(_ base: Double) -> Double {
            min(1, max(0.08, base + (illumination - 0.5) * 0.15))
        }

        guard let cycle else {
            // Not tracking yet: the sky carries the read alone.
            switch moon {
            case .fullMoon:
                return ("ALL SIGNAL", "Full moon. Everything is loud today and no, you're not imagining it.", bend(0.85))
            case .newMoon:
                return ("CLEAN SLATE", "New moon. Quiet sky, quiet you. Plant something and tell no one yet.", bend(0.3))
            case .waxingCrescent, .firstQuarter, .waxingGibbous:
                return ("BUILDING", "The moon is stacking momentum and you're invited. Act while it climbs.", bend(0.6))
            case .waningGibbous, .lastQuarter, .waningCrescent:
                return ("EXHALE", "The sky is winding down. You have permission to match it.", bend(0.4))
            }
        }

        switch cycle {
        case .menstrual:
            if moon == .fullMoon {
                return ("RED MOON", "Bleeding on a full moon. Potent, magnetic, a lot at once. Old magic, channel it.", 0.5)
            }
            if moon == .newMoon {
                return ("WHITE MOON", "Bleeding on a new moon. All the way inward. Rest is the whole assignment.", 0.15)
            }
            return ("LOW POWER MODE", "Hormones at the floor. Tired is data, not drama. Do less, gorgeous.", bend(0.2))
        case .follicular:
            return ("ON THE RISE", "Estrogen is climbing and so are you. Start the thing you've been circling.", bend(0.65))
        case .ovulatory:
            return ("MAIN CHARACTER", "Peak everything. Book the thing, send the text, wear the outfit.", bend(0.9))
        case .luteal:
            return ("EDIT MODE", "Energy is turning inward. Finish, don't start. And eat something real.", bend(0.45))
        }
    }
}
