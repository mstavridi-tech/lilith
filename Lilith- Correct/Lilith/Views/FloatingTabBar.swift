import SwiftUI

/// The four tabs. Custom celestial glyphs instead of SF Symbols, so the one piece of chrome that
/// sits on every single screen still reads as LILITH and not a stock iOS app.
enum MainTab: Int, CaseIterable, Identifiable {
    case today, cycle, chart, you
    var id: Int { rawValue }

    var glyph: String {
        switch self {
        case .today: "☾"
        case .cycle: "◗"
        case .chart: "✶"
        case .you: "✦"
        }
    }

    var label: String {
        switch self {
        case .today: "TODAY"
        case .cycle: "CYCLE"
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
            Text(tab.glyph)
                .font(.system(size: 17))
                .shadow(color: on ? Theme.gold.opacity(0.65) : .clear, radius: 8)
            Text(tab.label)
                .font(Theme.mono(8.5))
                .tracking(Theme.tracking(8.5, em: 0.22))
            Circle()
                .fill(on ? Theme.gold : .clear)
                .frame(width: 3, height: 3)
                .shadow(color: on ? Theme.gold : .clear, radius: 4)
        }
        .foregroundStyle(on ? Theme.gold : Theme.bone.opacity(0.4))
        .contentShape(Rectangle())
    }
}
