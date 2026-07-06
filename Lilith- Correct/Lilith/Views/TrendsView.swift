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
    @State private var showFriends = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // July 5 rebuild (Maria: "the whole page doesn't make sense to me"). Every section
                // now answers one plain question, stated in its own subtitle: how was the month
                // (strip), how does each era treat you (eras), what are the exact numbers
                // (receipts). The line graph is gone; the strip is the same visual language as
                // THE SKY OVER YOUR CYCLE, which she already reads fluently.
                header.cascadeIn(0, trigger: developToken)
                insightCard.cascadeIn(1, trigger: developToken)
                monthStrip.cascadeIn(2, trigger: developToken)
                erasSection.cascadeIn(3, trigger: developToken)
                receiptsSection.cascadeIn(4, trigger: developToken)
                friendsDoor.cascadeIn(5, trigger: developToken)
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

    /// The month as thirty little days, colored by era, same language as THE SKY OVER YOUR CYCLE.
    /// A bone dot on a day = she logged a mood (higher dot = better day). Wine cap = she bled.
    private var monthStrip: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR LAST 30 DAYS")
                .font(Theme.control(10)).tracking(1.1)
                .foregroundStyle(Theme.ember)
            Text("One bar per day, colored by which era you were in. Dots are moods you logged, higher is better. Wine at the base means you bled.")
                .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .bottom, spacing: 3.5) {
                ForEach(points) { p in dayBar(p) }
            }
            .frame(height: 88)
            .padding(.top, 6)

            HStack {
                Text(Self.shortDay.string(from: points.first?.date ?? Date()).uppercased())
                Spacer()
                Text("TODAY")
            }
            .font(Theme.mono(8)).tracking(Theme.tracking(8, em: 0.14))
            .foregroundStyle(Theme.bone.opacity(0.45))

            HStack(spacing: 12) {
                ForEach(CyclePhase.allCases, id: \.self) { phase in
                    HStack(spacing: 4) {
                        Circle().fill(phase.aura).frame(width: 5, height: 5)
                        Text(phase.name)
                            .font(Theme.mono(7.5)).tracking(Theme.tracking(7.5, em: 0.1))
                            .foregroundStyle(Theme.bone.opacity(0.55))
                    }
                }
            }
            .padding(.top, 2)
        }
        .softCard(padding: 18)
        .padding(.top, 22)
    }

    private func dayBar(_ p: DayPoint) -> some View {
        let isToday = Calendar.current.isDateInToday(p.date)
        return ZStack(alignment: .bottom) {
            // the era bar
            RoundedRectangle(cornerRadius: 2.5)
                .fill((p.phase?.aura ?? Theme.bone).opacity(p.phase == nil ? 0.12 : 0.42))
            // bled that day: wine at the base
            if p.bleeding {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Theme.blood.opacity(0.95))
                    .frame(height: 16)
            }
            // logged mood: a bone dot, its height = how the day felt
            if let mood = p.mood {
                Circle()
                    .fill(Theme.bone)
                    .frame(width: 5, height: 5)
                    .offset(y: -CGFloat(8 + (mood / 100) * 64))
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .frame(maxWidth: .infinity)
        .overlay(
            RoundedRectangle(cornerRadius: 2.5)
                .strokeBorder(isToday ? Theme.gold : .clear, lineWidth: 1)
        )
    }

    /// How each era treats her, from her own logs. The four phases she lives through, one row
    /// each, average logged mood on the right. This is the sentence version of the old graph.
    private var erasSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HairlineDivider(width: 110)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 18)
            Text("HOW EACH ERA TREATS YOU").displayCaps(20, em: 0.14)
                .padding(.bottom, 2)
            Text("Your logged moods, averaged per phase. The more you log, the sharper this gets.")
                .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.6))
                .padding(.bottom, 8)

            ForEach(CyclePhase.allCases, id: \.self) { phase in
                if phase != CyclePhase.allCases.first {
                    Rectangle().fill(Theme.gold.opacity(0.12)).frame(height: 0.5)
                }
                eraRow(phase)
            }
        }
        .padding(.top, 34)
        .shadow(color: .black.opacity(0.35), radius: 8, y: 1)
    }

    private func eraRow(_ phase: CyclePhase) -> some View {
        let moods = points.filter { $0.phase == phase }.compactMap(\.mood)
        let avg = moods.isEmpty ? nil : moods.reduce(0, +) / Double(moods.count)
        return HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Circle().fill(phase.aura).frame(width: 6, height: 6)
                    Text(phase.name)
                        .font(Theme.control(11)).tracking(1.1)
                        .foregroundStyle(Theme.bone)
                }
                Text(phase.tagline)
                    .font(Theme.body(13).italic())
                    .foregroundStyle(Theme.bone.opacity(0.55))
                    .padding(.leading, 14)
            }
            Spacer()
            Text(avg.map { "\(Int($0)) of 100" } ?? "no logs yet")
                .font(avg == nil ? Theme.body(14).italic() : Theme.display(19).weight(.medium))
                .foregroundStyle(avg == nil ? Theme.bone.opacity(0.45) : Theme.bone)
        }
        .padding(.vertical, 14)
    }

    /// The Friends door: the vision, honestly gated until accounts exist.
    private var friendsDoor: some View {
        Button {
            Haptics.open(); showFriends = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "person.2")
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(Theme.gold)
                VStack(alignment: .leading, spacing: 4) {
                    Text("FRIENDS")
                        .font(Theme.control(11)).tracking(1.1)
                        .foregroundStyle(Theme.bone)
                    Text("Cycle-sync, moon twins, memes. Coming.")
                        .font(Theme.body(13).italic()).foregroundStyle(Theme.bone.opacity(0.6))
                }
                Spacer()
                Text("→").font(Theme.body(18)).foregroundStyle(Theme.gold)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Theme.gold.opacity(0.3), lineWidth: 0.5))
            )
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
        .padding(.top, 30)
        .sheet(isPresented: $showFriends) { FriendsTeaserSheet() }
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
                .font(Theme.control(10)).tracking(1.1)
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

    // MARK: Data

    struct DayPoint: Identifiable {
        let date: Date
        let vibe: Double      // 0...100, computed cycle + moon estimate
        let moon: Double      // 0...100, illumination
        let mood: Double?     // 0...100 where logged
        let symptomLoad: Int  // count of logged symptoms
        let bleeding: Bool
        var phase: CyclePhase? = nil // which era she was in that day, for the month strip
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
                bleeding: entry?.isBleeding ?? false,
                phase: state?.phase)
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

// MARK: - Friends (the honest teaser; the real thing needs accounts)

/// The vision page for Friends, so the door exists and the promise is public: cycle-sync, moon
/// twins, memes and gifs, and NEVER rankings. Actual friend data needs accounts and a backend,
/// which are blocked until the paid Apple Developer enrollment lands, and the page says so.
struct FriendsTeaserSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("FRIENDS")
                    .displayCaps(26, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(26, em: 0.14))
                    .padding(.top, 44)
                Text("The group chat, but it knows your cycles.")
                    .font(Theme.body(15).italic()).foregroundStyle(Theme.gold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)

                teaserRow("CYCLE-SYNC", "See whose luteal is colliding with whose main character week, so you know exactly why the group chat is like that today.")
                teaserRow("MOON TWINS", "Find out which of your girls shares your moon sign. Instant lore.")
                teaserRow("MEMES & GIFS", "Send the meme that says what words can't, straight from her trends to yours.")

                Text("This unlocks when LILITH gets accounts (the App Store version). Sharing will be opt-in per friend, and your logs stay yours; a friend only ever sees what you choose to show.")
                    .font(Theme.body(13)).foregroundStyle(Theme.gold.opacity(0.75))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 28)

                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 44)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: "", accent: Theme.gold)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.control(11)).tracking(1.1)
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
    }

    private func teaserRow(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Theme.control(10)).tracking(1.1)
                .foregroundStyle(Theme.ember)
            Text(body)
                .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.85))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 26)
    }
}
