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
                .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
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

// MARK: - The textbook hormone curve (Maria's master list, July 4)
//
// Hormone literacy, drawn honestly: the CLASSIC estrogen / progesterone / LH shapes across a cycle
// of her length, a rule at today, and plain-language explainers. This is education about what's
// typical. It is NEVER her measured levels; the card says so out loud, per docs/01 trust rules.

struct HormoneCurveCard: View {
    let state: CycleState

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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HairlineDivider(width: 110).frame(maxWidth: .infinity, alignment: .center)
            Text("THE TEXTBOOK CURVE")
                .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
                .foregroundStyle(Theme.ember)
            Text("What the chemistry classically does across a \(length)-day cycle, and where you are in it.")
                .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)

            chart
                .frame(height: 225) // room to breathe (Maria, July 4 evening: it felt cramped)
                .padding(.top, 14)

            legend
                .padding(.top, 4)

            VStack(alignment: .leading, spacing: 16) {
                explainer("ESTROGEN", "The hype girl. She climbs all through your follicular phase, peaks right before the egg drops, and that peak is why main character week feels like that.")
                explainer("PROGESTERONE", "The cozy one. She only shows up after ovulation, runs the luteal show, and slows everything down on purpose. When she leaves, your period arrives.")
                explainer("LH", "The starting gun. One sharp spike out of nowhere and ovulation happens about a day later. Blink and you miss her.")
            }
            .padding(.top, 14)

            Text("The textbook shape, never your levels.")
                .font(Theme.body(12).italic()).foregroundStyle(Theme.gold.opacity(0.65))
                .padding(.top, 10)
        }
        .softCard(padding: 22)
        .padding(.top, 30)
    }

    private var chart: some View {
        Chart {
            ForEach(samples) { s in
                LineMark(x: .value("Day", s.day), y: .value("Level", s.value))
                    .foregroundStyle(by: .value("Hormone", s.hormone))
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 1.6))
            }
            RuleMark(x: .value("Today", Double(min(state.cycleDay, length))))
                .foregroundStyle(Theme.bone.opacity(0.45))
                .lineStyle(StrokeStyle(lineWidth: 0.75, dash: [3, 3]))
                .annotation(position: .top, alignment: .center) {
                    Text("TODAY")
                        .font(Theme.mono(8)).tracking(Theme.tracking(8, em: 0.2))
                        .foregroundStyle(Theme.bone.opacity(0.7))
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
    }

    private func label(for day: Int) -> String {
        if day == 1 { return "DAY 1" }
        if day == ovulation { return "OVULATION ~\(day)" }
        return "DAY \(day)"
    }

    private var legend: some View {
        HStack(spacing: 14) {
            ForEach(["ESTROGEN", "PROGESTERONE", "LH"], id: \.self) { name in
                HStack(spacing: 5) {
                    Circle().fill(palette[name] ?? Theme.bone).frame(width: 5, height: 5)
                    Text(name)
                        .font(Theme.mono(8.5)).tracking(Theme.tracking(8.5, em: 0.14))
                        .foregroundStyle(Theme.bone.opacity(0.65))
                }
            }
        }
    }

    private func explainer(_ name: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(name)
                .font(Theme.mono(9)).tracking(Theme.tracking(9, em: 0.2))
                .foregroundStyle(palette[name] ?? Theme.bone)
            Text(text)
                .font(Theme.body(13.5)).foregroundStyle(Theme.bone.opacity(0.82))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
