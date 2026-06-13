import SwiftUI

/// The home screen and the product: today's reading, designed to be screenshotted.
/// Layout is the APPROVED v7 card (docs/design/today-card-mockup.html): everything centered,
/// real moon up top ringed by hairline geometry, mono credits in the corners, ember eyebrow,
/// letterspaced serif headline, capped reading, diamond divider, caps mantra, big three + wordmark.
///
/// The lure pass (docs/08) adds the craft on top of that layout: the card develops instead of
/// popping, the sky drifts in parallax behind it, pull-to-refresh is the signature eclipse (never a
/// spinner), and the screen answers her touch with restrained haptics.
struct TodayView: View {
    let chart: NatalChart
    @State private var horoscope: HoroscopeService.HoroscopeResponse?
    @State private var moonStatus = "☽ READING THE SKY"
    @State private var moonCaption = "READING THE SKY" // phase name + % lit, named plainly under the moon
    @State private var moonElongation: Double = 180 // tonight's real phase; full until loaded
    @State private var scope: HoroscopeService.Scope = .daily        // the selected tab (underline)
    @State private var displayScope: HoroscopeService.Scope = .daily // what the reading actually shows
    @State private var showMoonSheet = false

    // Lure-pass state
    @State private var developToken = 0       // bumps once per fresh load; drives the cascade
    @State private var scrollY: CGFloat = 0    // top offset, for parallax + custom pull-to-refresh
    @State private var armed = false           // over-pulled past the threshold, waiting for release
    @State private var isRefreshing = false    // the eclipse is sweeping

    private let moonDiameter: CGFloat = 234 // v9: bigger, floating free in black
    private let pullThreshold: CGFloat = 88
    private static let space = "todayScroll"

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    credits.cascadeIn(0, trigger: developToken)
                    moonBlock
                    moonCaptionView.cascadeIn(1, trigger: developToken)
                    scopeSwitcher.cascadeIn(1, trigger: developToken)
                    eyebrow.cascadeIn(2, trigger: developToken)
                    headline.cascadeIn(3, trigger: developToken)
                    reading.cascadeIn(4, trigger: developToken)
                    HairlineDivider().padding(.top, 22).cascadeIn(5, trigger: developToken)
                    mantra.cascadeIn(6, trigger: developToken)
                    Spacer(minLength: 30)
                    footer.cascadeIn(7, trigger: developToken)
                }
                .padding(.horizontal, 30)
                .padding(.top, 8)
                .padding(.bottom, 28)
                // At LEAST the viewport tall so the footer pins above the tab bar on a short
                // daily, but free to grow past it so a long weekly or monthly reading shows in
                // full and scrolls. Never a fixed height, which is what truncated the reading.
                .frame(minHeight: geo.size.height, alignment: .top)
                .background(scrollReader)
            }
            .scrollIndicators(.hidden)
            .coordinateSpace(name: Self.space)
            .onPreferenceChange(ScrollOffsetKey.self) { handleScroll($0) }
        }
        .cosmicScreen(bloomAlignment: .top, bloomIntensity: 1, parallax: parallaxOffset)
        .task { await load() }
        .sheet(isPresented: $showMoonSheet) { MoonSheet(chart: chart) }
    }

    // MARK: Scroll plumbing (parallax + the custom, spinner-free pull-to-refresh)

    private var scrollReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(key: ScrollOffsetKey.self,
                                   value: proxy.frame(in: .named(Self.space)).minY)
        }
    }

    /// The sky drifts a fraction of the scroll, slower than the content, for depth. Clamped so it
    /// can never wander far from home.
    private var parallaxOffset: CGFloat {
        max(-60, min(60, scrollY * 0.10))
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

    // MARK: The moon, floating free in the black (v9: no rings, the photo carries it)

    private var moonBlock: some View {
        MoonView(diameter: moonDiameter, elongation: moonElongation)
            .frame(height: moonDiameter + 40)
            .overlay { if isRefreshing { eclipseSweep } }
            .contentShape(Rectangle())
            .onTapGesture {
                Haptics.open()
                showMoonSheet = true
            }
            .padding(.top, 24)
            .moonSettle(trigger: developToken)
    }

    /// The phase, named plainly right under the moon, with how lit it is tonight. So the cycle is
    /// always legible even when the disc itself is near-full and the shadow is only a sliver.
    private var moonCaptionView: some View {
        Text(moonCaption.isEmpty ? "READING THE SKY" : moonCaption)
            .font(Theme.mono(11))
            .tracking(Theme.tracking(11, em: 0.22))
            .foregroundStyle(Theme.gold.opacity(0.92))
            .multilineTextAlignment(.center)
            .contentTransition(.opacity)
            .padding(.top, 6)
    }

    /// The signature pull-to-refresh: while loading, the terminator shadow sweeps across the moon,
    /// again and again until the reading lands. An eclipse, never a spinner (docs/08). Driven by
    /// wall-clock time so it auto-stops the instant `isRefreshing` flips off.
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
        .padding(.top, 24)
    }

    // MARK: The reading block

    /// The time-aware greeting eyebrow (docs/07), as a pure function of the hour (0...23) and the
    /// day index so it is unit-testable. Hour bands cover all 24 hours with no gaps:
    /// 5...11 morning, 12...16 afternoon, 17...21 evening, everything else (22, 23, 0...4) late.
    /// Morning slots are Maria's locked signatures. The two phrases per slot alternate by day.
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

    /// TimelineView recomputes the greeting every minute, so the eyebrow can never go stale: if
    /// the app sits open across an hour boundary (the real cause of "UP LATE" showing at 11am),
    /// it still flips to the correct slot on its own.
    private var eyebrow: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            Text(currentGreeting(context.date))
                .font(Theme.mono(10))
                .tracking(Theme.tracking(10, em: 0.26))
                .foregroundStyle(Theme.ember)
                .multilineTextAlignment(.center)
                .padding(.top, 26)
        }
    }

    private var headline: some View {
        Text((horoscope?.headline ?? "CONSULTING THE SKY").uppercased())
            .font(Theme.display(23).weight(.medium))
            .tracking(Theme.tracking(23, em: 0.19))
            .foregroundStyle(Theme.bone)
            .multilineTextAlignment(.center)
            .lineSpacing(8)
            .contentTransition(.opacity) // crossfade on scope change, never a hard cut
            .padding(.leading, Theme.tracking(23, em: 0.19)) // recenter the letterspacing
            .padding(.top, 14)
    }

    private var readingText: String {
        horoscope?.reading ?? "The sky is loading your reading. Pull to refresh in a second."
    }

    /// Daily stays centered and poetic. Weekly and monthly become left-aligned reading columns
    /// with paragraph spacing (docs/03 long-form rule); monthly chapters get gold mono labels.
    @ViewBuilder
    private var reading: some View {
        if displayScope == .daily {
            Text(readingText)
                .font(Theme.body(15))
                .foregroundStyle(Theme.bone.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .frame(maxWidth: 272)
                .fixedSize(horizontal: false, vertical: true) // never truncate
                .contentTransition(.opacity)
                .padding(.top, 16)
        } else {
            longFormReading
        }
    }

    /// Both weekly and monthly carry the simple gold section labels Maria liked on monthly (THE ARC,
    /// KEY DATES, and so on): any short ALL-CAPS line ending in ":" becomes a gold mono label.
    private var longFormReading: some View {
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
                        .font(Theme.body(15))
                        .foregroundStyle(Theme.bone.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .lineSpacing(10) // ~1.7 line-height at 15pt, a comfortable reading column
                        .fixedSize(horizontal: false, vertical: true) // full height, never an ellipsis
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 4) // a touch more inset so the column reads like a book, not edge to edge
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 18)
    }

    /// One paragraph of a long-form reading, with an optional gold section label (monthly only).
    private struct Paragraph { let label: String?; let body: String }

    /// Split a reading into paragraphs on blank lines (the backend normalizes to "\n\n"). When
    /// detectLabels is on (monthly), a short ALL-CAPS first line ending in ":" becomes the label.
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
    }

    // MARK: Loading

    /// Cache-first. Runs on appear, tab switch, and scope switch. Costs ZERO network calls when
    /// this scope is already cached for today; only the first view of a scope per day fetches.
    /// The develop cascade fires only on the very first content load (never on a tab return); scope
    /// switches crossfade the text instead.
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
            // Swap the content and the rendered scope together, so the reading never shows the old
            // scope's text in the new scope's layout (the weekly "glitch"). One clean crossfade.
            withAnimation(.easeInOut(duration: 0.3)) {
                horoscope = new
                displayScope = target
            }
        }
    }

    /// Pull-to-refresh: the one manual override that always re-fetches from the backend. Develops
    /// the card again when the fresh reading lands.
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

    /// Tonight's moon status and phase for the card. Pure local math, never a network call.
    private func updateSky() {
        if let moon = (try? ChartEngine.currentSky())?.first(where: { $0.body == .moon }),
           let phase = try? ChartEngine.moonPhase() {
            moonStatus = "☽ \(phase.shortLabel) · \(Int(moon.degreeInSign))° \(moon.sign.name.prefix(3).uppercased())"
        }
        if let elongation = try? ChartEngine.moonElongation() {
            moonElongation = elongation
            // Illuminated fraction from the sun-moon elongation: (1 - cos θ) / 2, 0 = new, 1 = full.
            let illum = (1 - cos(elongation * .pi / 180)) / 2
            if let phase = try? ChartEngine.moonPhase() {
                moonCaption = "\(phase.rawValue.uppercased()) · \(Int((illum * 100).rounded()))% LIT"
            }
        }
    }
}

/// Reads the Today scroll view's top offset so the backdrop can parallax and the eclipse refresh
/// can arm and fire without a system spinner.
private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}
