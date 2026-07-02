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

/// The title card. An ember aura blooms up out of the void first, then the LILITH wordmark rises
/// into it, holds a beat, and signals it's done. Slow and weighty, never a bounce (docs/03, docs/08).
struct LaunchRitual: View {
    var onDone: () -> Void
    @State private var auraIn = false
    @State private var wordmarkIn = false

    var body: some View {
        ZStack {
            Theme.void.ignoresSafeArea()

            // The aura: a warm ember bloom that swells up and brightens out of the dark.
            RadialGradient(
                colors: [Theme.ember.opacity(0.45), Theme.ember.opacity(0.12), .clear],
                center: .center, startRadius: 0, endRadius: 360)
                .scaleEffect(auraIn ? 1.0 : 0.5)
                .opacity(auraIn ? 1 : 0)
                .blur(radius: 6)
                .ignoresSafeArea()

            Text("LILITH")
                .font(Theme.display(34).weight(.medium))
                .tracking(Theme.tracking(34, em: 0.5))
                .foregroundStyle(Theme.bone.opacity(0.95))
                .padding(.leading, Theme.tracking(34, em: 0.5)) // recenter the wide tracking
                .opacity(wordmarkIn ? 1 : 0)
                .scaleEffect(wordmarkIn ? 1 : 0.97)

            GrainOverlay()
        }
        .task {
            withAnimation(.easeOut(duration: 1.3)) { auraIn = true }     // aura blooms first
            try? await Task.sleep(nanoseconds: 850_000_000)
            withAnimation(.easeOut(duration: 2.0)) { wordmarkIn = true } // then the name fades in, slow
            try? await Task.sleep(nanoseconds: 2_500_000_000)            // let it finish, then hold a beat
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
            CycleView()
                .tabItem { Label("Cycle", systemImage: "drop.fill") }
            ChartView(chart: chart)
                .tabItem { Label("Chart", systemImage: "circle.hexagongrid") }
            SettingsView()
                .tabItem { Label("You", systemImage: "sparkles") }
            // Phase 3: CompatibilityView, LifeAreasView
        }
        .tint(Theme.gold)
        .background(Theme.void)
    }
}
