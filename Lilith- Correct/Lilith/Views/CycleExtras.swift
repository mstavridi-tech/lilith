import SwiftUI
import Charts

// MARK: - The sky over your cycle (Maria's master list, July 4)
//
// The Stardust move, in LILITH's language: her whole current cycle laid out day by day with the
// real moon phase over each one, scrollable, landing on today. Moon phases are deterministic sky
// math from ChartEngine, so future days are fine to show; her bleed days are the only "her" data
// here and they never leave the phone.

/// One day of the strip, precomputed so the scroll stays smooth (SwiftAA runs once, not per frame).
struct MoonCycleDay: Identifiable {
    let id: Int          // cycle day, 1-based
    let date: Date
    let moon: MoonPhase
    let phase: CyclePhase
    let isToday: Bool
    let bled: Bool       // actually logged, not the average

    /// Build the full current cycle from the store's history. Empty when she isn't tracking yet.
    static func currentCycle(entries: [CycleEntry], state: CycleState?) -> [MoonCycleDay] {
        guard let state else { return [] }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let starts = CycleMath.periodStarts(entries).filter { $0 <= today }
        guard let lastStart = starts.last else { return [] }

        let spans = CycleMath.phaseRanges(length: state.cycleLength, periodLength: state.periodLength)
        func phase(of day: Int) -> CyclePhase {
            spans.first { $0.range.contains(day) }?.phase ?? .luteal
        }
        let bledDays = Set(entries.filter(\.isBleeding).map { cal.startOfDay(for: $0.date) })

        return (1...max(state.cycleDay, state.cycleLength)).compactMap { day in
            guard let date = cal.date(byAdding: .day, value: day - 1, to: lastStart) else { return nil }
            let moon = (try? ChartEngine.moonPhase(at: date)) ?? .fullMoon
            return MoonCycleDay(id: day, date: date, moon: moon, phase: phase(of: day),
                                isToday: date == today, bled: bledDays.contains(date))
        }
    }
}

/// The horizontal strip itself. Frosted chips, one per day: the moon that night, the day number,
/// and a blood dot on days she actually bled (logged, never assumed). Opens scrolled to today.
struct MoonCycleStrip: View {
    let days: [MoonCycleDay]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HairlineDivider(width: 110).frame(maxWidth: .infinity, alignment: .center)
            Text("THE SKY OVER YOUR CYCLE")
                .font(Theme.control(10)).tracking(1.1)
                .foregroundStyle(Theme.ember)
            Text("Every night of this cycle and the moon it wears. Dots are days you actually bled.")
                .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)

            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(days) { day in chip(day).id(day.id) }
                    }
                    .padding(.vertical, 2)
                }
                .scrollIndicators(.hidden)
                .onAppear {
                    if let today = days.first(where: \.isToday) {
                        proxy.scrollTo(today.id, anchor: .center)
                    }
                }
            }
        }
        .padding(.top, 30)
    }

    private func chip(_ day: MoonCycleDay) -> some View {
        VStack(spacing: 7) {
            Image(systemName: CycleView.moonSymbol(day.moon))
                .font(.system(size: 15, weight: .light))
                .foregroundStyle(day.isToday ? Theme.bone : Theme.bone.opacity(0.7))
            Text("\(day.id)")
                .font(Theme.data(15))
                .foregroundStyle(day.isToday ? Theme.bone : Theme.bone.opacity(0.75))
            Text(Self.dayMonth.string(from: day.date).uppercased())
                .font(Theme.mono(7.5)).tracking(Theme.tracking(7.5, em: 0.08))
                .foregroundStyle(Theme.bone.opacity(0.45))
            Circle()
                .fill(day.bled ? Theme.blood : .clear)
                .overlay(Circle().strokeBorder(day.phase.aura.opacity(day.bled ? 0 : 0.55), lineWidth: 1))
                .frame(width: 5, height: 5)
        }
        .frame(width: 52)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .fill(day.isToday ? day.phase.aura.opacity(0.20) : Theme.void.opacity(0.30)))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(day.isToday ? day.phase.aura.opacity(0.8) : Theme.bone.opacity(0.10),
                                  lineWidth: day.isToday ? 1 : 0.5))
        )
    }

    private static let dayMonth: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "d MMM"; return f
    }()
}

// MARK: - The textbook hormone curve (Maria's master list, July 4; scrubber July 4 late)
//
// Hormone literacy, drawn honestly: the CLASSIC estrogen / progesterone / LH shapes across a cycle
// of her length. This is education about what's typical, NEVER her measured levels (docs/01).
// July 4 late round (Maria): off the card, onto the page, and it moves. Drag anywhere on the plot
// and the readout tells you how that day of the cycle classically feels, in group-chat language,
// so the science lands without anyone needing to know what "luteal" means first.

struct HormoneCurveCard: View {
    let state: CycleState

    @State private var scrubDay: Int? = nil   // the day under her finger; nil = resting on today

    private var length: Int { state.cycleLength }
    private var ovulation: Int { CycleMath.ovulationDay(length: length) }

    /// A smooth bump: 1 at `center`, fading over `width` days. The whole curve vocabulary.
    private func bump(_ day: Double, center: Double, width: Double) -> Double {
        let z = (day - center) / width
        return exp(-z * z)
    }

    private func estrogen(_ d: Double) -> Double {
        let ov = Double(ovulation)
        return min(1, 0.12 + 0.80 * bump(d, center: ov - 1.5, width: 3.4)
                        + 0.34 * bump(d, center: ov + 7, width: 5))
    }
    private func progesterone(_ d: Double) -> Double {
        min(1, 0.07 + 0.85 * bump(d, center: Double(ovulation) + 7, width: 4.6))
    }
    private func lh(_ d: Double) -> Double {
        min(1, 0.08 + 0.90 * bump(d, center: Double(ovulation), width: 1.0))
    }

    private struct Sample: Identifiable {
        let id = UUID()
        let day: Double
        let value: Double
        let hormone: String
    }

    private var samples: [Sample] {
        stride(from: 1.0, through: Double(length), by: 0.5).flatMap { d in
            [Sample(day: d, value: estrogen(d), hormone: "ESTROGEN"),
             Sample(day: d, value: progesterone(d), hormone: "PROGESTERONE"),
             Sample(day: d, value: lh(d), hormone: "LH")]
        }
    }

    private let palette: [String: Color] = [
        "ESTROGEN": Theme.gold,
        "PROGESTERONE": CyclePhase.luteal.aura,
        "LH": Theme.ember
    ]

    private var shownDay: Int { scrubDay ?? min(state.cycleDay, length) }

    private var shownPhase: CyclePhase {
        CycleMath.phaseRanges(length: length, periodLength: state.periodLength)
            .first { $0.range.contains(shownDay) }?.phase ?? .luteal
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HairlineDivider(width: 110).frame(maxWidth: .infinity, alignment: .center)
            Text("THE HORMONE STORY")
                .font(Theme.control(10)).tracking(1.1)
                .foregroundStyle(Theme.ember)
            Text("Drag your finger across the month and feel how each day usually goes.")
                .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.65))
                .fixedSize(horizontal: false, vertical: true)

            readout
                .padding(.top, 10)

            chart
                .frame(height: 200)
                .padding(.top, 6)

            legend
                .padding(.top, 2)

            Text("The textbook script, never your levels.")
                .font(Theme.body(12).italic()).foregroundStyle(Theme.gold.opacity(0.65))
                .padding(.top, 6)
        }
        .padding(.top, 30)
    }

    /// The living caption: the day under her finger (or today), what era it is, and how it
    /// classically feels. Fixed height so scrubbing never makes the page jump.
    private var readout: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("DAY")
                    .font(Theme.mono(8.5)).tracking(Theme.tracking(8.5, em: 0.3))
                    .foregroundStyle(Theme.bone.opacity(0.5))
                Text("\(shownDay)")
                    .font(Theme.data(40))
                    .foregroundStyle(Theme.bone)
                    .contentTransition(.numericText())
                Text(shownDay == min(state.cycleDay, length) && scrubDay == nil ? "TODAY" : shownPhase.name)
                    .font(Theme.mono(8.5)).tracking(Theme.tracking(8.5, em: 0.2))
                    .foregroundStyle(shownPhase.aura)
            }
            .frame(width: 64, alignment: .leading)

            Text(Self.feel(day: shownDay, length: length, periodLength: state.periodLength))
                .font(Theme.body(14.5)).foregroundStyle(Theme.bone.opacity(0.9))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 96, alignment: .top)
        .shadow(color: .black.opacity(0.4), radius: 8, y: 1) // legible straight on the plate
        .animation(.easeOut(duration: 0.15), value: shownDay)
    }

    /// How a given textbook day classically feels, in the group chat's language. Typical patterns,
    /// never her measured anything.
    static func feel(day: Int, length: Int, periodLength: Int) -> String {
        let ov = CycleMath.ovulationDay(length: length)
        switch day {
        case 1:
            return "Day one. The uterus is doing demolition work and everything hurts a little. Heating pad, biggest shirt you own, zero guilt. Cancel what needs cancelling, it's not that deep."
        case 2...periodLength:
            return "Still bleeding, still officially in rest era. Iron-rich food, soft plans, early nights. The bar is on the floor and that's exactly where it belongs."
        case (periodLength + 1)...(ov - 4):
            return "Estrogen is picking you back up off the floor. Ideas sound fun again, people sound tolerable again. Say yes to one thing and watch it snowball."
        case (ov - 3)...(ov - 1):
            return "The glow-up window. Energy, focus, and audacity all climbing at once. Book the thing, send the message, wear the outfit."
        case ov...(ov + 1):
            return "Peak you. Estrogen at the very top, LH just fired, main character lighting on. Everyone can tell, even if nobody says it. You are the prize."
        case (ov + 2)...(ov + 6):
            return "The golden comedown. Still social, suddenly more selective. Perfect era for finishing things instead of starting them."
        case (length - 2)...:
            return "The PMS window, be so for real right now. The rage is chemistry, the tears are chemistry, the snack drawer is medicine. Softer plans, softer people, please."
        default:
            return "Progesterone is running the show now: cozier, hungrier, way less patient with nonsense. All three of those are valid. Protect your peace."
        }
    }

    private var chart: some View {
        Chart {
            ForEach(samples) { s in
                LineMark(x: .value("Day", s.day), y: .value("Level", s.value))
                    .foregroundStyle(by: .value("Hormone", s.hormone))
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 1.8))
            }
            RuleMark(x: .value("Today", Double(min(state.cycleDay, length))))
                .foregroundStyle(Theme.bone.opacity(0.45))
                .lineStyle(StrokeStyle(lineWidth: 0.75, dash: [3, 3]))
                .annotation(position: .top, alignment: .center) {
                    Text("TODAY")
                        .font(Theme.mono(8)).tracking(Theme.tracking(8, em: 0.2))
                        .foregroundStyle(Theme.bone.opacity(0.7))
                }
            if let scrubDay {
                RuleMark(x: .value("Here", Double(scrubDay)))
                    .foregroundStyle(Theme.gold.opacity(0.9))
                    .lineStyle(StrokeStyle(lineWidth: 1.4))
            }
        }
        .chartForegroundStyleScale { (name: String) in palette[name] ?? Theme.bone }
        .chartLegend(.hidden)
        .chartYAxis(.hidden)
        .chartXScale(domain: 1...Double(length))
        .chartXAxis {
            AxisMarks(values: [1, ovulation, length].map(Double.init)) { value in
                AxisGridLine().foregroundStyle(Theme.bone.opacity(0.08))
                AxisValueLabel {
                    if let d = value.as(Double.self) {
                        Text(label(for: Int(d)))
                            .font(Theme.mono(8)).tracking(Theme.tracking(8, em: 0.12))
                            .foregroundStyle(Theme.bone.opacity(0.5))
                    }
                }
            }
        }
        // The scrubber: her finger anywhere on the plot picks the day; letting go rests on today.
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                guard let plotAnchor = proxy.plotFrame else { return }
                                let x = value.location.x - geo[plotAnchor].origin.x
                                guard let day: Double = proxy.value(atX: x) else { return }
                                let clamped = min(max(1, Int(day.rounded())), length)
                                if clamped != scrubDay {
                                    scrubDay = clamped
                                    Haptics.light()
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.4)) { scrubDay = nil }
                            }
                    )
            }
        }
    }

    private func label(for day: Int) -> String {
        if day == 1 { return "DAY 1" }
        if day == ovulation { return "OVULATION ~\(day)" }
        return "DAY \(day)"
    }

    /// The legend doubles as the cast list: each hormone keeps her nickname so the lines have
    /// personality without a wall of explainer text under the plot.
    private var legend: some View {
        VStack(alignment: .leading, spacing: 6) {
            legendRow("ESTROGEN", "the hype girl, peaks right before the egg drops")
            legendRow("PROGESTERONE", "the cozy one, runs the show after ovulation")
            legendRow("LH", "the starting gun, one spike and it's happening")
        }
    }

    private func legendRow(_ name: String, _ nickname: String) -> some View {
        HStack(spacing: 7) {
            Circle().fill(palette[name] ?? Theme.bone).frame(width: 5, height: 5)
            Text(name)
                .font(Theme.mono(8.5)).tracking(Theme.tracking(8.5, em: 0.14))
                .foregroundStyle(Theme.bone.opacity(0.75))
            Text(nickname)
                .font(Theme.body(12).italic())
                .foregroundStyle(Theme.bone.opacity(0.55))
                .lineLimit(1)
        }
    }

}
