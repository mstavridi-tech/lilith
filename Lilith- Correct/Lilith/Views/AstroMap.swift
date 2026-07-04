import SwiftUI
import CoreLocation

// MARK: - Astrocartography (approved by Maria; shipped July 4 evening)
//
// Relocation astrology in plain language: type a city, we recompute her chart's angles AS IF she'd
// been born there (same birth instant, new coordinates), and any natal planet that lands on the
// ASC / DESC / MC / IC there is a "line" she's living on in that place. Real math: the relocated
// ascendant comes from ChartEngine.natalChart with swapped coordinates, the MC from
// ChartEngine.midheaven. Weather, never verdicts, per the hard rule: a line describes a flavor,
// it never books the flight or blocks the move.

/// Which relocated angle a planet is sitting on.
enum MapAngle: String, CaseIterable {
    case rising = "RISING LINE"
    case setting = "SETTING LINE"
    case zenith = "ZENITH LINE"
    case root = "ROOT LINE"

    /// How the line colors a place, as a sentence opener.
    var context: String {
        switch self {
        case .rising: "wears you on the outside here. How you land in rooms, first impressions, the whole entrance"
        case .setting: "lives in your relationships here. Who you attract, what partnerships feel like"
        case .zenith: "crowns your public life here. Career, reputation, being seen"
        case .root: "settles into your foundations here. Home, rest, the private you"
        }
    }
}

/// One planet-on-angle hit for a searched place.
struct MapLine: Identifiable {
    let body: CelestialBody
    let angle: MapAngle
    let orb: Double
    var id: String { body.rawValue + angle.rawValue }
}

enum AstroMap {
    /// How close (in ecliptic degrees) a planet must sit to a relocated angle to count as a line.
    /// 6° keeps it honest: astrocartography maps classically show influence within a few hundred
    /// kilometers of the exact line.
    static let orb: Double = 6

    /// All lines active for her chart at the given coordinates, tightest first.
    static func lines(for chart: NatalChart, latitude: Double, longitude: Double) -> [MapLine] {
        guard chart.birthData.hasKnownTime, let moment = chart.birthData.utcMoment else { return [] }

        var reloc = chart.birthData
        reloc.latitude = latitude
        reloc.longitude = longitude
        guard let asc = (try? ChartEngine.natalChart(for: reloc))?.ascendant,
              let mc = try? ChartEngine.midheaven(at: moment, longitude: longitude)
        else { return [] }

        let angles: [(MapAngle, Double)] = [
            (.rising, asc), (.setting, asc + 180), (.zenith, mc), (.root, mc + 180)
        ]

        return chart.placements.flatMap { p in
            angles.compactMap { (angle, lon) in
                let sep = separation(p.longitude, lon)
                return sep <= orb ? MapLine(body: p.body, angle: angle, orb: sep) : nil
            }
        }
        .sorted { $0.orb < $1.orb }
    }

    private static func separation(_ a: Double, _ b: Double) -> Double {
        let d = abs((a - b).truncatingRemainder(dividingBy: 360))
        return min(d, 360 - d)
    }

    /// The flavor each planet pours into a line. In voice, one clause, composable with the
    /// angle's context sentence.
    static func flavor(_ body: CelestialBody) -> String {
        switch body {
        case .sun: return "Main character lighting. You feel more yourself, more visible, more seen."
        case .moon: return "Everything feels more, in the soft way and the soggy way. Deeply homey or deeply hormonal, sometimes both before lunch."
        case .mercury: return "Words flow, plans click, people text back. Great for study, deals, and finally sending the message."
        case .venus: return "Romance, beauty, and being adored come easier. You're prettier here, allegedly. The lore says go."
        case .mars: return "The drive turns all the way up. Gym era, bold asks, big energy, occasional beef. Pace yourself."
        case .jupiter: return "The luck line. Doors open a size bigger than you knocked. Classic pick for growth eras and fresh starts."
        case .saturn: return "The grind line. You'll build something real here and earn every brick of it. Respect it, don't romanticize it."
        case .uranus: return "Plot twists on tap. Nothing stays routine, which is either the dream or the nightmare depending on the week."
        case .neptune: return "Dreamy, artistic, and blurry at the edges. Gorgeous for creating, risky for boundaries and deposits."
        case .pluto: return "Intensity and reinvention. This kind of place doesn't host you, it remakes you. Transformative, not restful."
        case .northNode: return "The growth edge. Uncomfortable in the way that ages beautifully. The lore says your future self lives here."
        case .blackMoonLilith: return "The namesake line. Your wild, untamed, zero-apologies side gets the microphone here. Use responsibly or don't."
        }
    }
}

// MARK: - The sheet

struct AstroMapSheet: View {
    let chart: NatalChart
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""
    @State private var searching = false
    @State private var placeName: String?
    @State private var lines: [MapLine]?
    @State private var searchFailed = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("YOUR MAP")
                    .displayCaps(28, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(28, em: 0.14))
                    .padding(.top, 44)
                Text("Same you, different sky.")
                    .font(Theme.body(15).italic()).foregroundStyle(Theme.gold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)

                if chart.birthData.hasKnownTime {
                    intro
                    searchField
                    results
                } else {
                    Text("The map needs your birth time; without it there are no angles to relocate. Your mother knows. Ask her, update it in YOU, and this page comes alive.")
                        .font(Theme.body(15)).foregroundStyle(Theme.ember)
                        .lineSpacing(6)
                        .padding(.top, 30)
                }

                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 44)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: "✶", accent: Theme.gold)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
    }

    private var intro: some View {
        Text("Type a city you're eyeing: the trip, the maybe-move, the ex's hometown, whatever. I recompute your chart as if you'd been born under that sky and tell you which of your planets run the place.")
            .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.85))
            .lineSpacing(6)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 26)
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            TextField("city, country", text: $query)
                .font(Theme.body(16)).foregroundStyle(Theme.bone)
                .tint(Theme.gold)
                .autocorrectionDisabled()
                .onSubmit { Task { await search() } }
            Button {
                Haptics.light()
                Task { await search() }
            } label: {
                if searching {
                    ProgressView().tint(Theme.gold)
                } else {
                    Text("LOOK UP")
                        .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.16))
                        .foregroundStyle(Theme.gold)
                }
            }
            .buttonStyle(.plain)
            .disabled(searching || query.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.bone.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Theme.gold.opacity(0.3), lineWidth: 0.5))
        )
        .padding(.top, 20)
    }

    @ViewBuilder private var results: some View {
        if searchFailed {
            Text("Couldn't find that one. Check the spelling, or try the nearest big city.")
                .font(Theme.body(14)).foregroundStyle(Theme.ember)
                .padding(.top, 22)
        } else if let placeName, let lines {
            Text(placeName.uppercased())
                .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.2))
                .foregroundStyle(Theme.ember)
                .padding(.top, 30)

            if lines.isEmpty {
                Text("No major lines running through here. Neutral ground: nothing cosmic pushing, nothing pulling. Honestly? Sometimes that's exactly the holiday.")
                    .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.85))
                    .lineSpacing(6)
                    .padding(.top, 12)
            } else {
                ForEach(lines) { line in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(line.body.glyph)
                                .font(Theme.display(18))
                                .foregroundStyle(line.body == .blackMoonLilith ? Theme.ember : Theme.gold)
                            Text("\(line.body.displayName.uppercased()) · \(line.angle.rawValue)")
                                .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.14))
                                .foregroundStyle(Theme.bone)
                            Spacer()
                            Text(String(format: "%.1f°", line.orb))
                                .font(Theme.mono(10))
                                .foregroundStyle(Theme.gold.opacity(0.7))
                        }
                        Text("\(line.body.displayName) \(line.angle.context). \(AstroMap.flavor(line.body))")
                            .font(Theme.body(14.5)).foregroundStyle(Theme.bone.opacity(0.85))
                            .lineSpacing(5)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.vertical, 16)
                    if line.id != lines.last?.id {
                        Rectangle().fill(Theme.gold.opacity(0.12)).frame(height: 0.5)
                    }
                }
            }

            Text("Weather, not verdicts. A line colors a place, it doesn't decide for you.")
                .font(Theme.body(12).italic()).foregroundStyle(Theme.gold.opacity(0.65))
                .padding(.top, 16)
        }
    }

    private func search() async {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return }
        searching = true
        searchFailed = false
        defer { searching = false }
        do {
            let hits = try await CLGeocoder().geocodeAddressString(q)
            guard let spot = hits.first, let loc = spot.location else {
                searchFailed = true; return
            }
            let name = [spot.locality ?? spot.name, spot.country].compactMap { $0 }
                .joined(separator: ", ")
            placeName = name
            lines = AstroMap.lines(for: chart,
                                   latitude: loc.coordinate.latitude,
                                   longitude: loc.coordinate.longitude)
            Haptics.soft()
        } catch {
            searchFailed = true
        }
    }
}
