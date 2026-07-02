import SwiftUI

/// The home screen and the product: today's merged answer to "why do I feel like this?"
///
/// REBUILT July 2, 2026, twice, on Maria's orders. Round one made it body-first (cycle day hero,
/// moon demoted to a sky row). Round two is the Oura register: a giant thin numeral instead of
/// costume caps, calm opaque surface cards instead of raw void, a disciplined text hierarchy
/// (Theme.textPrimary/Secondary/Tertiary), tracking reserved for a couple of editorial moments,
/// and real pressed states. Cormorant survives only where it earns it: the headline and mantra.
///
/// The lure-pass craft is kept: the card develops instead of popping, pull-to-refresh is the
/// eclipse (never a spinner), restrained haptics.
struct TodayView: View {
    let chart: NatalChart
    @ObservedObject private var cycle = CycleStore.shared
    @State private var horoscope: HoroscopeService.HoroscopeResponse?
    @State private var moonStatus = "☽ READING THE SKY"
    @State private var moonPhaseFull = "READING THE SKY"  // full phase name, e.g. "WANING GIBBOUS"
    @State private var moonSignName = ""                  // e.g. "AQUARIUS"
    @State private var moonIllumPct = 0                   // illuminated fraction tonight, 0...100
    @State private var moonElongation: Double = 180 // tonight's real phase; full until loaded
    @State private var scope: HoroscopeService.Scope = .daily        // the selected tab
    @State private var displayScope: HoroscopeService.Scope = .daily // what the reading shows
    @State private var showMoonSheet = false

    // Lure-pass state
    @State private var developToken = 0       // bumps once per fresh load; drives the cascade
    @State private var scrollY: CGFloat = 0    // top offset, for the custom pull-to-refresh
    @State private var armed = false           // over-pulled past the threshold, waiting for release
    @State private var isRefreshing = false    // the eclipse is sweeping

    private let moonDiameter: CGFloat = 56 // the moon is seasoning now, not the headline
    private let pullThreshold: CGFloat = 88
    private static let space = "todayScroll"

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    credits.cascadeIn(0, trigger: developToken)
                    greeting.cascadeIn(1, trigger: developToken)
                    heroBlock.cascadeIn(2, trigger: developToken)
                    skyCard.moonSettle(trigger: developToken)
                    scopeSwitcher.cascadeIn(3, trigger: developToken)
                    readingCard.cascadeIn(4, trigger: developToken)
                    Spacer(minLength: 30)
                    footer.cascadeIn(5, trigger: developToken)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 110) // clears the floating tab bar
                .frame(minHeight: geo.size.height, alignment: .top)
                .background(scrollReader)
            }
            .scrollIndicators(.hidden)
            .coordinateSpace(name: Self.space)
            .onPreferenceChange(ScrollOffsetKey.self) { handleScroll($0) }
        }
        .atmosphereScreen(aura: cycle.today?.phase.aura ?? Theme.ember, intensity: 0.8)
        .task { await load() }
        .sheet(isPresented: $showMoonSheet) { MoonSheet(chart: chart) }
    }

    // MARK: Scroll plumbing (the custom, spinner-free pull-to-refresh)

    private var scrollReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ScrollOffsetKey.self,
                                   value: proxy.frame(in: .named(Self.space)).minY)
        }
    }

    /// Arm on over-pull, fire on release. No system spinner is ever involved.
    private func handleScroll(_ y: CGFloat) {
        scrollY = y
        guard !isRefreshing else { return }
        if y > pullThreshold, !armed {
            armed = true
            Haptics.light()
        } else if armed, y < 12 {
            armed = false
            Task { await refresh() }
        }
    }

    // MARK: Top credits (the one place tiny mono telemetry still lives)

    private var credits: some View {
        HStack {
            Text(Self.dateLine.string(from: Date()))
                .font(Theme.mono(10))
            Spacer()
            Text(moonStatus).font(Theme.mono(10)).opacity(0.85)
        }
        .tracking(Theme.tracking(10, em: 0.16))
        .foregroundStyle(Theme.gold.opacity(0.85))
    }

    /// "11 . 06 . 2026" — day . month . year, locale-independent.
    private static let dateLine: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd . MM . yyyy"
        return f
    }()

    // MARK: The greeting (docs/07), leading the page like a friend at the door

    /// Time-aware greeting as a pure function of the hour (0...23) and day index, unit-testable.
    /// Hour bands cover all 24 hours with no gaps. Morning slots are Maria's locked signatures.
    static func greetingPhrase(hour: Int, dayIndex: Int) -> String {
        let slot: [String]
        switch hour {
        case 5...11:  slot = ["GOOD MORNING, SUNSHINE.", "RISE AND SHINE."]
        case 12...16: slot = ["TODAY, FOR YOU.", "STILL YOUR DAY."]
        case 17...21: slot = ["GOOD EVENING, GORGEOUS.", "THE MOON IS UP."]
        default:      slot = ["UP LATE, I SEE.", "THE STARS DON'T SLEEP EITHER."]
        }
        return slot[((dayIndex % slot.count) + slot.count) % slot.count]
    }

    private func currentGreeting(_ date: Date) -> String {
        let cal = Calendar.current
        let hour = cal.component(.hour, from: date)
        let day = cal.ordinality(of: .day, in: .era, for: date) ?? 0
        return Self.greetingPhrase(hour: hour, dayIndex: day)
    }

    /// Recomputes every minute so the greeting can never go stale across an hour boundary.
    private var greeting: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            Text(currentGreeting(context.date))
                .font(Theme.label(11))
                .tracking(1.4)
                .foregroundStyle(Theme.ember)
                .padding(.top, 30)
        }
    }

    // MARK: The hero — her body, first, in jewelry numerals

    /// The cycle day as a giant thin numeral with the phase worn as a soft chip beside it.
    /// When no cycle is logged yet, a one-line invite points at the Cycle tab instead.
    @ViewBuilder
    private var heroBlock: some View {
        if let state = cycle.today {
            VStack(alignment: .leading, spacing: 4) {
                Text("CYCLE DAY")
                    .font(Theme.label(11))
                    .tracking(1.6)
                    .foregroundStyle(Theme.textSecondary)
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text("\(state.cycleDay)")
                        .font(Theme.data(84))
                        .foregroundStyle(Theme.textPrimary)
                    phaseChip(state)
                }
                Text(state.phase.tagline)
                    .font(Theme.body(16).italic())
                    .foregroundStyle(Theme.textSecondary)
            }
            .padding(.top, 12)
        } else {
            Text("Half the answer lives in your cycle. Log it in the Cycle tab and I'll read the whole you.")
                .font(Theme.body(15).italic())
                .foregroundStyle(Theme.textSecondary)
                .padding(.top, 16)
        }
    }

    private func phaseChip(_ state: CycleState) -> some View {
        Text(state.phase.name)
            .font(Theme.label(11))
            .tracking(1.2)
            .foregroundStyle(state.phase.aura)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(state.phase.aura.opacity(0.16)))
    }

    // MARK: The sky card — the moon as seasoning, one tap from the full sheet

    private var skyCard: some View {
        Button {
            Haptics.open()
            showMoonSheet = true
        } label: {
            HStack(spacing: 16) {
                MoonView(diameter: moonDiameter, elongation: moonElongation)
                    .overlay { if isRefreshing { eclipseSweep } }
                VStack(alignment: .leading, spacing: 3) {
                    Text("THE SKY")
                        .font(Theme.label(10))
                        .tracking(1.4)
                        .foregroundStyle(Theme.gold.opacity(0.8))
                    Text(skyLine)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Theme.textSecondary)
                        .contentTransition(.opacity)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.textTertiary)
            }
        }
        .buttonStyle(PressableCardStyle())
        .padding(.top, 26)
    }

    private var skyLine: String {
        var parts = [String]()
        if moonPhaseFull != "READING THE SKY" { parts.append(moonPhaseFull.capitalized) }
        if moonIllumPct > 0 { parts.append("\(moonIllumPct)% lit") }
        if !moonSignName.isEmpty { parts.append("in \(moonSignName.capitalized)") }
        return parts.isEmpty ? "Reading the sky" : parts.joined(separator: " · ")
    }

    /// The signature pull-to-refresh: the terminator shadow sweeps across the moon until the
    /// reading lands. An eclipse, never a spinner (docs/08).
    private var eclipseSweep: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            let p = CGFloat((t.truncatingRemainder(dividingBy: 1.3)) / 1.3) // 0...1 each 1.3s
            Circle()
                .fill(Theme.void.opacity(0.95))
                .frame(width: moonDiameter, height: moonDiameter)
                .offset(x: -moonDiameter * 1.25 + p * moonDiameter * 2.5)
                .blur(radius: moonDiameter * 0.05)
                .frame(width: moonDiameter, height: moonDiameter)
                .clipShape(Circle())
        }
        .frame(width: moonDiameter, height: moonDiameter)
        .allowsHitTesting(false)
    }

    // MARK: Scope — DAILY / WEEKLY / MONTHLY (all hit the same backend, docs/06)

    private var scopeSwitcher: some View {
        HStack(spacing: 8) {
            ForEach(HoroscopeService.Scope.allCases) { s in
                Button {
                    guard scope != s else { return }
                    Haptics.light()
                    scope = s
                    Task { await load() }
                } label: {
                    Text(s.label)
                        .font(Theme.label(11))
                        .tracking(1.0)
                        .foregroundStyle(scope == s ? Theme.void : Theme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10) // a real 44pt-class target
                        .background(
                            Capsule().fill(scope == s ? Theme.gold : Theme.surfaceHigh)
                        )
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .animation(.easeInOut(duration: 0.2), value: scope)
        .padding(.top, 26)
    }

    // MARK: The reading card — the merged answer on one calm surface

    private var readingCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            headline
            reading
            HairlineDivider()
                .frame(maxWidth: .infinity)
                .padding(.top, 22)
            mantra
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .softCard()
        .padding(.top, 18)
    }

    private var headline: some View {
        Text((horoscope?.headline ?? "CONSULTING THE SKY").uppercased())
            .font(Theme.display(23).weight(.medium))
            .tracking(Theme.tracking(23, em: 0.06)) // editorial, not effortful
            .foregroundStyle(Theme.textPrimary)
            .multilineTextAlignment(.leading)
            .lineSpacing(6)
            .contentTransition(.opacity) // crossfade on scope change, never a hard cut
    }

    private var readingText: String {
        horoscope?.reading ?? "The sky is loading your reading. Pull to refresh in a second."
    }

    /// One easy left-aligned column, every scope. Monthly keeps its gold chapter labels.
    private var reading: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(Array(Self.paragraphs(readingText, detectLabels: true).enumerated()), id: \.offset) { _, para in
                VStack(alignment: .leading, spacing: 7) {
                    if let label = para.label {
                        Text(label)
                            .font(Theme.label(10))
                            .tracking(1.4)
                            .foregroundStyle(Theme.gold)
                    }
                    Text(para.body)
                        .font(Theme.body(15.5))
                        .foregroundStyle(Theme.bone.opacity(0.92))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(9) // a comfortable reading column, never squeezed
                        .fixedSize(horizontal: false, vertical: true) // never truncate
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .contentTransition(.opacity)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }

    /// One paragraph of a reading, with an optional gold section label (monthly chapters).
    private struct Paragraph { let label: String?; let body: String }

    /// Split a reading into paragraphs on blank lines (the backend normalizes to "\n\n"). A short
    /// ALL-CAPS first line ending in ":" becomes a gold label.
    private static func paragraphs(_ text: String, detectLabels: Bool) -> [Paragraph] {
        let blocks = text.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return blocks.map { block in
            if detectLabels, let nl = block.firstIndex(of: "\n") {
                let first = String(block[..<nl]).trimmingCharacters(in: .whitespaces)
                let rest = String(block[block.index(after: nl)...]).trimmingCharacters(in: .whitespacesAndNewlines)
                if isLabel(first), !rest.isEmpty {
                    return Paragraph(label: String(first.dropLast()), body: rest) // drop trailing ":"
                }
            }
            return Paragraph(label: nil, body: block)
        }
    }

    private static func isLabel(_ s: String) -> Bool {
        guard s.hasSuffix(":") else { return false }
        let core = s.dropLast()
        guard !core.isEmpty, core.count <= 20 else { return false }
        return core.allSatisfy { $0 == " " || $0 == "/" || ($0.isLetter && $0.isUppercase) }
    }

    /// The mantra keeps its wide tracking: one of exactly two editorial tracking moments on this
    /// screen (the other is the headline). Everything else stays calm.
    private var mantra: some View {
        Text(horoscope?.cardMantra ?? "BREATHE.")
            .font(Theme.display(15).weight(.medium))
            .tracking(Theme.tracking(15, em: 0.3))
            .foregroundStyle(Theme.textPrimary)
            .multilineTextAlignment(.center)
            .contentTransition(.opacity)
            .frame(maxWidth: .infinity)
            .padding(.leading, Theme.tracking(15, em: 0.3))
            .padding(.top, 18)
    }

    // MARK: Footer — her big three, then the quiet wordmark

    private var footer: some View {
        VStack(spacing: 13) {
            Text(chart.bigThreeShort)
                .font(Theme.mono(9.5))
                .tracking(Theme.tracking(9.5, em: 0.12))
                .foregroundStyle(Theme.gold.opacity(0.7))
            Wordmark()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Loading

    /// Cache-first. Runs on appear, tab switch, and scope switch. Costs ZERO network calls when
    /// this scope is already cached for today; only the first view of a scope per day fetches.
    private func load() async {
        updateSky()
        let isFirst = horoscope == nil
        let target = scope
        let new = await HoroscopeService.reading(chart: chart, scope: target)
        // The tab may have changed again while we awaited; only commit if it's still the latest pick.
        guard scope == target else { return }
        if isFirst {
            horoscope = new
            displayScope = target
            bumpDevelop()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                horoscope = new
                displayScope = target
            }
        }
    }

    /// Pull-to-refresh: the one manual override that always re-fetches from the backend.
    private func refresh() async {
        isRefreshing = true
        updateSky()
        let target = scope
        let new = await HoroscopeService.refresh(chart: chart, scope: target)
        horoscope = new
        displayScope = target
        isRefreshing = false
        bumpDevelop()
    }

    /// One fresh-load beat: replay the cascade and answer with a single soft landing.
    private func bumpDevelop() {
        developToken += 1
        Haptics.soft()
    }

    /// Tonight's moon status and phase. Pure local math, never a network call.
    private func updateSky() {
        if let moon = (try? ChartEngine.currentSky())?.first(where: { $0.body == .moon }),
           let phase = try? ChartEngine.moonPhase() {
            moonStatus = "☽ \(phase.shortLabel) · \(Int(moon.degreeInSign))° \(moon.sign.name.prefix(3).uppercased())"
            moonSignName = moon.sign.name
        }
        if let elongation = try? ChartEngine.moonElongation() {
            moonElongation = elongation
            // Illuminated fraction from the sun-moon elongation: (1 - cos θ) / 2, 0 = new, 1 = full.
            let illum = (1 - cos(elongation * .pi / 180)) / 2
            moonIllumPct = Int((illum * 100).rounded())
            if let phase = try? ChartEngine.moonPhase() {
                moonPhaseFull = phase.rawValue
            }
        }
    }
}

/// A soft-card button: the whole surface presses down a breath (scale 0.98) and lifts back.
/// Real tap feedback without layout shift (pro-UI rule: stable interaction states).
struct PressableCardStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(configuration.isPressed ? Theme.surfaceHigh : Theme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(
                                LinearGradient(colors: [Theme.bone.opacity(0.08), .clear],
                                               startPoint: .top, endPoint: .bottom),
                                lineWidth: 0.75)
                    )
                    .shadow(color: .black.opacity(0.35), radius: 24, y: 10)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

/// Reads the Today scroll view's top offset so the eclipse refresh can arm and fire without a
/// system spinner.
private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
