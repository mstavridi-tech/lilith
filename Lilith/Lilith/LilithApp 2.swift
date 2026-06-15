import SwiftUI

@main
struct LilithApp: App {
    // Birth data persisted as JSON in UserDefaults for the MVP.
    // Move to SwiftData when CycleEntry arrives in Phase 2.
    @AppStorage("birthData") private var birthDataJSON: String = ""

    init() {
        // Register Cormorant Garamond at launch (no Info.plist editing needed). No-ops gracefully
        // until the .ttf files are added to the target, at which point the real typeface activates.
        Theme.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootContainer {
                Group {
                    if let chart = storedChart {
                        MainTabView(chart: chart)
                    } else {
                        OnboardingView { birth in
                            if let data = try? JSONEncoder().encode(birth) {
                                birthDataJSON = String(data: data, encoding: .utf8) ?? ""
                            }
                        }
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }

    private var storedChart: NatalChart? {
        guard let data = birthDataJSON.data(using: .utf8),
              let birth = try? JSONDecoder().decode(BirthData.self, from: data),
              let chart = try? ChartEngine.natalChart(for: birth)
        else { return nil }
        return chart
    }
}

/// Holds the app and, on a cold launch, the launch ritual on top of it. Two seconds of theater
/// (docs/08): pure void with grain, the wordmark fading in letterspaced, then a crossfade to the app.
struct RootContainer<Content: View>: View {
    @ViewBuilder var content: Content
    @State private var showLaunch = true

    var body: some View {
        ZStack {
            content
            if showLaunch {
                LaunchRitual {
                    withAnimation(.easeInOut(duration: 0.7)) { showLaunch = false }
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

/// The title card. The wordmark rises out of the void, holds a beat, then signals it's done.
struct LaunchRitual: View {
    var onDone: () -> Void
    @State private var wordmarkIn = false

    var body: some View {
        ZStack {
            Theme.void.ignoresSafeArea()
            Text("LILITH")
                .font(Theme.display(34).weight(.medium))
                .tracking(Theme.tracking(34, em: 0.5))
                .foregroundStyle(Theme.gold.opacity(0.92))
                .padding(.leading, Theme.tracking(34, em: 0.5)) // recenter the wide tracking
                .opacity(wordmarkIn ? 1 : 0)
                .scaleEffect(wordmarkIn ? 1 : 0.98)
            GrainOverlay()
        }
        .task {
            withAnimation(.easeOut(duration: 1.1)) { wordmarkIn = true }
            try? await Task.sleep(nanoseconds: 1_900_000_000)
            onDone()
        }
    }
}

struct MainTabView: View {
    let chart: NatalChart

    var body: some View {
        TabView {
            TodayView(chart: chart)
                .tabItem { Label("Today", systemImage: "moon.stars.fill") }
            ChartView(chart: chart)
                .tabItem { Label("Chart", systemImage: "circle.hexagongrid") }
            SettingsView()
                .tabItem { Label("You", systemImage: "sparkles") }
            // Phase 2: CycleView  |  Phase 3: CompatibilityView, LifeAreasView
        }
        .tint(Theme.gold)
        .background(Theme.void)
    }
}
