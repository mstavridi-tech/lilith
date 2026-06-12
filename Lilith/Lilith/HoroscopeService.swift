import Foundation

/// Fetches AI-written horoscopes from the LILITH backend.
/// The backend holds the Claude API key — NEVER put an API key in the app.
///
/// Privacy by design: we send placements and transits only. No name, no email,
/// no device ID. The backend cannot identify anyone.
struct HoroscopeService {

    /// The deployed Vercel function (see backend/ and docs/02-ARCHITECTURE.md). If `vercel --prod`
    /// printed a different production domain, this one line is what changes.
    static var backendURL = URL(string: "https://lilith-horoscope-gamma.vercel.app/api/horoscope")!

    /// The reading's time horizon. All three hit the same backend with the `scope` field
    /// (docs/06); until the backend exists each has its own in-voice offline fallback.
    enum Scope: String, CaseIterable, Identifiable {
        case daily, weekly, monthly
        var id: String { rawValue }
        /// Small-caps tab label.
        var label: String { rawValue.uppercased() }
    }

    struct DailyRequest: Codable {
        let bigThree: String              // "Leo sun, Scorpio moon, Capricorn rising"
        let natalSummary: [String]        // formatted placements
        let currentTransits: [String]     // today's sky, formatted
        let moonPhase: String
        let scope: String                 // "daily" | "weekly" | "monthly"
        let yesterdayHeadline: String?    // so the engine never repeats itself two days running
        let cyclePhase: String?           // Phase 2: "luteal, day 24". Always nil for now.
    }

    struct HoroscopeResponse: Codable {
        let headline: String       // "THE AUDACITY OF THIS MOON."
        let reading: String        // the main horoscope text, capped ~4 short sentences
        let affirmation: String    // full sentence; lives in the PUSH, never on the card (see docs/03)
        let mantra: String?        // 2 to 5 words for the card, e.g. "SAY LESS." Optional so older
                                   // responses still decode; the card derives one when it's missing.

        /// The card mantra, letterspaced caps. Falls back to a short cut of the affirmation
        /// so the card always has its closing line even before the backend sends a real mantra.
        var cardMantra: String {
            if let mantra, !mantra.trimmingCharacters(in: .whitespaces).isEmpty {
                return mantra.uppercased()
            }
            // First clause of the affirmation, trimmed to a few words, ending clean.
            let firstClause = affirmation.split(whereSeparator: { ",.;:".contains($0) }).first.map(String.init) ?? affirmation
            let words = firstClause.split(separator: " ").prefix(4).joined(separator: " ")
            return words.uppercased() + "."
        }
    }

    // MARK: - Public API (cache-first, so the app stops paying API credit just for being open)

    /// Today's reading for a scope. Served instantly from the on-device cache whenever possible.
    /// Hits the network ONLY when there is no cached reading for this scope today (the day rolled
    /// over, the chart changed, or it has never been fetched today). Tab switches, scope switches,
    /// and same-day relaunches therefore cost ZERO network calls. Never throws: returns the
    /// in-voice offline fallback if a needed fetch fails.
    static func reading(chart: NatalChart, scope: Scope) async -> HoroscopeResponse {
        if let cached = cachedReading(scope: scope, chart: chart) {
            return cached
        }
        return await fetchAndCache(chart: chart, scope: scope)
    }

    /// Pull-to-refresh: the one manual override that always re-fetches. Still cheap, because the
    /// backend dedupes identical (scope + date + chart) requests in its own cache.
    static func refresh(chart: NatalChart, scope: Scope) async -> HoroscopeResponse {
        await fetchAndCache(chart: chart, scope: scope)
    }

    /// Convenience for the default daily card.
    static func fetchDaily(chart: NatalChart) async -> HoroscopeResponse {
        await reading(chart: chart, scope: .daily)
    }

    /// Fetch from the backend and, on a real success, store it in the on-device cache. Fallbacks
    /// are never cached, so a transient outage retries next time instead of sticking all day.
    private static func fetchAndCache(chart: NatalChart, scope: Scope) async -> HoroscopeResponse {
        do {
            let response = try await fetchFromBackend(chart: chart, scope: scope)
            store(response, scope: scope, chart: chart)
            rememberHeadline(response.headline, scope: scope) // only real readings seed "yesterday"
            return response
        } catch {
            let phase = (try? ChartEngine.moonPhase()) ?? .fullMoon
            return fallback(chart: chart, moonPhase: phase, scope: scope)
        }
    }

    /// The network call. Throws on any failure so the caller decides whether to fall back; it does
    /// NOT substitute a fallback itself, because a fallback must never be written to the cache.
    private static func fetchFromBackend(chart: NatalChart, scope: Scope) async throws -> HoroscopeResponse {
        let sky = try ChartEngine.currentSky()
        let phase = try ChartEngine.moonPhase()

        let request = DailyRequest(
            bigThree: chart.bigThree,
            natalSummary: chart.placements.map(\.formatted),
            currentTransits: sky.map(\.formatted),
            moonPhase: phase.rawValue,
            scope: scope.rawValue,
            yesterdayHeadline: lastHeadline(scope),
            cyclePhase: nil
        )

        var urlRequest = URLRequest(url: backendURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue(sharedSecret, forHTTPHeaderField: "x-lilith-key")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        // Monthly is a long Sonnet "deep read" (280 to 380 words) and a cold call can run ~35s.
        urlRequest.timeoutInterval = 45

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw ServiceError.badStatus
        }
        return try JSONDecoder().decode(HoroscopeResponse.self, from: data)
    }

    enum ServiceError: Error { case badStatus }

    /// Shared secret between app and backend, sent as the x-lilith-key header. The backend rejects
    /// requests without it. This is a soft gate (it ships in the binary), not a true secret, but it
    /// stops the endpoint from being hit and billed by random callers. Must match the Vercel
    /// LILITH_SHARED_SECRET env var.
    private static let sharedSecret = "d420cb1704434aeb0e9117d15915a8452207a3631f967b05"

    // MARK: - On-device cache (keyed by scope + date)

    private struct CachedReading: Codable {
        let date: String        // local yyyy-MM-dd the reading was fetched for
        let bigThree: String    // chart identity, so editing birth data invalidates stale readings
        let response: HoroscopeResponse
    }

    private static func cacheKey(_ scope: Scope) -> String { "lilith.reading.\(scope.rawValue)" }

    /// Today in the user's local calendar as yyyy-MM-dd, so the cache rolls over at local midnight.
    private static func todayString() -> String {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    /// A cached reading for this scope IF it is for today and the same chart, else nil.
    private static func cachedReading(scope: Scope, chart: NatalChart) -> HoroscopeResponse? {
        guard let data = UserDefaults.standard.data(forKey: cacheKey(scope)),
              let entry = try? JSONDecoder().decode(CachedReading.self, from: data),
              entry.date == todayString(),
              entry.bigThree == chart.bigThree
        else { return nil }
        return entry.response
    }

    private static func store(_ response: HoroscopeResponse, scope: Scope, chart: NatalChart) {
        let entry = CachedReading(date: todayString(), bigThree: chart.bigThree, response: response)
        if let data = try? JSONEncoder().encode(entry) {
            UserDefaults.standard.set(data, forKey: cacheKey(scope))
        }
    }

    /// Drop all cached readings. Call when birth data changes or is deleted so a new chart never
    /// shows the previous person's reading.
    static func clearCache() {
        for scope in Scope.allCases {
            UserDefaults.standard.removeObject(forKey: cacheKey(scope))
            UserDefaults.standard.removeObject(forKey: headlineKey(scope))
        }
    }

    // The last real headline we showed per scope, so the engine can avoid repeating itself.
    private static func headlineKey(_ scope: Scope) -> String { "lilith.lastHeadline.\(scope.rawValue)" }
    private static func lastHeadline(_ scope: Scope) -> String? {
        UserDefaults.standard.string(forKey: headlineKey(scope))
    }
    private static func rememberHeadline(_ headline: String, scope: Scope) {
        UserDefaults.standard.set(headline, forKey: headlineKey(scope))
    }

    /// Templated offline reading from real transit data. Less personal, still in voice.
    /// One per scope so a girl switching tabs offline never sees the same buffering line twice.
    private static func fallback(chart: NatalChart, moonPhase: MoonPhase, scope: Scope) -> HoroscopeResponse {
        let phase = moonPhase.rawValue.lowercased()
        switch scope {
        case .daily:
            return HoroscopeResponse(
                headline: "THE STARS ARE BUFFERING.",
                reading: "The \(phase) is doing its thing and so are you, \(chart.bigThree). Full reading is loading. The cosmos respects your patience exactly as much as you respect other people's, so. Pull to refresh in a minute.",
                affirmation: "Even offline, you are the moment.",
                mantra: "STILL THE MOMENT."
            )
        case .weekly:
            return HoroscopeResponse(
                headline: "THE WEEK IS STILL DEVELOPING.",
                reading: "Your week is loading, \(chart.bigThree). The \(phase) sets the tone and the rest is on its way. Sunday-you is allowed to plan in pencil. Pull to refresh and the full forecast lands.",
                affirmation: "You get to begin again every single week.",
                mantra: "PLAN IN PENCIL."
            )
        case .monthly:
            return HoroscopeResponse(
                headline: "THE MONTH IS WRITING ITSELF.",
                reading: "The month's arc is loading, \(chart.bigThree). The \(phase) is just the opening line. Big stories take a second to render, and so do good ones. Pull to refresh for the whole chapter.",
                affirmation: "You are the main character of this month, not a side plot.",
                mantra: "LET IT UNFOLD."
            )
        }
    }
}
