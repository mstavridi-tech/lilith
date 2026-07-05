import SwiftUI
import Combine
import LocalAuthentication

// MARK: - The Health Vault (Maria's master list, July 4)
//
// The most private shelf in the app: pap smears, breast checks, gyno visits, STI tests, IVF steps.
// Hard rules from docs/01 and CLAUDE.md: on-device ONLY (UserDefaults JSON like CycleStore, never
// server-side), locked behind Face ID / device passcode, "book it with your provider" framing
// everywhere, never diagnosis, never judgment. Discreet by design: nothing in here ever appears
// in a notification or leaves the page.

/// What kind of care moment she's logging.
enum VaultKind: String, Codable, CaseIterable, Identifiable {
    case papSmear, breastCheck, gyno, sti, ivf

    var id: String { rawValue }

    var label: String {
        switch self {
        case .papSmear: "PAP SMEAR"
        case .breastCheck: "BREAST CHECK"
        case .gyno: "GYNO VISIT"
        case .sti: "STI TEST"
        case .ivf: "IVF"
        }
    }

    /// The friend line under each kind. Guidance to book with a provider, never a schedule we
    /// invent and never a diagnosis. Cadence talk stays vague on purpose; guidelines differ by
    /// country and the Phase 2.5 care reminders will carry the sourced, country-adjustable version.
    var note: String {
        switch self {
        case .papSmear: "The screening everyone postpones. Book it with your provider, then log it here and forget the guesswork."
        case .breastCheck: "Self-checks at home, professional ones with your provider. Log either, future-you stops wondering when the last one was."
        case .gyno: "The regular check-in. Your provider sets the rhythm, this page just remembers it."
        case .sti: "Routine when you need it, zero shame ever. Book with your provider or a clinic, log the date, done."
        case .ivf: "Every step of that journey counts, and it's nobody's business but yours. Log what you want remembered."
        }
    }
}

/// One logged care moment. A date, a kind, an optional note. That's all we keep, on purpose.
struct VaultEntry: Codable, Identifiable {
    var id: UUID = UUID()
    var kind: VaultKind
    var date: Date
    var note: String? = nil
}

/// On-device storage, mirror of CycleStore's pattern. Nothing here ever leaves the phone.
final class VaultStore: ObservableObject {
    static let shared = VaultStore()

    @Published private(set) var entries: [VaultEntry] = []

    private let key = "lilith.vault.entries"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([VaultEntry].self, from: data) {
            entries = decoded
        }
    }

    func add(_ entry: VaultEntry) {
        entries.append(entry)
        persist()
    }

    func delete(_ entry: VaultEntry) {
        entries.removeAll { $0.id == entry.id }
        persist()
    }

    /// Her most recent log of a kind, so each shelf shows "last done".
    func latest(_ kind: VaultKind) -> VaultEntry? {
        entries.filter { $0.kind == kind }.max { $0.date < $1.date }
    }

    /// For the Settings "delete my data" promise.
    func deleteAll() {
        entries = []
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func persist() {
        entries.sort { $0.date > $1.date }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// MARK: - The vault screen

struct HealthVaultView: View {
    @ObservedObject private var store = VaultStore.shared
    @Environment(\.dismiss) private var dismiss

    @State private var unlocked = false
    @State private var authFailed = false
    @State private var adding: VaultKind?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("HEALTH VAULT")
                    .displayCaps(28, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(28, em: 0.14))
                    .padding(.top, 44)
                Text(unlocked ? "Between you and this phone." : "Locked. As it should be.")
                    .font(Theme.body(15).italic()).foregroundStyle(Theme.gold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)

                if unlocked {
                    shelves
                    honesty
                } else {
                    lockedFace
                }

                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 44)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: "", accent: Theme.blood)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
        .sheet(item: $adding) { kind in
            VaultAddSheet(kind: kind, store: store)
        }
        .onAppear(perform: unlock)
    }

    // MARK: Lock

    /// Face ID first, device passcode as the system fallback. If the phone has no lock set at all
    /// we say so and open, because a vault door on an unlocked house is theater, not privacy.
    private func unlock() {
        guard !unlocked else { return }
        let ctx = LAContext()
        ctx.localizedReason = "Unlock your Health Vault"
        var error: NSError?
        guard ctx.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            unlocked = true // no passcode on the device; nothing to lock behind
            return
        }
        ctx.evaluatePolicy(.deviceOwnerAuthentication,
                           localizedReason: "Unlock your Health Vault") { ok, _ in
            DispatchQueue.main.async {
                unlocked = ok
                authFailed = !ok
            }
        }
    }

    private var lockedFace: some View {
        VStack(spacing: 18) {
            Image(systemName: "faceid")
                .font(.system(size: 44, weight: .ultraLight))
                .foregroundStyle(Theme.gold)
            Text(authFailed
                 ? "That didn't unlock it. Only your face or your passcode gets in here, that's the whole point."
                 : "This shelf opens with your face or your passcode. Nobody else's.")
                .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            Button {
                Haptics.light(); authFailed = false; unlock()
            } label: {
                Text("UNLOCK")
                    .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.18))
                    .foregroundStyle(Theme.gold)
                    .padding(.horizontal, 34).padding(.vertical, 13)
                    .overlay(Capsule().strokeBorder(Theme.gold.opacity(0.5), lineWidth: 0.75))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: Shelves

    private var shelves: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(VaultKind.allCases) { kind in
                shelf(kind)
                if kind != VaultKind.allCases.last {
                    Rectangle().fill(Theme.gold.opacity(0.12)).frame(height: 0.5)
                }
            }
        }
        .padding(.top, 16)
    }

    private func shelf(_ kind: VaultKind) -> some View {
        let logs = store.entries.filter { $0.kind == kind }
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(kind.label)
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.14))
                        .foregroundStyle(Theme.bone)
                    if let last = store.latest(kind) {
                        Text("LAST · \(Self.short.string(from: last.date).uppercased())")
                            .font(Theme.mono(9)).tracking(Theme.tracking(9, em: 0.14))
                            .foregroundStyle(Theme.gold.opacity(0.8))
                    }
                }
                Spacer()
                Button {
                    Haptics.light(); adding = kind
                } label: {
                    Text("LOG")
                        .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.16))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .overlay(Capsule().strokeBorder(Theme.gold.opacity(0.45), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
            }
            Text(kind.note)
                .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.6))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(logs) { entry in
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(Self.short.string(from: entry.date).uppercased())
                        .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.12))
                        .foregroundStyle(Theme.bone.opacity(0.8))
                    if let note = entry.note {
                        Text(note)
                            .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.6))
                            .lineLimit(2)
                    }
                    Spacer()
                    Button {
                        Haptics.light(); store.delete(entry)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Theme.bone.opacity(0.4))
                            .padding(6)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(.vertical, 18)
    }

    private var honesty: some View {
        Text("On this phone only. Never synced, never in a notification.")
            .font(Theme.body(12).italic()).foregroundStyle(Theme.gold.opacity(0.65))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 22)
    }

    private static let short: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "d MMM yyyy"; return f
    }()
}

// MARK: - Logging one care moment

struct VaultAddSheet: View {
    let kind: VaultKind
    let store: VaultStore
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var note = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(kind.label)
                    .displayCaps(26, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(26, em: 0.14))
                    .padding(.top, 44)

                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)

                Text("WHEN")
                    .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
                    .foregroundStyle(Theme.ember)
                    .padding(.top, 28)
                DatePicker("", selection: $date, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Theme.gold)
                    .padding(.top, 4)

                Text("NOTE")
                    .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
                    .foregroundStyle(Theme.ember)
                    .padding(.top, 18)
                TextField("optional, e.g. all clear", text: $note, axis: .vertical)
                    .font(Theme.body(16)).foregroundStyle(Theme.bone)
                    .tint(Theme.gold)
                    .lineLimit(2...4)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.bone.opacity(0.05))
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Theme.gold.opacity(0.25), lineWidth: 0.5))
                    )
                    .padding(.top, 10)

                Button {
                    Haptics.soft()
                    let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
                    store.add(VaultEntry(kind: kind, date: date, note: trimmed.isEmpty ? nil : trimmed))
                    dismiss()
                } label: {
                    Text("SAVE TO THE VAULT")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.2))
                        .foregroundStyle(Theme.void)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Theme.gold))
                        .background(Capsule().fill(Theme.gold).opacity(0.4).blur(radius: 18))
                }
                .buttonStyle(.plain)
                .padding(.top, 30)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: "", accent: Theme.blood)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
    }
}
