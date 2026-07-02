import SwiftUI

/// The home screen and the product: today's merged answer to "why do I feel like this?"
///
/// REBUILT July 2, 2026 (Maria's reset): body FIRST, sky as seasoning. The hero is her cycle
/// day and phase; the moon shrinks into a compact sky row; the reading follows as an easy
/// left-aligned column. The stage is the Marte-poster atmosphere (LimbAtmosphere in Theme),
/// tinted by her current phase. Ease to the eyes: one glow, calm black, fewer glyphs.
///
/// The lure-pass craft is kept: the card develops instead of popping, pull-to-refresh is the
/// eclipse (never a spinner), and the screen answers her touch with restrained haptics.
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

    private let moonDiameter: CGFloat = 64 // the moon is seasoning now, not the headline
    private let pullThreshold: CGFloat = 88
    private static let space = "todayScroll"

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    credits.cascadeIn(0, trigger: developToken)
                    greeting.cascadeIn(1, trigger: developToken)
                    heroBlock.cascadeIn(2, trigger: developToken)
                    skyRow.moonSettle(trigger: developToken)
                    scopeSwitcher.cascadeIn(3, trigger: developToken)
                    headline.cascadeIn(4, trigger: developToken)
                    reading.cascadeIn(5, trigger: developToken)
                    HairlineDivider()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                        .cascadeIn(6, trigger: developToken)
                    mantra.cascadeIn(7, trigger: developToken)
                    Spacer(minLength: 30)
                    footer.cascadeIn(8, trigger: developToken)
                }
                .padding(.horizontal, 28)
                .padding(.top, 8)
                .padding(.bottom, 110) // clears the floating tab bar
                .frame(minHeight: geo.size.height, alignment: .top)
                .background(scrollReader)
            }
            .scrollIndicators(.hidden)
            .coordinateSpace(name: Self.space)
            .onPreferenceChange(ScrollOffsetKey.self) { handleScroll($0) }
        }
        .atmosphereScreen(aura: cycle.today?.phase.aura ?? Theme.ember)
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

    // MARK: Top credits (mono, in the corners like poster credits)

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

    /// "11 . 06 . 2026" — day . month . year, locale-independent like the mockup credit.
    private static let dateLine: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd . MM . yyyy"
        return f
    }()

    // MARK: The greeting (docs/07), now leading the page like a friend at the door

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
                .font(Theme.mono(10))
                .tracking(Theme.tracking(10, em: 0.26))
                .foregroundStyle(Theme.ember)
                .padding(.top, 30)
        }
    }

    // MARK: The hero — her body, first

    /// "DAY 24 · LUTEAL" and the phase's one-line vibe. The merged answer starts with her, not
    /// the sky. When no cycle is logged yet, a one-line invite points at the Cycle tab instead
    /// (a best friend notices what she doesn't know yet; she's never scolded).
    @ViewBuilder
    private var heroBlock: some View {
        if let state = cycle.today {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 14) {
                    Text("DAY \(state.cycleDay)")
                        .font(Theme.display(54).weight(.medium))
                        .tracking(Theme.tracking(54, em: 0.05))
                        .foregroundStyle(Theme.bone)
                    Text(state.phase.name)
                        .font(Theme.mono(12))
                        .tracking(Theme.tracking(12, em: 0.3))
                        .foregroundStyle(state.phase.aura)
                        .shadow(color: state.phase.aura.opacity(0.55), radius: 9)
                }
                Text(state.phase.tagline)
                    .font(Theme.body(16).italic())
                    .foregroundStyle(Theme.bone.opacity(0.72))
            }
            .padding(.top, 14)
        } else {
            Text("Half the answer lives in your cycle. Log it in the Cycle tab and I'll read the whole you.")
                .font(Theme.body(15).italic())
                .foregroundStyle(Theme.bone.opacity(0.6))
                .padding(.top, 16)
        }
    }

    // MARK: The sky row — the moon as seasoning, one tap from the full sheet

    private var skyRow: some View {
        Button {
            Haptics.open()
            showMoonSheet = true
        } label: {
            HStack(spacing: 16) {
                MoonView(diameter: moonDiameter, elongation: moonElongation)
                    .overlay { if isRefreshing { eclipseSweep } }
                VStack(alignment: .leading, spacing: 4) {
                    Text("THE SKY")
                        .font(Theme.mono(8.5))
                        .tracking(Theme.tracking(8.5, em: 0.22))
                        .foregroundStyle(Theme.gold.opacity(0.55))
                    Text(skyLine)
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.bone.opacity(0.78))
                        .contentTransition(.opacity)
                }
                Spacer()
                Text("→")
                    .font(Theme.mono(12))
                    .foregroundStyle(Theme.gold.opacity(0.5))
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 24)
    }

    private var skyLine: String {
        var parts = [String]()
        if moonPhaseFull != "READING THE SKY" { parts.append(moonPhaseFull) }
        if moonIllumPct > 0 { parts.append("\(moonIllumPct)% LIT") }
        if !moonSignName.isEmpty { parts.append("IN \(moonSignName)") }
        return parts.isEmpty ? "READING THE SKY" : parts.joined(separator: " · ")
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
        HStack(spacing: 26) {
            ForEach(HoroscopeService.Scope.allCases) { s in
                Button {
                    guard scope != s else { return }
                    Haptics.light()
                    scope = s
                    Task { await load() }
                } label: {
                    Text(s.label)
                        .font(Theme.mono(11))
                        .tracking(Theme.tracking(11, em: 0.2))
                        .foregroundStyle(scope == s ? Theme.bone : Theme.bone.opacity(0.32))
                        .overlay(alignment: .bottom) {
                            if scope == s {
                                Rectangle().fill(Theme.gold).frame(height: 1).offset(y: 6)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: scope)
        .padding(.top, 28)
    }

    // MARK: The reading block — one easy left-aligned column, every scope

    private var headline: some View {
        Text((horoscope?.headline ?? "CONSULTING THE SKY").uppercased())
            .font(Theme.display(24).weight(.medium))
            .tracking(Theme.tracking(24, em: 0.10)) // calmer tracking: editorial, not effortful
            .foregroundStyle(Theme.bone)
            .multilineTextAlignment(.leading)
            .lineSpacing(7)
            .contentTransition(.opacity) // crossfade on scope change, never a hard cut
            .padding(.top, 22)
    }

    private var readingText: String {
        horoscope?.reading ?? "The sky is loading your reading. Pull to refresh in a second."
    }

    /// Every scope reads as a left-aligned column now ("ease to your eyes" over poetry-centered,
    /// Maria, July 2). Monthly keeps its gold chapter labels.
    private var reading: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(Array(Self.paragraphs(readingText, detectLabels: true).enumerated()), id: \.offset) { _, para in
                VStack(alignment: .leading, spacing: 7) {
                    if let label = para.label {
                        Text(label)
                            .font(Theme.mono(10))
                            .tracking(Theme.tracking(10, em: 0.18))
                            .foregroundStyle(Theme.gold)
                    }
                    Text(para.body)
                        .font(Theme.body(15.5))
                        .foregroundStyle(Theme.bone.opacity(0.9))
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

    private var mantra: some View {
        Text(horoscope?.cardMantra ?? "BREATHE.")
            .font(Theme.display(15).weight(.medium))
            .tracking(Theme.tracking(15, em: 0.3))
            .foregroundStyle(Theme.bone)
            .multilineTextAlignment(.center)
            .contentTransition(.opacity)
            .frame(maxWidth: .infinity) // the poster's bottom-edge tagline, centered wide
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
            moonSignName = moon.sign.name.uppercased()
        }
        if let elongation = try? ChartEngine.moonElongation() {
            moonElongation = elongation
            // Illuminated fraction from the sun-moon elongation: (1 - cos θ) / 2, 0 = new, 1 = full.
            let illum = (1 - cos(elongation * .pi / 180)) / 2
            moonIllumPct = Int((illum * 100).rounded())
            if let phase = try? ChartEngine.moonPhase() {
                moonPhaseFull = phase.rawValue.uppercased()
            }
        }
    }
}

/// Reads the Today scroll view's top offset so the eclipse refresh can arm and fire without a
/// system spinner.
private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
