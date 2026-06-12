import SwiftUI

/// The home screen and the product: today's reading, designed to be screenshotted.
/// Layout is the APPROVED v7 card (docs/design/today-card-mockup.html): everything centered,
/// real moon up top ringed by hairline geometry, mono credits in the corners, ember eyebrow,
/// letterspaced serif headline, capped reading, diamond divider, caps mantra, big three + wordmark.
struct TodayView: View {
    let chart: NatalChart
    @State private var horoscope: HoroscopeService.HoroscopeResponse?
    @State private var moonStatus = "☽ READING THE SKY"
    @State private var moonElongation: Double = 180 // tonight's real phase; full until loaded
    @State private var scope: HoroscopeService.Scope = .daily
    @State private var showMoonSheet = false

    private let moonDiameter: CGFloat = 234 // v9: bigger, floating free in black

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    credits
                    moonBlock
                    scopeSwitcher
                    eyebrow
                    headline
                    reading
                    HairlineDivider().padding(.top, 22)
                    mantra
                    Spacer(minLength: 30)
                    footer
                }
                .padding(.horizontal, 30)
                .padding(.top, 8)
                .padding(.bottom, 28)
                // At LEAST the viewport tall so the footer pins above the tab bar on a short
                // daily, but free to grow past it so a long weekly or monthly reading shows in
                // full and scrolls. Never a fixed height, which is what truncated the reading.
                .frame(minHeight: geo.size.height, alignment: .top)
            }
            .scrollIndicators(.hidden)
            .refreshable { await refresh() }
        }
        .cosmicScreen(bloomAlignment: .top, bloomIntensity: 1)
        .task { await load() }
        .sheet(isPresented: $showMoonSheet) { MoonSheet(chart: chart) }
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
            .padding(.top, 24)
            .contentShape(Rectangle())
            .onTapGesture { showMoonSheet = true }
    }

    // MARK: Scope — DAILY / WEEKLY / MONTHLY (all hit the same backend, docs/06)

    private var scopeSwitcher: some View {
        HStack(spacing: 26) {
            ForEach(HoroscopeService.Scope.allCases) { s in
                Button {
                    guard scope != s else { return }
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
        if scope == .daily {
            Text(readingText)
                .font(Theme.body(15))
                .foregroundStyle(Theme.bone.opacity(0.82))
                .multilineTextAlignment(.center)
                .lineSpacing(5)
                .frame(maxWidth: 272)
                .fixedSize(horizontal: false, vertical: true) // never truncate
                .padding(.top, 16)
        } else {
            longFormReading
        }
    }

    private var longFormReading: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(Array(Self.paragraphs(readingText, detectLabels: scope == .monthly).enumerated()), id: \.offset) { _, para in
                VStack(alignment: .leading, spacing: 7) {
                    if let label = para.label {
                        Text(label)
                            .font(Theme.mono(10))
                            .tracking(Theme.tracking(10, em: 0.18))
                            .foregroundStyle(Theme.gold)
                    }
                    Text(para.body)
                        .font(Theme.body(15))
                        .foregroundStyle(Theme.bone.opacity(0.82))
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

    /// Cache-first. Runs on appear, tab switch, and scope switch. Costs ZERO network calls when
    /// this scope is already cached for today; only the first view of a scope per day fetches.
    private func load() async {
        updateSky()
        horoscope = await HoroscopeService.reading(chart: chart, scope: scope)
    }

    /// Pull-to-refresh: the one manual override that always re-fetches from the backend.
    private func refresh() async {
        updateSky()
        horoscope = await HoroscopeService.refresh(chart: chart, scope: scope)
    }

    /// Tonight's moon status and phase for the card. Pure local math, never a network call.
    private func updateSky() {
        if let moon = (try? ChartEngine.currentSky())?.first(where: { $0.body == .moon }),
           let phase = try? ChartEngine.moonPhase() {
            moonStatus = "☽ \(phase.shortLabel) · \(Int(moon.degreeInSign))° \(moon.sign.name.prefix(3).uppercased())"
        }
        if let elongation = try? ChartEngine.moonElongation() {
            moonElongation = elongation
        }
    }
}
