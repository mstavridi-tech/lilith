import Foundation
import Combine

/// The on-device home for cycle logs. NOTHING here ever leaves the phone (docs/02 hard rule): the
/// entries persist to UserDefaults as JSON, and only a derived phase string is ever handed to the
/// horoscope. A lightweight store on purpose for this first cut, flagged in place of SwiftData so
/// it can't break the build; migrate when HealthKit and heavier querying arrive.
final class CycleStore: ObservableObject {
    static let shared = CycleStore()

    @Published private(set) var entries: [CycleEntry] = []

    private let key = "lilith.cycle.entries"

    init() { entries = Self.load(key: key) }

    // MARK: Derived state

    /// Where she is today, or nil until there's enough history to be honest about it.
    var today: CycleState? { CycleMath.state(entries: entries, on: Date()) }

    /// The entry for a given day, if she logged one.
    func entry(on date: Date) -> CycleEntry? {
        let d = Calendar.current.startOfDay(for: date)
        return entries.first { Calendar.current.startOfDay(for: $0.date) == d }
    }

    /// Recent entries, newest first.
    func recent(_ limit: Int = 14) -> [CycleEntry] {
        entries.sorted { $0.date > $1.date }.prefix(limit).map { $0 }
    }

    // MARK: Mutations

    /// Create or replace the entry for its day, then persist. An entry with no flow, mood, symptoms,
    /// or note is treated as a deletion so toggling a day off leaves no empty husk behind.
    func save(_ entry: CycleEntry) {
        let d = Calendar.current.startOfDay(for: entry.date)
        entries.removeAll { Calendar.current.startOfDay(for: $0.date) == d }
        let isEmpty = entry.flow == nil && entry.mood == nil && entry.symptoms.isEmpty
            && (entry.note?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        if !isEmpty {
            var e = entry
            e.date = d
            entries.append(e)
        }
        persist()
    }

    func delete(on date: Date) {
        let d = Calendar.current.startOfDay(for: date)
        entries.removeAll { Calendar.current.startOfDay(for: $0.date) == d }
        persist()
    }

    /// One-tap "my period started today" (or toggle it back off). Defaults to medium flow.
    func togglePeriodToday() {
        let d = Calendar.current.startOfDay(for: Date())
        if let existing = entry(on: d), existing.isBleeding {
            var e = existing; e.flow = nil; save(e)
        } else {
            var e = entry(on: d) ?? CycleEntry(date: d)
            e.flow = .medium
            save(e)
        }
    }

    /// Wipe everything. For the Settings "delete my data" promise.
    func deleteAll() {
        entries = []
        UserDefaults.standard.removeObject(forKey: key)
    }

    // MARK: Persistence

    private func persist() {
        entries.sort { $0.date < $1.date }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private static func load(key: String) -> [CycleEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([CycleEntry].self, from: data)
        else { return [] }
        return decoded
    }

    // MARK: For the horoscope (read straight from storage, no view dependency)

    /// The phase string the horoscope request carries, e.g. "luteal, day 24", or nil if she hasn't
    /// logged enough to know. Computed from persisted entries so it's safe to call off the main view.
    static func currentPhaseString() -> String? {
        CycleMath.state(entries: load(key: "lilith.cycle.entries"), on: Date())?.horoscopeString
    }
}
