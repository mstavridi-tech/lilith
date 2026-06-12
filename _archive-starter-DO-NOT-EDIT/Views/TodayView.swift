import SwiftUI

/// The home screen and the product: today's reading, designed to be screenshotted.
struct TodayView: View {
    let chart: NatalChart
    @State private var horoscope: HoroscopeService.HoroscopeResponse?
    @State private var moonPhase: MoonPhase?

    var body: some View {
        ZStack {
            Theme.void.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    if let h = horoscope { dailyCard(h) } else { loadingState }
                    moonStrip
                }
                .padding(24)
            }
            .refreshable { await load() }
        }
        .task { await load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Date().formatted(.dateTime.weekday(.wide).day().month(.wide)).uppercased())
                .font(Theme.mono(13)).foregroundStyle(Theme.gold)
            Text(chart.bigThree.uppercased())
                .font(Theme.display(22)).foregroundStyle(Theme.bone)
        }
    }

    /// The screenshot-bait card. 4:5-safe, wordmark at the bottom = every share is an ad.
    private func dailyCard(_ h: HoroscopeService.HoroscopeResponse) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(h.headline)
                .font(Theme.display(28)).foregroundStyle(Theme.bone)
            Text(h.reading)
                .font(Theme.body()).foregroundStyle(Theme.bone.opacity(0.85))
                .lineSpacing(6)
            Divider().background(Theme.gold.opacity(0.3))
            Text(h.affirmation)
                .font(Theme.body(15)).italic().foregroundStyle(Theme.ember)
            Text("LILITH")
                .font(Theme.mono(11)).foregroundStyle(Theme.gold.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .lilithCard()
    }

    private var loadingState: some View {
        Text("CONSULTING THE SKY…")
            .font(Theme.display(20)).foregroundStyle(Theme.bone.opacity(0.4))
            .frame(maxWidth: .infinity).padding(.vertical, 60)
            .lilithCard()
    }

    private var moonStrip: some View {
        HStack {
            Text("☽").font(Theme.display(28)).foregroundStyle(Theme.ember)
            VStack(alignment: .leading, spacing: 2) {
                Text(moonPhase?.rawValue.uppercased() ?? "—")
                    .font(Theme.mono(14)).foregroundStyle(Theme.bone)
                Text("Tap for what this means for you") // Phase 1.1: moon detail sheet
                    .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.5))
            }
            Spacer()
        }
        .lilithCard()
    }

    private func load() async {
        moonPhase = try? ChartEngine.moonPhase()
        horoscope = try? await HoroscopeService.fetchDaily(chart: chart)
    }
}
