import SwiftUI

/// The Cycle tab (Phase 2). Manual logging first: where she is in her cycle, the hormone-weather
/// note for that phase, one-tap period logging, a fuller log sheet, and her recent days. Same
/// celestial editorial language as the rest of the app, with the deep-wine accent cycle features
/// wear. Wellness content, never medical: the disclaimer bridge to a real doctor lives at the foot.
struct CycleView: View {
    @ObservedObject private var store = CycleStore.shared
    @State private var showLog = false
    @State private var developToken = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header.cascadeIn(0, trigger: developToken)

                if let state = store.today {
                    phaseBlock(state).cascadeIn(1, trigger: developToken)
                    hormoneWeather(state).cascadeIn(2, trigger: developToken)
                } else {
                    emptyState.cascadeIn(1, trigger: developToken)
                }

                logActions.cascadeIn(3, trigger: developToken)

                if !store.recent().isEmpty {
                    recentLog.cascadeIn(4, trigger: developToken)
                }

                disclaimer.cascadeIn(5, trigger: developToken)

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
        .onAppear { if developToken == 0 { developToken = 1 } }
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR CYCLE").displayCaps(34, em: 0.16)
            Text("Tracked against the moon, kept on your phone alone.")
                .font(Theme.body(16)).foregroundStyle(Theme.gold)
        }
    }

    // MARK: Current phase

    private func phaseBlock(_ state: CycleState) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(state.phase.name)
                .displayCaps(40, em: 0.12, color: state.phase.accent)
                .padding(.leading, Theme.tracking(40, em: 0.12))

            Text("DAY \(state.cycleDay)  ·  \(state.phase.tagline.uppercased())")
                .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                .foregroundStyle(Theme.bone.opacity(0.7))

            Text(nextLine(state))
                .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.12))
                .foregroundStyle(Theme.gold.opacity(0.75))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 34)
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

    // MARK: Empty state (no data yet)

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("LET'S SYNC YOU UP")
                .displayCaps(28, em: 0.14)
                .padding(.leading, Theme.tracking(28, em: 0.14))
            Text("Log the first day of your period and I'll start reading your phases, your hormone weather, and how it all plays against your chart. The more you log, the sharper I get. Your data never leaves this phone.")
                .font(Theme.body(16)).foregroundStyle(Theme.bone.opacity(0.88))
                .lineSpacing(7)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 34)
    }

    // MARK: Logging actions

    private var logActions: some View {
        VStack(spacing: 12) {
            Button {
                Haptics.soft()
                store.togglePeriodToday()
            } label: {
                Text(bleedingToday ? "PERIOD LOGGED FOR TODAY ✓" : "MY PERIOD STARTED TODAY")
                    .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.16))
                    .foregroundStyle(bleedingToday ? Theme.void : Theme.bone)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(bleedingToday ? Theme.blood : Color.clear)
                            .overlay(RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(Theme.blood.opacity(0.7), lineWidth: 0.75))
                    )
            }
            .buttonStyle(.plain)

            Button {
                Haptics.light()
                showLog = true
            } label: {
                Text("LOG TODAY IN DETAIL")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.16))
                    .foregroundStyle(Theme.gold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Theme.gold.opacity(0.4), lineWidth: 0.5))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 36)
    }

    private var bleedingToday: Bool { store.entry(on: Date())?.isBleeding ?? false }

    // MARK: Recent log

    private var recentLog: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("RECENT").displayCaps(20, em: 0.16)
                .padding(.bottom, 10)
            ForEach(Array(store.recent().enumerated()), id: \.element.id) { index, entry in
                if index > 0 {
                    Rectangle().fill(Theme.gold.opacity(0.15)).frame(height: 0.5)
                }
                HStack(spacing: 14) {
                    Text(Self.dayLabel.string(from: entry.date))
                        .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.1))
                        .foregroundStyle(Theme.bone.opacity(0.55))
                        .frame(width: 92, alignment: .leading)
                    Text(summary(entry))
                        .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.85))
                    Spacer()
                }
                .padding(.vertical, 13)
            }
        }
        .padding(.top, 38)
    }

    private func summary(_ entry: CycleEntry) -> String {
        var bits: [String] = []
        if let f = entry.flow { bits.append(f.rawValue) }
        if let m = entry.mood { bits.append(m.rawValue) }
        if !entry.symptoms.isEmpty { bits.append(entry.symptoms.map(\.rawValue).joined(separator: ", ")) }
        return bits.isEmpty ? "logged" : bits.joined(separator: " · ")
    }

    private static let dayLabel: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "d MMM"; return f
    }()

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
                Text("LOG TODAY")
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
