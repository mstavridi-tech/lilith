import Foundation
import UserNotifications

// MARK: - The care logic (July 6, Maria: "I need you to calculate and work out by standard when
// she needs to do it... I want all this worked out.")
//
// The standards, sourced and encoded (guidelines differ by country; these are the widely-used
// defaults, and THE FINE PRINT says her provider sets her real schedule):
//   PAP SMEAR      every 3 years (USPSTF: cytology every 3y under 30; many national programs 3-5y)
//   STI TEST       yearly when sexually active (CDC baseline), PLUS ~2 weeks after a new partner
//                  (that's when common chlamydia/gonorrhea tests turn reliable; HIV and syphilis
//                  need 6+ weeks, which the in-app note says out loud)
//   GYNO VISIT     yearly (the well-woman visit)
//   BREAST CHECK   self-check monthly, ideally a few days after the period ends (breasts least
//                  tender then); professional checks per her provider
//   IVF            no standard cadence; her clinic runs that calendar, we never invent one
//
// Delivery: LOCAL notifications only (no server, no push entitlement needed). And the hard rule
// holds: the lock screen NEVER says what the reminder is. Vault business stays vault business.

enum Care {

    /// Days until the next one is due, per kind. IVF returns nil on purpose.
    static func interval(for kind: VaultKind) -> Int? {
        switch kind {
        case .papSmear: 365 * 3
        case .sti: 365
        case .gyno: 365
        case .breastCheck: 30
        case .ivf: nil
        }
    }

    /// The friend sentence for the vault shelf: when the next one is due, computed from her last log.
    static func nextDueLine(for kind: VaultKind, lastDone: Date) -> String? {
        guard let days = interval(for: kind),
              let due = Calendar.current.date(byAdding: .day, value: days, to: lastDone) else { return nil }
        let f = DateFormatter(); f.dateFormat = "MMM yyyy"
        switch kind {
        case .papSmear: return "Next one's due around \(f.string(from: due)), by the every-3-years standard. Your provider may say sooner; they win."
        case .sti: return "Routine rhythm says around \(f.string(from: due)), sooner with a new partner."
        case .gyno: return "The yearly check-in points to \(f.string(from: due))."
        case .breastCheck: return "Next self-check in about a month, a few days after your period ends."
        case .ivf: return nil
        }
    }

    // MARK: Scheduling (discreet, local, replaceable)

    private static func requestPermission(_ then: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted { DispatchQueue.main.async(execute: then) }
        }
    }

    /// The lock screen never says what it is. She asked us to remember; that's all it admits.
    private static let discreetLines = [
        "That thing you asked me to remember? It's time. Open me.",
        "A little date with yourself is due, babe. Open me.",
        "Health admin day. Two minutes, in and out. Open me."
    ]

    private static func schedule(id: String, in days: Int, lineIndex: Int) {
        requestPermission {
            let content = UNMutableNotificationContent()
            content.title = "LILITH"
            content.body = discreetLines[lineIndex % discreetLines.count]
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: TimeInterval(days) * 86_400, repeats: false)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [id]) // re-logging replaces
            center.add(request)
        }
    }

    /// Called when she logs a vault entry: the next one schedules itself by the standard.
    static func scheduleReminder(for kind: VaultKind) {
        guard let days = interval(for: kind) else { return }
        schedule(id: "care.\(kind.rawValue)", in: days, lineIndex: 0)
    }

    /// Called when she logs sex with a new partner: a quiet nudge in two weeks, when the common
    /// tests turn reliable. Replaces any earlier pending one rather than stacking.
    static func scheduleNewPartnerCheck() {
        schedule(id: "care.newPartner", in: 14, lineIndex: 2)
    }

    // MARK: The in-app care note (the sensitive stuff NEVER goes to the lock screen at all)

    /// What the friend says on the Cycle tab based on the last few days of logs. Ordered by
    /// urgency; returns the single most important thing, or nil when there's nothing to say.
    static func note(entries: [CycleEntry], state: CycleState?, tryingToConceive: Bool) -> String? {
        let cal = Calendar.current
        let cutoff = cal.date(byAdding: .day, value: -4, to: cal.startOfDay(for: Date())) ?? Date()
        let recent = entries.filter { $0.date >= cutoff }

        if recent.contains(where: { $0.sex == .unprotected }) && !tryingToConceive {
            return "Logged unprotected and you're not trying: no lecture, just facts. Emergency contraception works best FAST and the pharmacy can sort it today. And if the period runs late, test, don't spiral."
        }
        if recent.contains(where: { $0.newPartner == true }) {
            return "New partner era, love that for you. Standard move: an STI check in about two weeks (that's when the common tests turn reliable; HIV and syphilis take six-plus). I've set a quiet nudge."
        }
        if tryingToConceive, let state, state.phase == .ovulatory {
            return "You're trying, and this is the window: the fertile days around ovulation. Go get your baby, girl. And take the folic acid your provider mentioned."
        }
        return nil
    }
}
