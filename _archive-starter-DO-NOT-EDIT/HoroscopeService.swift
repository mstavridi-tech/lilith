import Foundation

/// Fetches AI-written horoscopes from the LILITH backend.
/// The backend holds the Claude API key — NEVER put an API key in the app.
///
/// Privacy by design: we send placements and transits only. No name, no email,
/// no device ID. The backend cannot identify anyone.
struct HoroscopeService {

    /// Set this once the Vercel function is deployed (see docs/02-ARCHITECTURE.md).
    static var backendURL = URL(string: "https://YOUR-PROJECT.vercel.app/api/horoscope")!

    struct DailyRequest: Codable {
        let bigThree: String           // "Leo sun, Scorpio moon, Capricorn rising"
        let natalSummary: [String]     // formatted placements
        let currentTransits: [String]  // today's sky, formatted
        let moonPhase: String
        let scope: String              // "daily" or "monthly"
        // Phase 2 will add: let cyclePhase: String?  ("luteal day 26", etc.)
    }

    struct HoroscopeResponse: Codable {
        let headline: String   // "THE AUDACITY OF THIS MOON."
        let reading: String    // the main horoscope text
        let affirmation: String
    }

    static func fetchDaily(chart: NatalChart) async throws -> HoroscopeResponse {
        let sky = try ChartEngine.currentSky()
        let phase = try ChartEngine.moonPhase()

        let request = DailyRequest(
            bigThree: chart.bigThree,
            natalSummary: chart.placements.map(\.formatted),
            currentTransits: sky.map(\.formatted),
            moonPhase: phase.rawValue,
            scope: "daily"
        )

        var urlRequest = URLRequest(url: backendURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        urlRequest.timeoutInterval = 15

        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                return fallback(chart: chart, moonPhase: phase)
            }
            return try JSONDecoder().decode(HoroscopeResponse.self, from: data)
        } catch {
            // Offline or backend down — the app never feels dead.
            return fallback(chart: chart, moonPhase: phase)
        }
    }

    /// Templated offline reading from real transit data. Less personal, still in voice.
    private static func fallback(chart: NatalChart, moonPhase: MoonPhase) -> HoroscopeResponse {
        HoroscopeResponse(
            headline: "THE STARS ARE BUFFERING.",
            reading: "The \(moonPhase.rawValue.lowercased()) is doing its thing and so are you, \(chart.bigThree). Full reading is loading. The cosmos respects your patience exactly as much as you respect other people's, so. Pull to refresh in a minute.",
            affirmation: "Even offline, you are the moment."
        )
    }
}
