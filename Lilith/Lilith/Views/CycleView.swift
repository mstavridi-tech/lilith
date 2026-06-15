import SwiftUI

/// The Cycle tab (Phase 2). Manual logging first: where she is in her cycle, the hormone-weather
/// note for that phase, one-tap period logging, a fuller log sheet, and her recent days. Same
/// celestial editorial language as the rest of the app, with the deep-wine accent cycle features
/// wear. Wellness content, never medical: the disclaimer bridge to a real doctor lives at the foot.
struct CycleView: View {
    @ObservedObject private var store = CycleStore.shared
    @State private var showLog = false
    @State private var showCalendar = false
    @State private var developToken = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                topBar.cascadeIn(0, trigger: developToken)

                CycleOrb(state: store.today, expectingDays: store.expectingDays)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 22)
                    .cascadeIn(1, trigger: developToken)

                if let state = store.today {
                    orbCaption(state).cascadeIn(2, trigger: developToken)
                    logActions.cascadeIn(3, trigger: developToken)
                    hormoneWeather(state).cascadeIn(4, trigger: developToken)
                    moonWeather(state).cascadeIn(5, trigger: developToken)
                } else {
                    invite.cascadeIn(2, trigger: developToken)
                    logActions.cascadeIn(3, trigger: developToken)
                }

                disclaimer.cascadeIn(6, trigger: developToken)

                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 40)
            }
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .cosmicScreen(bloomAlignment: .top, bloomIntensity: 0.7)
        .sheet(isPresented: $showLog) {
            CycleLogSheet(date: Date(), store: store)
        }
        .sheet(isPresented: $showCalendar) {
            CycleCalendarSheet(store: store)
        }
        .onAppear { if developToken == 0 { developToken = 1 } }
    }

    // MARK: Top bar (title + the tappable calendar)

    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("YOUR CYCLE").displayCaps(30, em: 0.16)
                Text("Kept on your phone alone.")
                    .font(Theme.body(14)).foregroundStyle(Theme.gold.opacity(0.85))
            }
            Spacer()
            Button {
                Haptics.light()
                showCalendar = true
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12, weight: .medium))
                    Text("CALENDAR")
                        .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.16))
                }
                .foregroundStyle(Theme.gold)
                .padding(.horizontal, 14).padding(.vertical, 9)
                .overlay(Capsule().strokeBorder(Theme.gold.opacity(0.45), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
        }
    }

    // A single line under the orb: when her next period is expected.
    private func orbCaption(_ state: CycleState) -> some View {
        Text(nextLine(state))
            .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.16))
            .foregroundStyle(Theme.gold.opacity(0.8))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 18)
    }

    private func nextLine(_ state: CycleState) -> String {
        if state.isBleedingToday { return "BLEEDING TODAY · CYCLE OF ~\(state.cycleLength) DAYS" }
        switch state.nextPeriodInDays {
        case 0: return "PERIOD EXPECTED TODAY"
        case 1: return "PERIOD EXPECTED TOMORROW"
        default: return "PERIOD EXPECTED IN ~\(state.nextPeriodInDays) DAYS"
        }
    }

    private func hormoneWeather(_ state: CycleState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HairlineDivider(width: 110)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("HORMONE WEATHER")
                .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
                .foregroundStyle(Theme.ember)
            Text(state.phase.hormoneNote)
                .font(Theme.body(16))
                .foregroundStyle(Theme.bone.opacity(0.9))
                .lineSpacing(7)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 30)
    }

    // MARK: Invite (no data yet)

    private var invite: some View {
        Text("Log the first day of your period and the orb comes alive: your phase, your hormone weather, and how it all plays against your chart. The more you log, the sharper I get, and none of it ever leaves this phone.")
            .font(Theme.body(16)).foregroundStyle(Theme.bone.opacity(0.88))
            .lineSpacing(7)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
            .padding(.top, 26)
    }

    // MARK: Moon weather (cycle synced to the moon, the whole point of LILITH)

    private func moonWeather(_ state: CycleState) -> some View {
        let moon = (try? ChartEngine.moonPhase()) ?? .fullMoon
        return VStack(alignment: .leading, spacing: 12) {
            HairlineDivider(width: 110).frame(maxWidth: .infinity, alignment: .center)
            HStack(spacing: 8) {
                Image(systemName: Self.moonSymbol(moon)).font(.system(size: 13))
                Text("MOON WEATHER · \(moon.rawValue.uppercased())")
                    .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.22))
            }
            .foregroundStyle(Theme.ember)
            Text(Self.moonCycleNote(cycle: state.phase, moon: moon))
                .font(Theme.body(16))
                .foregroundStyle(Theme.bone.opacity(0.9))
                .lineSpacing(7)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 30)
    }

    static func moonSymbol(_ p: MoonPhase) -> String {
        switch p {
        case .newMoon: "moonphase.new.moon"
        case .waxingCrescent: "moonphase.waxing.crescent"
        case .firstQuarter: "moonphase.first.quarter"
        case .waxingGibbous: "moonphase.waxing.gibbous"
        case .fullMoon: "moonphase.full.moon"
        case .waningGibbous: "moonphase.waning.gibbous"
        case .lastQuarter: "moonphase.last.quarter"
        case .waningCrescent: "moonphase.waning.crescent"
        }
    }

    /// Blends her cycle phase with tonight's moon, including the old red-moon / white-moon lore when
    /// she's bleeding on a full or new moon. In voice, never doom, never medical.
    static func moonCycleNote(cycle: CyclePhase, moon: MoonPhase) -> String {
        if cycle == .menstrual && moon == .newMoon {
            return "Bleeding on a new moon is the old White Moon cycle: deeply inward and intuitive, the body and the sky both pulling you to rest and set quiet intentions. Lean all the way in."
        }
        if cycle == .menstrual && moon == .fullMoon {
            return "Bleeding on a full moon is the Red Moon cycle: potent and magnetic, a lot of energy moving at once. You're not too much, you're in season. Channel it."
        }
        switch moon {
        case .newMoon:
            return "New moon, clean slate, and you're in your \(cycle.rawValue) phase, so beginnings are doubly favoured. Plant the seed, skip the grand reveal."
        case .waxingCrescent, .waxingGibbous:
            return "The moon is building toward full and so is the momentum, which suits the \(cycle.rawValue) energy you're in. A good window to act."
        case .firstQuarter:
            return "First quarter moon: a little friction is the point. Pair it with your \(cycle.rawValue) phase and make the decision you keep circling."
        case .fullMoon:
            return "The full moon turns the volume up on everything, feelings included. In your \(cycle.rawValue) phase that's a lot at once, so let it peak, then breathe."
        case .waningGibbous, .waningCrescent:
            return "The moon is releasing and winding down, which matches the \(cycle.rawValue) instinct to let go and conserve. Permission granted."
        case .lastQuarter:
            return "Last quarter moon: clear, don't start. Quiet alignment with where your \(cycle.rawValue) phase already wants to go."
        }
    }

    // MARK: Logging actions (aura pills)

    private var logActions: some View {
        VStack(spacing: 14) {
            auraPill(bleedingToday ? "PERIOD LOGGED TODAY" : "MY PERIOD STARTED TODAY",
                     color: Theme.blood, filled: bleedingToday) {
                Haptics.soft(); store.togglePeriodToday()
            }
            auraPill("LOG TODAY IN DETAIL", color: Theme.gold, filled: false) {
                Haptics.light(); showLog = true
            }
        }
        .padding(.top, 30)
    }

    /// A soft, glowing capsule. The aura comes from a blurred colour halo bleeding out behind it.
    private func auraPill(_ title: String, color: Color, filled: Bool,
                          action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.18))
                .foregroundStyle(filled ? Theme.bone : color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    ZStack {
                        Capsule().fill(color.opacity(filled ? 0.30 : 0.0))
                        Capsule().strokeBorder(color.opacity(filled ? 0.9 : 0.55), lineWidth: 1)
                    }
                )
                .background(
                    Capsule().fill(color)
                        .opacity(filled ? 0.40 : 0.20)
                        .blur(radius: 20) // the aura halo
                )
        }
        .buttonStyle(.plain)
    }

    private var bleedingToday: Bool { store.entry(on: Date())?.isBleeding ?? false }

    // MARK: Disclaimer (the mandatory bridge, in voice)

    private var disclaimer: some View {
        Text("LILITH reads patterns, it doesn't diagnose. It can't measure your hormones, only describe what's typical for each phase. If something feels extreme month after month, that's worth a real doctor conversation, and it's not you being dramatic.")
            .font(Theme.body(13)).foregroundStyle(Theme.gold.opacity(0.7))
            .lineSpacing(5)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 18)
            .padding(.horizontal, 18)
            .overlay(Rectangle().fill(Theme.gold.opacity(0.4)).frame(width: 0.5), alignment: .leading)
            .padding(.top, 40)
    }
}

// MARK: - The detail log sheet

/// Log or edit one day: flow, mood, symptoms, a note. Rises as the same dark glass as the readings.
struct CycleLogSheet: View {
    let date: Date
    let store: CycleStore
    @Environment(\.dismiss) private var dismiss

    @State private var flow: FlowLevel?
    @State private var mood: CycleMood?
    @State private var symptoms: Set<CycleSymptom> = []
    @State private var note: String = ""

    init(date: Date, store: CycleStore) {
        self.date = date
        self.store = store
        let existing = store.entry(on: date)
        _flow = State(initialValue: existing?.flow)
        _mood = State(initialValue: existing?.mood)
        _symptoms = State(initialValue: Set(existing?.symptoms ?? []))
        _note = State(initialValue: existing?.note ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(Calendar.current.isDateInToday(date) ? "LOG TODAY" : "EDIT DAY")
                    .displayCaps(28, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(28, em: 0.14))
                    .padding(.top, 44)
                Text(Self.longDate.string(from: date).uppercased())
                    .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.2))
                    .foregroundStyle(Theme.gold.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)

                periodStartAction.padding(.top, 26)

                groupLabel("FLOW")
                chips(FlowLevel.allCases, isOn: { flow == $0 }) { picked in
                    flow = (flow == picked) ? nil : picked
                }

                groupLabel("MOOD")
                chips(CycleMood.allCases, isOn: { mood == $0 }) { picked in
                    mood = (mood == picked) ? nil : picked
                }

                groupLabel("SYMPTOMS")
                chips(CycleSymptom.allCases, isOn: { symptoms.contains($0) }) { picked in
                    if symptoms.contains(picked) { symptoms.remove(picked) } else { symptoms.insert(picked) }
                }

                groupLabel("NOTE")
                TextField("anything worth remembering", text: $note, axis: .vertical)
                    .font(Theme.body(16)).foregroundStyle(Theme.bone)
                    .lineLimit(2...5)
                    .padding(12)
                    .overlay(RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Theme.gold.opacity(0.3), lineWidth: 0.5))

                Button {
                    Haptics.soft()
                    save()
                    dismiss()
                } label: {
                    Text("SAVE")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.18))
                        .foregroundStyle(Theme.void)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Theme.gold))
                }
                .buttonStyle(.plain)
                .padding(.top, 30)
            }
            .padding(.horizontal, 30)
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
    }

    /// The clearest way to log a period on this day: one tap that blocks off the typical span, or
    /// removes it. Works for any day the sheet was opened on (today, past, or expected).
    @ViewBuilder private var periodStartAction: some View {
        if store.isBleeding(on: date) {
            Button {
                Haptics.soft(); store.clearPeriod(around: date); dismiss()
            } label: {
                Text("REMOVE THIS PERIOD")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.16))
                    .foregroundStyle(Theme.blood)
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .overlay(RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Theme.blood.opacity(0.6), lineWidth: 0.75))
            }
            .buttonStyle(.plain)
        } else {
            VStack(spacing: 8) {
                Button {
                    Haptics.soft(); store.logPeriodStart(on: date); dismiss()
                } label: {
                    Text("PERIOD STARTED THIS DAY")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.16))
                        .foregroundStyle(Theme.void)
                        .frame(maxWidth: .infinity).padding(.vertical, 15)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Theme.blood))
                }
                .buttonStyle(.plain)
                Text("blocks off the next 5 days. edit any of them below.")
                    .font(Theme.body(12)).foregroundStyle(Theme.bone.opacity(0.55))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    private func groupLabel(_ text: String) -> some View {
        Text(text)
            .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
            .foregroundStyle(Theme.ember)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 28)
            .padding(.bottom, 12)
    }

    /// A wrapping row of selectable chips for any labelled, identifiable set.
    private func chips<T: Identifiable>(_ items: [T], isOn: @escaping (T) -> Bool,
                                        toggle: @escaping (T) -> Void) -> some View where T: Hashable {
        FlowLayout(spacing: 10) {
            ForEach(items) { item in
                let on = isOn(item)
                Button {
                    Haptics.light()
                    toggle(item)
                } label: {
                    Text(label(for: item))
                        .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.12))
                        .foregroundStyle(on ? Theme.void : Theme.bone.opacity(0.8))
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(
                            RoundedRectangle(cornerRadius: 3)
                                .fill(on ? Theme.gold : Color.clear)
                                .overlay(RoundedRectangle(cornerRadius: 3)
                                    .strokeBorder(Theme.gold.opacity(on ? 0 : 0.4), lineWidth: 0.5))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func label<T>(for item: T) -> String {
        switch item {
        case let f as FlowLevel: return f.label
        case let m as CycleMood: return m.label
        case let s as CycleSymptom: return s.label
        default: return "\(item)"
        }
    }

    private func save() {
        var entry = store.entry(on: date) ?? CycleEntry(date: date)
        entry.flow = flow
        entry.mood = mood
        entry.symptoms = Array(symptoms)
        entry.note = note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : note
        store.save(entry)
    }

    private static let longDate: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "EEEE, d MMMM"; return f
    }()
}

// MARK: - A minimal wrapping layout for the chips

/// A tiny flow layout so chips wrap to the next line instead of clipping. Standard Layout protocol.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth == .infinity ? x : maxWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for sub in subviews {
            let size = sub.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            sub.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
