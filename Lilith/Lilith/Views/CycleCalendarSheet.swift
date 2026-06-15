import SwiftUI

/// The calendar that pops out from the Cycle tab (Maria's brief): her logged and predicted periods,
/// the moon cycle, and what's coming, including guideline-based care nudges. Tap any day to log it.
/// Rises as the same dark glass as the readings. Everything here is computed on-device.
struct CycleCalendarSheet: View {
    let store: CycleStore
    @Environment(\.dismiss) private var dismiss

    @State private var monthAnchor = Calendar.current.startOfMonth(for: Date())
    @State private var logDay: LogDay?

    private let cal = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("YOUR CALENDAR")
                    .displayCaps(26, em: 0.16)
                    .padding(.leading, Theme.tracking(26, em: 0.16))
                    .padding(.top, 44)

                monthHeader.padding(.top, 26)
                weekdayRow.padding(.top, 16)
                grid.padding(.top, 6)
                legend.padding(.top, 18)

                HairlineDivider(width: 120).padding(.top, 28)

                whatsComing.padding(.top, 24)
                careReminders.padding(.top, 28)
                disclaimer.padding(.top, 26)

                Wordmark().padding(.top, 40)
            }
            .padding(.horizontal, 26)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: "☾", accent: Theme.blood)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
        .sheet(item: $logDay) { pick in
            CycleLogSheet(date: pick.date, store: store)
        }
    }

    // MARK: Month header

    private var monthHeader: some View {
        HStack {
            chevron("chevron.left") { shiftMonth(-1) }
            Spacer()
            Text(Self.monthTitle.string(from: monthAnchor).uppercased())
                .font(Theme.mono(13)).tracking(Theme.tracking(13, em: 0.2))
                .foregroundStyle(Theme.bone)
            Spacer()
            chevron("chevron.right") { shiftMonth(1) }
        }
    }

    private func chevron(_ name: String, _ action: @escaping () -> Void) -> some View {
        Button { Haptics.light(); action() } label: {
            Image(systemName: name)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Theme.gold)
                .frame(width: 40, height: 30)
        }
        .buttonStyle(.plain)
    }

    private var weekdayRow: some View {
        HStack(spacing: 6) {
            ForEach(Self.weekdaySymbols, id: \.self) { s in
                Text(s)
                    .font(Theme.mono(9)).tracking(Theme.tracking(9, em: 0.1))
                    .foregroundStyle(Theme.bone.opacity(0.4))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: The grid

    private var grid: some View {
        let days = monthDays()
        let predicted = predictedPeriodDays()
        let fertile = fertileDays()
        let ovulation = ovulationDays()
        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                if let day {
                    dayCell(day, predicted: predicted, fertile: fertile, ovulation: ovulation)
                } else {
                    Color.clear.frame(height: 46)
                }
            }
        }
    }

    private func dayCell(_ date: Date, predicted: Set<Date>, fertile: Set<Date>, ovulation: Set<Date>) -> some View {
        let d = cal.startOfDay(for: date)
        let isToday = cal.isDateInToday(d)
        let isPeriod = store.entry(on: d)?.isBleeding ?? false
        let isPredicted = predicted.contains(d)
        let isFertile = fertile.contains(d)
        let isOvulation = ovulation.contains(d)

        return Button {
            Haptics.light()
            logDay = LogDay(date: d)
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    if isPeriod {
                        Circle().fill(Theme.blood)
                    } else if isPredicted {
                        Circle().strokeBorder(Theme.blood.opacity(0.6),
                                              style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                    } else if isFertile {
                        // the whole fertile window glows ember, the ovulation peak brightest
                        Circle().fill(Theme.ember.opacity(isOvulation ? 0.30 : 0.14))
                        Circle().strokeBorder(Theme.ember.opacity(isOvulation ? 0.95 : 0.45),
                                              lineWidth: isOvulation ? 1.5 : 1)
                    }
                    if isToday {
                        Circle().strokeBorder(Theme.gold.opacity(0.85), lineWidth: 1)
                    }
                    Text("\(cal.component(.day, from: d))")
                        .font(Theme.mono(12))
                        .foregroundStyle(isPeriod ? Theme.bone : Theme.bone.opacity(0.8))
                }
                .frame(width: 30, height: 30)

                // the moon cycle, marked on every day
                moonMark(d).frame(height: 10)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    /// The moon phase on every day, so the whole lunar cycle reads across the month.
    @ViewBuilder private func moonMark(_ date: Date) -> some View {
        if let phase = try? ChartEngine.moonPhase(at: date) {
            let strong = phase == .fullMoon || phase == .newMoon
            Image(systemName: CycleView.moonSymbol(phase))
                .font(.system(size: 9))
                .foregroundStyle(Theme.bone.opacity(strong ? 0.85 : 0.45))
        } else {
            EmptyView()
        }
    }

    private var legend: some View {
        HStack(spacing: 14) {
            legendItem("PERIOD") { Circle().fill(Theme.blood) }
            legendItem("PREDICTED") {
                Circle().strokeBorder(Theme.blood.opacity(0.7), style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
            }
            legendItem("FERTILE") { Circle().strokeBorder(Theme.ember.opacity(0.8), lineWidth: 1) }
            legendItem("MOON") {
                Image(systemName: "moonphase.full.moon").font(.system(size: 7))
                    .foregroundStyle(Theme.bone.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func legendItem<S: View>(_ label: String, @ViewBuilder swatch: () -> S) -> some View {
        HStack(spacing: 5) {
            swatch().frame(width: 8, height: 8)
            Text(label).font(Theme.mono(8)).tracking(Theme.tracking(8, em: 0.08))
                .foregroundStyle(Theme.bone.opacity(0.55))
        }
    }

    // MARK: What's coming

    private var whatsComing: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WHAT'S COMING")
                .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
                .foregroundStyle(Theme.ember)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let next = nextPeriodDate() {
                comingRow("Next period", Self.longDate.string(from: next))
            }
            if let ov = nextOvulationDate() {
                comingRow("Fertile window peak", Self.longDate.string(from: ov))
            }
            if nextPeriodDate() == nil {
                Text("Log a period and I'll start predicting the rest.")
                    .font(Theme.body(14)).foregroundStyle(Theme.bone.opacity(0.7))
            }
        }
    }

    private func comingRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.85))
            Spacer()
            Text(value).font(Theme.mono(11)).foregroundStyle(Theme.gold.opacity(0.85))
        }
    }

    // MARK: Care reminders (guideline-based nudges, never diagnosis)

    private var careReminders: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("WORTH A REMINDER")
                .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
                .foregroundStyle(Theme.ember)

            careRow("Cervical screening (pap smear)",
                    "Guidelines vary by country, often every 3 to 5 years from your early twenties. Ask your provider when yours is due.")
            careRow("STI check",
                    "Worth one with any new partner, and a routine one now and then regardless.")
            careRow("Breast self-check",
                    "A quick monthly feel, ideally just after your period. You're learning your normal, not diagnosing.")
        }
    }

    private func careRow(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.9))
            Text(body).font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.62)).lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private var disclaimer: some View {
        Text("These are general screening guidelines, not personal medical advice, and they vary by country and history. Your provider sets your real schedule.")
            .font(Theme.body(12)).foregroundStyle(Theme.gold.opacity(0.7))
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 16).padding(.horizontal, 16)
            .overlay(Rectangle().fill(Theme.gold.opacity(0.4)).frame(width: 0.5), alignment: .leading)
    }

    // MARK: Date math

    private func shiftMonth(_ delta: Int) {
        if let m = cal.date(byAdding: .month, value: delta, to: monthAnchor) {
            monthAnchor = cal.startOfMonth(for: m)
        }
    }

    /// The cells for the visible month: leading blanks (nil) then each day.
    private func monthDays() -> [Date?] {
        guard let range = cal.range(of: .day, in: .month, for: monthAnchor) else { return [] }
        let firstWeekday = cal.component(.weekday, from: monthAnchor)
        let leading = (firstWeekday - cal.firstWeekday + 7) % 7
        var cells: [Date?] = Array(repeating: nil, count: leading)
        for d in range {
            if let date = cal.date(byAdding: .day, value: d - 1, to: monthAnchor) {
                cells.append(date)
            }
        }
        return cells
    }

    private var lastStart: Date? { CycleMath.periodStarts(store.entries).last }
    private var length: Int { CycleMath.averageLength(CycleMath.periodStarts(store.entries)) }

    /// Predicted period days (start plus the typical 5-day span) for upcoming cycles.
    private func predictedPeriodDays() -> Set<Date> {
        guard let start = lastStart else { return [] }
        let span = CycleMath.averagePeriodLength(store.entries) // her learned bleed length
        var set: Set<Date> = []
        for k in 1...13 {
            guard let s = cal.date(byAdding: .day, value: k * length, to: start) else { continue }
            for offset in 0..<span {
                if let d = cal.date(byAdding: .day, value: offset, to: s) {
                    set.insert(cal.startOfDay(for: d))
                }
            }
        }
        return set
    }

    private func ovulationDays() -> Set<Date> {
        guard let start = lastStart else { return [] }
        let ov = CycleMath.ovulationDay(length: length)
        var set: Set<Date> = []
        for k in 0...13 {
            if let d = cal.date(byAdding: .day, value: k * length + ov - 1, to: start) {
                set.insert(cal.startOfDay(for: d))
            }
        }
        return set
    }

    /// The fertile window: the few days leading into ovulation plus the day after, for each cycle.
    private func fertileDays() -> Set<Date> {
        guard let start = lastStart else { return [] }
        let ov = CycleMath.ovulationDay(length: length)
        var set: Set<Date> = []
        for k in 0...13 {
            for offset in -3...1 {
                if let d = cal.date(byAdding: .day, value: k * length + ov - 1 + offset, to: start) {
                    set.insert(cal.startOfDay(for: d))
                }
            }
        }
        return set
    }

    private func nextPeriodDate() -> Date? {
        guard let start = lastStart else { return nil }
        let today = cal.startOfDay(for: Date())
        for k in 1...13 {
            if let d = cal.date(byAdding: .day, value: k * length, to: start), d >= today {
                return cal.startOfDay(for: d)
            }
        }
        return nil
    }

    private func nextOvulationDate() -> Date? {
        guard let start = lastStart else { return nil }
        let ov = CycleMath.ovulationDay(length: length)
        let today = cal.startOfDay(for: Date())
        for k in 0...13 {
            if let d = cal.date(byAdding: .day, value: k * length + ov - 1, to: start), d >= today {
                return cal.startOfDay(for: d)
            }
        }
        return nil
    }

    // MARK: Formatters / statics

    struct LogDay: Identifiable { let date: Date; var id: Double { date.timeIntervalSince1970 } }

    private static let monthTitle: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; return f
    }()
    private static let longDate: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "EEE d MMM"; return f
    }()
    private static let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
}

extension Calendar {
    /// First day of the month containing `date`.
    func startOfMonth(for date: Date) -> Date {
        self.date(from: dateComponents([.year, .month], from: date)) ?? startOfDay(for: date)
    }
}
