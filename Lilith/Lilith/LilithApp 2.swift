import SwiftUI

@main
struct LilithApp: App {
    // Birth data persisted as JSON in UserDefaults for the MVP.
    // Move to SwiftData when CycleEntry arrives in Phase 2.
    @AppStorage("birthData") private var birthDataJSON: String = ""

    var body: some Scene {
        WindowGroup {
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
