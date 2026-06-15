import SwiftUI

// MARK: - Cycle logging types
//
// Phase 2 (docs/01, docs/02, docs/06). Manual entry first. EVERYTHING here stays on-device: cycle
// data is the most sensitive thing the app holds and never goes server-side. The horoscope request
// receives only a derived phase string ("luteal, day 24"), never raw logs. This is wellness content,
// never medical: we describe typical patterns, we never claim to measure HER hormones, and the UI
// always carries the bridge to a real doctor for anything that feels extreme.

/// How heavy the bleeding was on a logged day. A day with any flow counts as a period day.
enum FlowLevel: String, Codable, CaseIterable, Identifiable {
    case spotting, light, medium, heavy
    var id: String { rawValue }
    var label: String { rawValue.uppercased() }
}

/// A light, non-clinical mood vocabulary in voice. Optional on any entry.
enum CycleMood: String, Codable, CaseIterable, Identifiable {
    case radiant, good, meh, tender, low, wired
    var id: String { rawValue }
    var label: String { rawValue.uppercased() }
}

/// Optional body signals. Pattern-tracking only, never a diagnosis.
enum CycleSymptom: String, Codable, CaseIterable, Identifiable {
    case cramps, headache, bloating, tender, lowEnergy, breakout, nausea, insomnia
    var id: String { rawValue }
    var label: String {
        switch self {
        case .lowEnergy: "LOW ENERGY"
        default: rawValue.uppercased()
        }
    }
}

/// One logged day. A day with `flow != nil` is a bleeding day; the rest is optional context.
struct CycleEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var date: Date                       // normalized to the start of the day
    var flow: FlowLevel? = nil
    var mood: CycleMood? = nil
    var symptoms: [CycleSymptom] = []
    var note: String? = nil

    var isBleeding: Bool { flow != nil }
}

// MARK: - The four phases

/// Rule-based phases (docs/02): menstrual / follicular / ovulatory / luteal. Each carries a short
/// "hormone weather" note: education about typical patterns, in girl, never a claim about her own
/// levels and never a diagnosis.
enum CyclePhase: String, Codable, CaseIterable {
    case menstrual, follicular, ovulatory, luteal

    var name: String { rawValue.uppercased() }

    /// One-line vibe for the big label area.
    var tagline: String {
        switch self {
        case .menstrual:  "rest is the assignment"
        case .follicular: "green light, building energy"
        case .ovulatory:  "peak, magnetic, on"
        case .luteal:     "slow down on purpose"
        }
    }

    /// The hormone-weather blurb. Typical patterns, friend-who-read-the-science voice.
    var hormoneNote: String {
        switch self {
        case .menstrual:
            return "Estrogen and progesterone are both at their lowest right now, which is exactly why you're tired and want everyone to leave you alone. Rest here isn't lazy, it's the whole point. Bleed, nap, repeat."
        case .follicular:
            return "Estrogen is climbing back up, so your energy, focus, and appetite for starting things are all rising with it. This is your green light. Begin the thing you've been circling."
        case .ovulatory:
            return "Estrogen peaks and you can feel it: you're magnetic, social, quick, and you know it. This is the window where saying yes pays off. Use it, then let the comedown be okay too."
        case .luteal:
            return "Progesterone is doing the most now, so if you're more sensitive, slower, or snappier, that's chemistry, not a character flaw. Lower the bar on purpose and protect your peace. Future-you will get it back."
        }
    }

    /// The accent the phase wears in the UI. Blood-wine for menstrual, ember/gold for the rest.
    var accent: Color {
        switch self {
        case .menstrual:  Theme.blood
        case .follicular: Theme.gold
        case .ovulatory:  Theme.ember
        case .luteal:     Theme.gold
        }
    }
}

// MARK: - Phase computation (pure, testable)

/// The resolved state of the cycle on a given day: where she is, and how confident we are.
struct CycleState {
    let cycleDay: Int        // 1-based day since the last period start
    let cycleLength: Int     // her average, or the 28-day default until we know better
    let phase: CyclePhase
    let isBleedingToday: Bool
    let nextPeriodInDays: Int

    /// What the horoscope receives, e.g. "luteal, day 24". Never raw logs.
    var horoscopeString: String { "\(phase.rawValue), day \(cycleDay)" }
}

/// Pure cycle math, no storage. Derives the current day and phase from logged period starts using
/// a simple, transparent rule set (refine later, per docs/02). Ovulation is estimated the classic
/// way, ~14 days before the next expected period.
enum CycleMath {
    static let defaultLength = 28
    static let defaultPeriodLength = 5

    private static func day(_ date: Date) -> Date { Calendar.current.startOfDay(for: date) }
    private static func daysBetween(_ a: Date, _ b: Date) -> Int {
        Calendar.current.dateComponents([.day], from: day(a), to: day(b)).day ?? 0
    }

    /// All bleeding days, ascending.
    private static func bleedingDays(_ entries: [CycleEntry]) -> [Date] {
        entries.filter(\.isBleeding).map { day($0.date) }.sorted()
    }

    /// First bleeding day of each distinct period: a bleeding day whose previous bleeding day was
    /// more than 2 days earlier (a gap of 2 days or less is treated as the same period run).
    static func periodStarts(_ entries: [CycleEntry]) -> [Date] {
        let days = bleedingDays(entries)
        var starts: [Date] = []
        var prev: Date?
        for d in days {
            if let p = prev, daysBetween(p, d) <= 2 {
                // continuation of the current run
            } else {
                starts.append(d)
            }
            prev = d
        }
        return starts
    }

    /// Average gap between consecutive period starts, clamped to a sane range. Default until known.
    static func averageLength(_ starts: [Date]) -> Int {
        guard starts.count >= 2 else { return defaultLength }
        var gaps: [Int] = []
        for i in 1..<starts.count { gaps.append(daysBetween(starts[i - 1], starts[i])) }
        let valid = gaps.filter { (18...45).contains($0) }
        guard !valid.isEmpty else { return defaultLength }
        return min(40, max(21, valid.reduce(0, +) / valid.count))
    }

    /// Resolve the cycle state on `date`, or nil if there's not enough history to be honest about it.
    static func state(entries: [CycleEntry], on date: Date = Date()) -> CycleState? {
        let today = day(date)
        let starts = periodStarts(entries).filter { $0 <= today }
        guard let lastStart = starts.last else { return nil }

        let cycleDay = daysBetween(lastStart, today) + 1
        guard cycleDay <= 60 else { return nil } // stale data; ask her to log rather than guess

        let length = averageLength(periodStarts(entries))
        let ovulation = max(10, length - 14)
        let isBleedingToday = entries.contains { $0.isBleeding && day($0.date) == today }

        let phase: CyclePhase
        if isBleedingToday || cycleDay <= defaultPeriodLength {
            phase = .menstrual
        } else if cycleDay < ovulation - 1 {
            phase = .follicular
        } else if cycleDay <= ovulation + 1 {
            phase = .ovulatory
        } else {
            phase = .luteal
        }

        let nextPeriodInDays = max(0, length - cycleDay + 1)
        return CycleState(cycleDay: cycleDay, cycleLength: length, phase: phase,
                          isBleedingToday: isBleedingToday, nextPeriodInDays: nextPeriodInDays)
    }
}
