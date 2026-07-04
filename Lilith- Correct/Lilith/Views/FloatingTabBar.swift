import SwiftUI

/// The four tabs. Real vector icons (SF Symbols), per the pro-UI rule: text glyphs pretending to
/// be icons are the single fastest amateur tell. LILITH's character lives in the gold, the glow,
/// and the dark glass, not in unicode characters.
enum MainTab: Int, CaseIterable, Identifiable {
    case today, cycle, trends, chart, you
    var id: Int { rawValue }

    /// Resting icon, thin and quiet.
    var symbol: String {
        switch self {
        case .today: "moon.stars"
        case .cycle: "drop"
        case .trends: "chart.line.uptrend.xyaxis"
        case .chart: "sparkles"
        case .you: "person"
        }
    }

    /// The active tab fills in, so selection reads by shape as well as color (never color alone).
    /// Trends' chart symbol has no fill variant; like sparkles, it leans on the color + dot.
    var symbolActive: String {
        switch self {
        case .today: "moon.stars.fill"
        case .cycle: "drop.fill"
        case .trends: "chart.line.uptrend.xyaxis"
        case .chart: "sparkles"
        case .you: "person.fill"
        }
    }

    var label: String {
        switch self {
        case .today: "TODAY"
        case .cycle: "CYCLE"
        case .trends: "TRENDS"
        case .chart: "CHART"
        case .you: "YOU"
        }
    }
}

/// Dark glass, floating clear of the home indicator, gold glyph + tiny mono label + a lit dot for
/// the active tab. Ports the mockup's `.tabbar` straight into SwiftUI (docs/design, the aura glow-up).
struct FloatingTabBar: View {
    @Binding var selection: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases) { tab in
                Button {
                    guard selection != tab else { return }
                    Haptics.light()
                    selection = tab
                } label: {
                    tabItem(tab)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 10)
        .padding(.horizontal, 8)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(
                    Capsule().fill(
                        LinearGradient(colors: [Theme.void.opacity(0.88), Theme.void.opacity(0.95)],
                                      startPoint: .top, endPoint: .bottom))
                )
                .overlay(Capsule().strokeBorder(Theme.bone.opacity(0.09), lineWidth: 0.75))
                .shadow(color: .black.opacity(0.55), radius: 22, y: 12)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private func tabItem(_ tab: MainTab) -> some View {
        let on = tab == selection
        return VStack(spacing: 5) {
            Image(systemName: on ? tab.symbolActive : tab.symbol)
                .font(.system(size: 16, weight: .regular))
                .symbolRenderingMode(.hierarchical)
                .frame(height: 18)
                .shadow(color: on ? Theme.gold.opacity(0.6) : .clear, radius: 8)
            Text(tab.label)
                .font(Theme.label(9))
                .tracking(0.8)
            Circle()
                .fill(on ? Theme.gold : .clear)
                .frame(width: 3, height: 3)
                .shadow(color: on ? Theme.gold : .clear, radius: 4)
        }
        .foregroundStyle(on ? Theme.gold : Theme.bone.opacity(0.55)) // ≥3:1 even at rest
        .padding(.vertical, 2) // keeps each target comfortably past 44pt with the bar's padding
        .contentShape(Rectangle())
    }
}
