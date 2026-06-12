import SwiftUI

/// The quiet back room: edit birth data, read the privacy promise in her voice, and the door
/// to delete everything. Same celestial editorial language as the rest of the app.
struct SettingsView: View {
    @AppStorage("birthData") private var birthDataJSON = ""
    @AppStorage("userName") private var userName = ""
    @AppStorage("appleUserID") private var appleUserID = ""

    @State private var editingBirth = false
    @State private var confirmingDelete = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("SETTINGS").displayCaps(34, em: 0.16)
                Text(userName.isEmpty ? "The basics, babe." : "Hey \(userName). The basics.")
                    .font(Theme.body(16)).foregroundStyle(Theme.gold)
                    .padding(.top, 8)

                row(title: "EDIT BIRTH DATA", note: "Got the time from your mom? Update it here.") {
                    editingBirth = true
                }
                .padding(.top, 30)

                Rectangle().fill(Theme.gold.opacity(0.15)).frame(height: 0.5)

                privacyPromise

                deleteButton
                    .padding(.top, 40)

                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 50)
            }
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .cosmicScreen(bloomAlignment: .top, bloomIntensity: 0.5)
        .sheet(isPresented: $editingBirth) {
            OnboardingView(startStep: 2) { birth in
                if let data = try? JSONEncoder().encode(birth) {
                    birthDataJSON = String(data: data, encoding: .utf8) ?? ""
                }
                HoroscopeService.clearCache() // new birth data means a new chart; drop stale readings
                editingBirth = false
            }
        }
        .confirmationDialog("Delete everything?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete it all", role: .destructive) { deleteEverything() }
            Button("Keep me", role: .cancel) {}
        } message: {
            Text("This wipes your chart and everything on this phone. No take-backs. You'd start fresh.")
        }
    }

    // MARK: Rows

    private func row(title: String, note: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.12))
                        .foregroundStyle(Theme.bone)
                    Text(note)
                        .font(Theme.body(14)).foregroundStyle(Theme.bone.opacity(0.5))
                }
                Spacer()
                Text("→").font(Theme.body(18)).foregroundStyle(Theme.gold)
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: The privacy promise (docs/02), in her voice

    private var privacyPromise: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("THE PROMISE").displayCaps(18, em: 0.16, color: Theme.gold)
            Text("Your birth details, and anything you'll ever track, live on this phone and nowhere else. When I ask the stars for your reading I send the planets, never you. No name, no email, no location attached to it. Your secrets stay secret, because that's what a best friend is.")
                .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.8)).lineSpacing(6)
        }
        .padding(.top, 34)
    }

    // MARK: Delete everything

    private var deleteButton: some View {
        Button(role: .destructive) {
            confirmingDelete = true
        } label: {
            Text("DELETE EVERYTHING")
                .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.14))
                .foregroundStyle(Theme.blood)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .overlay(Rectangle().stroke(Theme.blood.opacity(0.5), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    private func deleteEverything() {
        birthDataJSON = ""
        userName = ""
        appleUserID = ""
        HoroscopeService.clearCache() // wipe cached readings too; nothing of her stays behind
        // The app re-derives storedChart as nil and drops back to onboarding automatically.
    }
}
