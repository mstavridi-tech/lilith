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
                // July 4 late round (Maria: "super ugly, too AI"): the dashboard grammar is gone.
                // Voice leads, the one line follows, and the numbers read as an editorial list
                // instead of boxed widgets. Boxes are what every AI dashboard looks like.
                header.cascadeIn(0, trigger: developToken)
                insightCard.cascadeIn(1, trigger: developToken)
                chartCard.cascadeIn(2, trigger: developToken)
                receiptsSection.cascadeIn(3, trigger: developToken)
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

    /// REDONE July 4 evening (Maria: "trends graph kills me i hate it"). The five-series pileup
    /// (moon wash + vibe line + mood line + two kinds of bars) is gone. Now it's one calm gold
    /// line: her month, drawn once, with a soft light pooled under it. Moods she logged sit on
    /// the line as jewels, bleed days rest on the floor as wine dots. Nothing else competes.
    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("THE SHAPE OF YOUR MONTH")
                .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.24))
                .foregroundStyle(Theme.ember)
            let curve = Self.smoothedVibe(points)
            Chart {
                // The line: the cycle + moon estimate, smoothed over a five-day window for the
                // drawing only. The raw vibe moves in plateaus (phases and moon octants are
                // discrete), and the resulting cliffs were the ugliness (July 4 evening). Her
                // logged moods sit AGAINST the line as dots, never spliced into it.
                ForEach(Array(curve.enumerated()), id: \.offset) { _, p in
                    AreaMark(x: .value("Day", p.date), y: .value("Level", p.value))
                        .foregroundStyle(
                            LinearGradient(colors: [Theme.gold.opacity(0.22), .clear],
                                           startPoint: .top, endPoint: .bottom))
                        .interpolationMethod(.catmullRom)
                    LineMark(x: .value("Day", p.date), y: .value("Level", p.value))
                        .foregroundStyle(Theme.gold)
                        .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .interpolationMethod(.catmullRom)
                }
                // Her logged moods, sitting on the line as the receipts.
                ForEach(points.filter { $0.mood != nil }) { p in
                    PointMark(x: .value("Day", p.date), y: .value("Level", p.mood ?? 0))
                        .foregroundStyle(Theme.bone)
                        .symbolSize(34)
                }
                // Bleed days: quiet wine dots along the floor, not bars stabbing the line.
                ForEach(points.filter(\.bleeding)) { p in
                    PointMark(x: .value("Day", p.date), y: .value("Level", 3))
                        .foregroundStyle(Theme.blood.opacity(0.9))
                        .symbolSize(22)
                }
            }
            .chartYScale(domain: 0...100)
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                    AxisGridLine().foregroundStyle(Theme.bone.opacity(0.06))
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        .font(Theme.label(9))
                        .foregroundStyle(Theme.textTertiary)
                }
            }
            .frame(height: 210)

            legend
        }
        .softCard(padding: 22)
        .padding(.top, 22)
    }

    private var legend: some View {
        HStack(spacing: 14) {
            legendDot(Theme.gold, "THE VIBE")
            legendDot(Theme.bone, "YOUR MOOD")
            legendDot(Theme.blood, "BLEED")
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

    // MARK: The receipts (editorial rows, no boxes: a ledger, not a dashboard)

    private var receiptsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HairlineDivider(width: 110)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 18)
            Text("THE RECEIPTS").displayCaps(20, em: 0.16)
                .padding(.bottom, 6)

            receiptRow("YOUR AVERAGE MOOD",
                       stats.moodCount == 0 ? "no logs yet" : "\(Int(stats.avgMood)) of 100",
                       accent: CyclePhase.follicular.aura)
            hairline
            receiptRow("THE VIBE, AVERAGED", "\(Int(stats.avgVibe)) of 100", accent: Theme.gold)
            hairline
            receiptRow("DAYS YOU BLED", "\(stats.bleedDays)", accent: Theme.blood)
            hairline
            receiptRow("DAYS WITH SYMPTOMS", "\(stats.symptomDays)", accent: Theme.ember)
            hairline
            receiptRow("YOUR BEST DAY", stats.bestWeekday, accent: Theme.gold)
            hairline
            receiptRow("THE MONTH IS", stats.trendWord.lowercased(), accent: Theme.gold,
                       detail: stats.trendDetail.lowercased())
        }
        .padding(.top, 34)
        .shadow(color: .black.opacity(0.35), radius: 8, y: 1) // ledger sits straight on the plate
    }

    private var hairline: some View {
        Rectangle().fill(Theme.gold.opacity(0.14)).frame(height: 0.5)
    }

    private func receiptRow(_ label: String, _ value: String, accent: Color,
                            detail: String? = nil) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.16))
                .foregroundStyle(Theme.bone.opacity(0.6))
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(Theme.display(21).weight(.medium))
                    .foregroundStyle(Theme.bone)
                if let detail {
                    Text(detail)
                        .font(Theme.body(12).italic())
                        .foregroundStyle(accent.opacity(0.85))
                }
            }
        }
        .padding(.vertical, 15)
    }

    // MARK: The insight (voice first: the friend speaks before the numbers do)

    private var insightCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("✶")
                .font(Theme.display(16))
                .foregroundStyle(Theme.gold)
            Text(insightLine)
                .font(Theme.body(16).italic())
                .foregroundStyle(Theme.bone.opacity(0.92))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 24)
        .shadow(color: .black.opacity(0.4), radius: 8, y: 1)
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

    private static let shortDay: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "d MMM"; return f
    }()

    /// The vibe series with a centered, weighted five-day average, display only. Stats and
    /// averages stay on the raw values; this exists purely so the line flows instead of stepping.
    static func smoothedVibe(_ points: [DayPoint]) -> [(date: Date, value: Double)] {
        let weights: [Double] = [1, 2, 3, 2, 1]
        return points.indices.map { i in
            var total = 0.0, weightSum = 0.0
            for (k, w) in weights.enumerated() {
                let j = i + k - 2
                guard points.indices.contains(j) else { continue }
                total += points[j].vibe * w
                weightSum += w
            }
            return (points[i].date, total / max(1, weightSum))
        }
    }

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
