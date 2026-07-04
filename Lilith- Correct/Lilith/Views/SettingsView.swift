import SwiftUI

/// YOU, the full profile (Maria's master list, July 4). Everything about her and the app in one
/// quiet room: chart data, body basics, the Health Vault door, notifications, sharing, premium,
/// support, the fine print, and the exits. Same celestial editorial language as the rest.
struct SettingsView: View {
    @AppStorage("birthData") private var birthDataJSON = ""
    @AppStorage("userName") private var userName = ""
    @AppStorage("appleUserID") private var appleUserID = ""
    @AppStorage("wantsHealthKit") private var wantsHealthKit = false
    @AppStorage("notifyDailyReading") private var notifyDailyReading = false
    @AppStorage("notifyPeriodHeadsUp") private var notifyPeriodHeadsUp = false
    @AppStorage("bodyWeight") private var bodyWeight = ""
    @AppStorage("bodyHeight") private var bodyHeight = ""

    @State private var editingBirth = false
    @State private var showingVault = false
    @State private var showingFinePrint = false
    @State private var showingPremium = false
    @State private var confirmingDelete = false
    @State private var confirmingSignOut = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("YOU").displayCaps(34, em: 0.16)
                Text(userName.isEmpty ? "Your corner of the app." : "Hey \(userName). Your corner of the app.")
                    .font(Theme.body(16)).foregroundStyle(Theme.gold)
                    .padding(.top, 8)

                group("YOUR CHART") {
                    row(title: "EDIT BIRTH DATA", note: "Got the exact time from your mom? Update it here.") {
                        editingBirth = true
                    }
                }

                group("YOUR BODY") {
                    toggleRow(title: "CONNECT A TRACKER", isOn: $wantsHealthKit,
                              note: "Oura, Whoop, Garmin, Watch, anything that talks to Apple Health. The wiring ships next; your yes is saved.")
                    divider
                    measureRow
                }

                group("HEALTH VAULT") {
                    row(title: "OPEN THE VAULT", note: "Pap smears, breast checks, gyno, STI tests, IVF. Locked with your face, kept on this phone.") {
                        showingVault = true
                    }
                }

                group("THE APP") {
                    toggleRow(title: "DAILY READING", isOn: $notifyDailyReading,
                              note: "One nudge a day when your reading is ready. Goes live the moment push ships.")
                    divider
                    toggleRow(title: "PERIOD HEADS-UP", isOn: $notifyPeriodHeadsUp,
                              note: "A discreet heads-up before your period is due. Discreet means your lock screen will never say why.")
                    divider
                    shareRow
                    divider
                    row(title: "LILITH PREMIUM", note: "Not open yet. The good stuff is coming.") {
                        showingPremium = true
                    }
                    divider
                    supportRow
                }

                group("THE FINE PRINT") {
                    row(title: "READ THE DISCLAIMERS", note: "Not a doctor, not birth control, not your measured hormones. All of it, one page.") {
                        showingFinePrint = true
                    }
                }

                privacyPromise

                if !appleUserID.isEmpty {
                    signOutButton.padding(.top, 40)
                }
                deleteButton
                    .padding(.top, appleUserID.isEmpty ? 40 : 14)

                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 50)
            }
            .padding(.horizontal, 28)
            .padding(.top, 16)
            .padding(.bottom, 120) // clears the floating tab bar
        }
        .scrollIndicators(.hidden)
        .auraScreen(.you) // pearl and champagne; the quiet back room
        .sheet(isPresented: $editingBirth) {
            OnboardingView(startStep: 2) { birth in
                if let data = try? JSONEncoder().encode(birth) {
                    birthDataJSON = String(data: data, encoding: .utf8) ?? ""
                }
                HoroscopeService.clearCache() // new birth data means a new chart; drop stale readings
                editingBirth = false
            }
        }
        .sheet(isPresented: $showingVault) { HealthVaultView() }
        .sheet(isPresented: $showingFinePrint) { DisclaimersView() }
        .sheet(isPresented: $showingPremium) { PremiumTeaser() }
        .confirmationDialog("Sign out?", isPresented: $confirmingSignOut, titleVisibility: .visible) {
            Button("Sign me out") { appleUserID = "" }
            Button("Stay", role: .cancel) {}
        } message: {
            Text("Your chart, cycle, and vault stay on this phone. This only disconnects your Apple sign-in.")
        }
        .confirmationDialog("Delete everything?", isPresented: $confirmingDelete, titleVisibility: .visible) {
            Button("Delete it all", role: .destructive) { deleteEverything() }
            Button("Keep me", role: .cancel) {}
        } message: {
            Text("This wipes your chart, your cycle, your vault, everything on this phone. No take-backs. You'd start fresh.")
        }
    }

    // MARK: Layout pieces

    private func group<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
                .foregroundStyle(Theme.ember)
                .padding(.bottom, 4)
            content()
        }
        .padding(.top, 34)
    }

    private var divider: some View {
        Rectangle().fill(Theme.gold.opacity(0.12)).frame(height: 0.5)
    }

    private func row(title: String, note: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.light(); action()
        } label: {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.12))
                        .foregroundStyle(Theme.bone)
                    Text(note)
                        .font(Theme.body(14)).foregroundStyle(Theme.bone.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Text("→").font(Theme.body(18)).foregroundStyle(Theme.gold)
            }
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func toggleRow(title: String, isOn: Binding<Bool>, note: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.12))
                    .foregroundStyle(Theme.bone)
                Text(note)
                    .font(Theme.body(14)).foregroundStyle(Theme.bone.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(Theme.gold.opacity(0.75))
        }
        .padding(.vertical, 16)
    }

    /// Weight and height, hers to fill or ignore. On-device like everything else; future features
    /// (honest energy estimates) will read them, nothing else ever does.
    private var measureRow: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 5) {
                Text("WEIGHT & HEIGHT")
                    .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.12))
                    .foregroundStyle(Theme.bone)
                Text("Optional, on this phone only. No goals, no judgment, ever.")
                    .font(Theme.body(14)).foregroundStyle(Theme.bone.opacity(0.5))
            }
            Spacer()
            HStack(spacing: 10) {
                measureField("KG", $bodyWeight)
                measureField("CM", $bodyHeight)
            }
        }
        .padding(.vertical, 16)
    }

    private func measureField(_ unit: String, _ value: Binding<String>) -> some View {
        HStack(spacing: 4) {
            TextField("··", text: value)
                .keyboardType(.decimalPad)
                .font(Theme.data(15))
                .foregroundStyle(Theme.bone)
                .tint(Theme.gold)
                .multilineTextAlignment(.trailing)
                .frame(width: 42)
            Text(unit)
                .font(Theme.mono(8)).tracking(Theme.tracking(8, em: 0.14))
                .foregroundStyle(Theme.gold.opacity(0.7))
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.bone.opacity(0.05))
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Theme.gold.opacity(0.25), lineWidth: 0.5))
        )
    }

    private var shareRow: some View {
        ShareLink(item: "My best friend lives in my pocket now. LILITH: your chart, your cycle, and the moon, all keeping your secrets. She's coming to the App Store soon.") {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("TELL A FRIEND")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.12))
                        .foregroundStyle(Theme.bone)
                    Text("The good ones get shared. So does LILITH.")
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

    private var supportRow: some View {
        Link(destination: URL(string: "mailto:m.stavridi@me.com?subject=LILITH%20support")!) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("TALK TO SUPPORT")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.12))
                        .foregroundStyle(Theme.bone)
                    Text("Something broken, something weird, something on your mind. Write in.")
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

    // MARK: Exits

    private var signOutButton: some View {
        Button {
            confirmingSignOut = true
        } label: {
            Text("SIGN OUT")
                .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.14))
                .foregroundStyle(Theme.gold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .overlay(Rectangle().stroke(Theme.gold.opacity(0.4), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

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
        bodyWeight = ""
        bodyHeight = ""
        CycleStore.shared.deleteAll()  // the promise means ALL of her, not just the chart
        VaultStore.shared.deleteAll()
        HoroscopeService.clearCache() // wipe cached readings too; nothing of her stays behind
        // The app re-derives storedChart as nil and drops back to onboarding automatically.
    }
}

/// The premium door, honestly shut. No fake paywall, no dark pattern countdown: just what's
/// coming and a promise the free heart of the app stays free.
struct PremiumTeaser: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("LILITH PREMIUM")
                    .displayCaps(26, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(26, em: 0.14))
                    .padding(.top, 44)
                Text("Not open yet. Worth the wait.")
                    .font(Theme.body(15).italic()).foregroundStyle(Theme.gold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)

                Text("The daily readings, your cycle, your chart, and the vault stay free forever. That's the deal and it doesn't change. Premium will be the deeper cuts: the full compatibility room, the astrocartography maps, the BFF who texts back. When it opens, you'll hear it from me first.")
                    .font(Theme.body(16)).foregroundStyle(Theme.bone.opacity(0.85))
                    .lineSpacing(7)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 30)

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
}
