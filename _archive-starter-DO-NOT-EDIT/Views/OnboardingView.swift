import SwiftUI
import CoreLocation
import AuthenticationServices

/// Onboarding: account → name → birth date → time → place. Under 90 seconds.
/// Account = Sign in with Apple only (one tap, zero typing). See docs/02 "Accounts".
/// Tone: we're not collecting data, we're preparing her reading.
struct OnboardingView: View {
    let onComplete: (BirthData) -> Void

    @AppStorage("userName") private var userName = ""
    @AppStorage("appleUserID") private var appleUserID = ""

    @State private var step = 0
    @State private var nameDraft = ""
    @State private var birthDate = Date(timeIntervalSince1970: 820_454_400) // ~1996, flattering default
    @State private var birthTime = Date()
    @State private var knowsTime = true
    @State private var placeQuery = ""
    @State private var resolvedPlace: (name: String, lat: Double, lon: Double, tz: String)?

    var body: some View {
        ZStack {
            Theme.void.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 32) {
                switch step {
                case 0: accountStep
                case 1: nameStep
                case 2: dateStep
                case 3: timeStep
                default: placeStep
                }
                Spacer()
                if step > 0 { continueButton }
            }
            .padding(28)
        }
    }

    // MARK: Step 0 — the account (one tap)

    private var accountStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Text("LILITH")
                .font(Theme.display(56)).foregroundStyle(Theme.bone)
            Text("Your chart. Your cycle. Your best friend.\nOne tap and we never forget you.")
                .font(Theme.body()).foregroundStyle(Theme.gold)

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleAppleSignIn(result)
            }
            .signInWithAppleButtonStyle(.white)
            .frame(height: 54)
            .padding(.top, 24)

            Text("Your name and email make your account. Your cycle and your secrets never leave this phone.")
                .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.5))

            #if DEBUG
            // Prototype-only bypass: Sign in with Apple needs the paid developer
            // account. Remove nothing — this whole block disappears in release builds.
            Button("DEV: skip sign-in for now") {
                appleUserID = "dev-preview"
                step = 1
            }
            .font(Theme.mono(13)).foregroundStyle(Theme.ember)
            #endif
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        guard case .success(let auth) = result,
              let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
        appleUserID = credential.user
        // Apple only provides the name on the FIRST authorization — capture it now or never.
        if let given = credential.fullName?.givenName { nameDraft = given }
        // TODO(Claude Code): exchange credential.identityToken with Supabase auth
        // (signInWithIdToken, provider: .apple) and store the session. See docs/02.
        step = 1
    }

    // MARK: Step 1 — what do we call you

    private var nameStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WHAT DO WE\nCALL YOU")
                .font(Theme.display(36)).foregroundStyle(Theme.bone)
            Text("Government name optional. BFF name required.")
                .font(Theme.body()).foregroundStyle(Theme.gold)
            TextField("", text: $nameDraft, prompt: Text("Your name").foregroundStyle(Theme.bone.opacity(0.3)))
                .font(Theme.body(24)).foregroundStyle(Theme.bone)
                .textFieldStyle(.plain)
                .padding(.vertical, 12)
                .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.gold), alignment: .bottom)
        }
    }

    // MARK: Steps 2–4 — the birth data

    private var dateStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WHEN WERE YOU BORN")
                .font(Theme.display(36)).foregroundStyle(Theme.bone)
            Text("The day the universe upgraded.")
                .font(Theme.body()).foregroundStyle(Theme.gold)
            DatePicker("", selection: $birthDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .colorScheme(.dark)
        }
    }

    private var timeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WHAT TIME, EXACTLY")
                .font(Theme.display(36)).foregroundStyle(Theme.bone)
            Text("This unlocks your rising sign and houses. Text your mother. We'll wait.")
                .font(Theme.body()).foregroundStyle(Theme.gold)
            if knowsTime {
                DatePicker("", selection: $birthTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .colorScheme(.dark)
            }
            Toggle(isOn: $knowsTime) {
                Text(knowsTime ? "I know my birth time" : "No idea (rising sign will stay a mystery)")
                    .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.7))
            }
            .tint(Theme.ember)
        }
    }

    private var placeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WHERE DID IT HAPPEN")
                .font(Theme.display(36)).foregroundStyle(Theme.bone)
            Text("City of birth. The sky looked different there.")
                .font(Theme.body()).foregroundStyle(Theme.gold)
            TextField("", text: $placeQuery, prompt: Text("e.g. Athens, Greece").foregroundStyle(Theme.bone.opacity(0.3)))
                .font(Theme.body(20)).foregroundStyle(Theme.bone)
                .textFieldStyle(.plain)
                .padding(.vertical, 12)
                .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.gold), alignment: .bottom)
                .onSubmit { geocode() }
            if let place = resolvedPlace {
                Text("✓ \(place.name)").font(Theme.mono()).foregroundStyle(Theme.ember)
            }
        }
    }

    private var continueButton: some View {
        Button {
            if step == 1 { userName = nameDraft.isEmpty ? "babe" : nameDraft }
            if step < 4 { step += 1 }
            else if let place = resolvedPlace { finish(place) }
            else { geocode() }
        } label: {
            Text(step < 4 ? "NEXT" : "READ MY CHART")
                .font(Theme.display(18))
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(Theme.bone).foregroundStyle(Theme.void)
        }
        .disabled(step == 1 && nameDraft.isEmpty)
    }

    /// CLGeocoder gives lat/lon AND the timezone of the place — both essential.
    private func geocode() {
        CLGeocoder().geocodeAddressString(placeQuery) { placemarks, _ in
            guard let p = placemarks?.first, let loc = p.location else { return }
            resolvedPlace = (
                name: [p.locality, p.country].compactMap { $0 }.joined(separator: ", "),
                lat: loc.coordinate.latitude,
                lon: loc.coordinate.longitude,
                tz: p.timeZone?.identifier ?? TimeZone.current.identifier
            )
        }
    }

    private func finish(_ place: (name: String, lat: Double, lon: Double, tz: String)) {
        let calendar = Calendar(identifier: .gregorian)
        let birth = BirthData(
            date: calendar.dateComponents([.year, .month, .day], from: birthDate),
            time: knowsTime ? calendar.dateComponents([.hour, .minute], from: birthTime) : nil,
            placeName: place.name,
            latitude: place.lat,
            longitude: place.lon,
            timeZoneID: place.tz
        )
        onComplete(birth)
    }
}
