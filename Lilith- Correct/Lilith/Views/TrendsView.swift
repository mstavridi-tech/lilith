import SwiftUI
import Charts

/// TRENDS (July 4, 2026): the graph page Maria loved in the Kimi reference, rebuilt on data we
/// actually have. The composite chart plots her logged mood, the computed vibe level (cycle +
/// moon), and the moon's illumination as a soft wash behind everything, with her bleed days and
/// symptom load as small bars along the floor. Below it: the averages rows, the key-stats grid,
/// and one pattern insight in voice. All local math; nothing here touches the network.
struct TrendsView: View {
    @ObservedObject private var store = CycleStore.shared
    @State private var points: [DayPoint] = []
    @State private var developToken = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header.cascadeIn(0, trigger: developToken)
                chartCard.cascadeIn(1, trigger: developToken)
                averagesSection.cascadeIn(2, trigger: developToken)
                keyStatsSection.cascadeIn(3, trigger: developToken)
                insightCard.cascadeIn(4, trigger: developToken)
                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 120) // clears the floating tab bar
        }
        .scrollIndicators(.hidden)
        .auraScreen(.gold) // champagne silk; the data carries the color, the ground carries the lux
        .onAppear {
            if points.isEmpty { points = Self.buildPoints(entries: store.entries) }
            if developToken == 0 { developToken = 1 }
        }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("YOUR PATTERNS").displayCaps(30, em: 0.12)
            Text("The receipts, drawn. Last 30 days.")
                .font(Theme.body(14).italic())
                .foregroundStyle(Theme.textSecondary)
        }
    }

    // MARK: The composite chart

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Chart {
                // The moon: a soft wash behind everything, the sky she lives under.
                ForEach(points) { p in
                    AreaMark(x: .value("Day", p.date), y: .value("Moon", p.moon),
                             series: .value("Series", "MOON"))
                        .foregroundStyle(Theme.gold.opacity(0.07))
                        .interpolationMethod(.catmullRom)
                }
                // The vibe: our computed cycle + moon estimate, always drawable.
                ForEach(points) { p in
                    LineMark(x: .value("Day", p.date), y: .value("Vibe", p.vibe),
                             series: .value("Series", "VIBE"))
                        .foregroundStyle(Theme.gold.opacity(0.85))
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)
                }
                // Her mood, only where she logged one. The line SHE draws.
                ForEach(points.filter { $0.mood != nil }) { p in
                    LineMark(x: .value("Day", p.date), y: .value("Mood", p.mood ?? 0),
                             series: .value("Series", "MOOD"))
                        .foregroundStyle(CyclePhase.follicular.aura)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)
                    PointMark(x: .value("Day", p.date), y: .value("Mood", p.mood ?? 0))
                        .foregroundStyle(CyclePhase.follicular.aura)
                        .symbolSize(22)
                }
                // Bleed days and symptom load: small honest bars along the floor.
                ForEach(points.filter(\.bleeding)) { p in
                    BarMark(x: .value("Day", p.date), y: .value("Bleed", 7), width: 3)
                        .foregroundStyle(Theme.blood.opacity(0.75))
                }
                ForEach(points.filter { $0.symptomLoad > 0 && !$0.bleeding }) { p in
                    BarMark(x: .value("Day", p.date), y: .value("Load", p.symptomLoad * 4), width: 3)
                        .foregroundStyle(Theme.ember.opacity(0.45))
                }
            }
            .chartYScale(domain: 0...100)
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        .font(Theme.label(8.5))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            .frame(height: 200)

            legend
        }
        .softCard(padding: 20)
        .padding(.top, 22)
    }

    private var legend: some View {
        HStack(spacing: 14) {
            legendDot(Theme.gold, "VIBE")
            legendDot(CyclePhase.follicular.aura, "MOOD")
            legendDot(Theme.blood, "BLEED")
            legendDot(Theme.ember.opacity(0.6), "SYMPTOMS")
            legendDot(Theme.gold.opacity(0.25), "MOON")
        }
    }

    private func legendDot(_ color: Color, _ label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 5, height: 5)
            Text(label)
                .font(Theme.label(8))
                .tracking(0.8)
                .foregroundStyle(Theme.textTertiary)
        }
    }

    // MARK: The averages (Kimi's "System averages" rows, on real numbers)

    private var averagesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("THE AVERAGES")
            VStack(alignment: .leading, spacing: 14) {
                averageRow("MOOD", value: stats.avgMood, denom: 100,
                           display: stats.moodCount == 0 ? "—" : "\(Int(stats.avgMood))",
                           color: CyclePhase.follicular.aura)
                averageRow("VIBE", value: stats.avgVibe, denom: 100,
                           display: "\(Int(stats.avgVibe))", color: Theme.gold)
                averageRow("SYMPTOM DAYS", value: Double(stats.symptomDays), denom: 30,
                           display: "\(stats.symptomDays)", color: Theme.ember)
                averageRow("BLEED DAYS", value: Double(stats.bleedDays), denom: 30,
                           display: "\(stats.bleedDays)", color: Theme.blood)
            }
            .softCard(padding: 20) // glass under the rows so the bars never fight the glow (July 4)
        }
        .padding(.top, 32)
    }

    private func averageRow(_ label: String, value: Double, denom: Double,
                            display: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack {
                HStack(spacing: 7) {
                    Circle().fill(color).frame(width: 5, height: 5)
                    Text(label)
                        .font(Theme.label(10))
                        .tracking(1.0)
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
                Text(display)
                    .font(Theme.data(16))
                    .foregroundStyle(Theme.textPrimary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Theme.bone.opacity(0.07))
                    Capsule().fill(color.opacity(0.75))
                        .frame(width: max(3, geo.size.width * min(1, value / denom)))
                }
            }
            .frame(height: 3)
        }
    }

    // MARK: Key stats (Kimi's grid: Highest / Lowest / Best day / Trend)

    private var keyStatsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("KEY STATS")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())],
                      spacing: 12) {
                statCard("HIGHEST", value: "\(Int(stats.highest.vibe))", sub: Self.shortDay.string(from: stats.highest.date).uppercased())
                statCard("LOWEST", value: "\(Int(stats.lowest.vibe))", sub: Self.shortDay.string(from: stats.lowest.date).uppercased())
                statCard("BEST DAY", value: stats.bestWeekday, sub: "ON AVERAGE")
                statCard("TREND", value: stats.trendWord, sub: stats.trendDetail)
            }
        }
        .padding(.top, 32)
    }

    private func statCard(_ label: String, value: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(Theme.label(9))
                .tracking(1.2)
                .foregroundStyle(Theme.textTertiary)
            Text(value)
                .font(value.count > 4 ? Theme.display(20).weight(.medium) : Theme.data(26))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(sub)
                .font(Theme.label(8.5))
                .tracking(0.8)
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(padding: 16)
    }

    // MARK: The insight (one pattern, in voice, honest about thin data)

    private var insightCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("✶")
                .font(Theme.display(15))
                .foregroundStyle(Theme.gold)
            Text(insightLine)
                .font(Theme.body(14.5))
                .foregroundStyle(Theme.bone.opacity(0.88))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard(padding: 20)
        .padding(.top, 32)
    }

    private var insightLine: String {
        if stats.moodCount < 5 {
            return "Log a few more moods and I'll start pulling receipts. Patterns need ingredients, babe."
        }
        if stats.lutealDip {
            return "Your mood consistently dips in the days before your period. That's not a character flaw, that's progesterone. Plan soft days there and guard them like appointments."
        }
        if stats.trendWord == "RISING" {
            return "Your month is trending up and the data agrees with your delulu. Keep doing whatever this is."
        }
        return "No big pattern jumping out this month. Sometimes stability IS the plot twist."
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.label(10))
            .tracking(1.4)
            .foregroundStyle(Theme.gold.opacity(0.8))
    }

    private static let shortDay: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "d MMM"; return f
    }()

    // MARK: Data

    struct DayPoint: Identifiable {
        let date: Date
        let vibe: Double      // 0...100, computed cycle + moon estimate
        let moon: Double      // 0...100, illumination
        let mood: Double?     // 0...100 where logged
        let symptomLoad: Int  // count of logged symptoms
        let bleeding: Bool
        var id: Date { date }
    }

    /// Mood words to plot height. Not clinical, just relative: radiant up top, low at the floor,
    /// wired in the jangly middle.
    static func moodScore(_ mood: CycleMood) -> Double {
        switch mood {
        case .radiant: 92
        case .good: 75
        case .wired: 58
        case .meh: 50
        case .tender: 34
        case .low: 20
        }
    }

    /// The last 30 days, oldest first. Ephemeris math runs once per appearance, never per frame.
    static func buildPoints(entries: [CycleEntry], today: Date = Date()) -> [DayPoint] {
        let cal = Calendar.current
        let start = cal.startOfDay(for: today)
        return (0..<30).reversed().compactMap { back in
            guard let date = cal.date(byAdding: .day, value: -back, to: start) else { return nil }
            let entry = entries.first { cal.startOfDay(for: $0.date) == date }
            let state = CycleMath.state(entries: entries, on: date)
            let elongation = (try? ChartEngine.moonElongation(at: date)) ?? 180
            let illum = (1 - cos(elongation * .pi / 180)) / 2
            let phase = (try? ChartEngine.moonPhase(at: date)) ?? .fullMoon
            let vibe = VibeCheck.vibe(cycle: state?.phase, moon: phase, illumination: illum).level
            return DayPoint(
                date: date,
                vibe: vibe * 100,
                moon: illum * 100,
                mood: entry?.mood.map(moodScore),
                symptomLoad: entry?.symptoms.count ?? 0,
                bleeding: entry?.isBleeding ?? false)
        }
    }

    // MARK: Stats over the window

    private struct Stats {
        var avgMood: Double = 0
        var moodCount: Int = 0
        var avgVibe: Double = 0
        var symptomDays: Int = 0
        var bleedDays: Int = 0
        var highest: (vibe: Double, date: Date) = (0, Date())
        var lowest: (vibe: Double, date: Date) = (0, Date())
        var bestWeekday: String = "—"
        var trendWord: String = "HOLDING"
        var trendDetail: String = "THIS MONTH"
        var lutealDip: Bool = false
    }

    private var stats: Stats {
        var s = Stats()
        guard !points.isEmpty else { return s }

        let moods = points.compactMap(\.mood)
        s.moodCount = moods.count
        s.avgMood = moods.isEmpty ? 0 : moods.reduce(0, +) / Double(moods.count)
        s.avgVibe = points.map(\.vibe).reduce(0, +) / Double(points.count)
        s.symptomDays = points.filter { $0.symptomLoad > 0 }.count
        s.bleedDays = points.filter(\.bleeding).count

        // Highest and lowest days go by mood where she logged it, vibe otherwise.
        let scored = points.map { (v: $0.mood ?? $0.vibe, d: $0.date) }
        if let hi = scored.max(by: { $0.v < $1.v }) { s.highest = (hi.v, hi.d) }
        if let lo = scored.min(by: { $0.v < $1.v }) { s.lowest = (lo.v, lo.d) }

        // Best weekday by average of the same blend.
        let cal = Calendar.current
        var byDay: [Int: [Double]] = [:]
        for p in points { byDay[cal.component(.weekday, from: p.date), default: []].append(p.mood ?? p.vibe) }
        if let best = byDay.max(by: { $0.value.reduce(0, +) / Double($0.value.count) < $1.value.reduce(0, +) / Double($1.value.count) }) {
            s.bestWeekday = cal.weekdaySymbols[best.key - 1]
        }

        // Trend: back half of the window against the front half.
        let half = points.count / 2
        let first = points.prefix(half).map { $0.mood ?? $0.vibe }
        let second = points.suffix(points.count - half).map { $0.mood ?? $0.vibe }
        let a = first.reduce(0, +) / Double(max(1, first.count))
        let b = second.reduce(0, +) / Double(max(1, second.count))
        let delta = b - a
        if delta > 5 { s.trendWord = "RISING"; s.trendDetail = String(format: "+%.0f%% THIS MONTH", delta) }
        else if delta < -5 { s.trendWord = "SOFTENING"; s.trendDetail = String(format: "%.0f%% THIS MONTH", delta) }

        // The luteal dip: logged moods in the 5 days before a bleed run, against all the others.
        let bleedDates = Set(points.filter(\.bleeding).map(\.date))
        var pre: [Double] = [], rest: [Double] = []
        for p in points {
            guard let mood = p.mood else { continue }
            let isPre = (1...5).contains { off in
                guard let d = cal.date(byAdding: .day, value: off, to: p.date) else { return false }
                return bleedDates.contains(d)
            }
            isPre ? pre.append(mood) : rest.append(mood)
        }
        if pre.count >= 2 && rest.count >= 2 {
            s.lutealDip = (pre.reduce(0, +) / Double(pre.count)) < (rest.reduce(0, +) / Double(rest.count)) - 8
        }
        return s
    }
}
