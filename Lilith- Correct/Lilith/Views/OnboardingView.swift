import SwiftUI
import Combine
import CoreLocation
import MapKit
import AuthenticationServices

/// Onboarding (July 4 glow-up, Maria's spec): account → name → birth date → time → place →
/// last period → tracker ask. Still under two minutes, and every question sounds like a friend
/// asking, not a form. Editing birth data from Settings runs only the birth steps.
/// Account = Sign in with Apple only (one tap, zero typing). See docs/02 "Accounts".
struct OnboardingView: View {
    let onComplete: (BirthData) -> Void

    /// First run starts at 0 (the account step). Editing birth data from Settings jumps
    /// straight to the date step (2) and finishes after place: no period/tracker re-ask.
    init(startStep: Int = 0, onComplete: @escaping (BirthData) -> Void) {
        self.onComplete = onComplete
        _step = State(initialValue: startStep)
        isEditing = startStep >= 2
    }

    @AppStorage("userName") private var userName = ""
    @AppStorage("appleUserID") private var appleUserID = ""
    @AppStorage("wantsHealthKit") private var wantsHealthKit = false

    private let isEditing: Bool
    @State private var step: Int
    @State private var nameDraft = ""
    @State private var birthDate = Date(timeIntervalSince1970: 820_454_400) // ~1996, flattering default
    @State private var birthTime = Date()
    @State private var knowsTime = true
    @State private var placeQuery = ""
    @State private var resolvedPlace: (name: String, lat: Double, lon: Double, tz: String)?
    @State private var geoStatus: String?
    @StateObject private var cities = CityCompleter()
    @State private var selectingCity = false
    @FocusState private var placeFocused: Bool
    @State private var periodDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var knowsPeriod = true

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            switch step {
            case 0: accountStep
            case 1: nameStep
            case 2: dateStep
            case 3: timeStep
            case 4: placeStep
            case 5: periodStep
            default: trackerStep
            }
            Spacer()
            if step > 0 && step < 6 { continueButton }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .auraScreen(.halo) // the crown-jewel plate; first impressions wear the best light
    }

    // MARK: Step 0 — the account (one tap)

    private var accountStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()
            Text("LILITH").displayCaps(56, em: 0.16)
            HairlineDivider(width: 90)
            Text("Your chart. Your cycle. Your best friend.\nOne tap and we never forget you.")
                .font(Theme.body()).foregroundStyle(Theme.gold).lineSpacing(4)

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
            Text("WHAT DO WE\nCALL YOU").displayCaps(36, em: 0.14)
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
            Text("WHEN WERE YOU BORN").displayCaps(36, em: 0.14)
            Text("The day the universe upgraded.")
                .font(Theme.body()).foregroundStyle(Theme.gold)
            DatePicker("", selection: $birthDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .colorScheme(.dark)
        }
    }

    private var timeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WHAT TIME, EXACTLY").displayCaps(36, em: 0.14)
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
            Text("WHERE DID IT HAPPEN").displayCaps(36, em: 0.14)
            Text("City of birth. The sky looked different there.")
                .font(Theme.body()).foregroundStyle(Theme.gold)
            TextField("", text: $placeQuery, prompt: Text("Start typing your city").foregroundStyle(Theme.bone.opacity(0.3)))
                .font(Theme.body(20)).foregroundStyle(Theme.bone)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .focused($placeFocused)
                .padding(.vertical, 12)
                .overlay(Rectangle().frame(height: 1).foregroundStyle(Theme.gold), alignment: .bottom)
                .onChange(of: placeQuery) { _, newValue in
                    if selectingCity { selectingCity = false; return }
                    resolvedPlace = nil
                    geoStatus = nil
                    cities.update(newValue)
                }

            if let place = resolvedPlace {
                Text("✓ \(place.name). Tap READ MY CHART.")
                    .font(Theme.mono()).foregroundStyle(Theme.ember)
            } else if !cities.results.isEmpty {
                cityResults
            } else if let status = geoStatus {
                Text(status).font(Theme.mono(13)).foregroundStyle(Theme.gold)
            }
        }
    }

    /// The live autocomplete dropdown. Tapping a city pins its exact coordinates
    /// and timezone, both essential for an accurate chart.
    private var cityResults: some View {
        VStack(spacing: 0) {
            let matches = Array(cities.results.prefix(5).enumerated())
            ForEach(matches, id: \.offset) { index, completion in
                Button { select(completion) } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(completion.title)
                            .font(Theme.body(17)).foregroundStyle(Theme.bone)
                        if !completion.subtitle.isEmpty {
                            Text(completion.subtitle)
                                .font(Theme.mono(12)).foregroundStyle(Theme.bone.opacity(0.55))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if index < matches.count - 1 {
                    Rectangle().frame(height: 0.5).foregroundStyle(Theme.gold.opacity(0.2))
                }
            }
        }
    }

    // MARK: Step 5 — the last period (optional, one date, logs straight into CycleStore)

    private var periodStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("WHEN DID YOUR LAST\nPERIOD START").displayCaps(34, em: 0.12)
            Text("Roughly is fine. This wakes up your cycle from day one, and it never leaves this phone.")
                .font(Theme.body()).foregroundStyle(Theme.gold).lineSpacing(4)
            if knowsPeriod {
                DatePicker("", selection: $periodDate,
                           in: (Calendar.current.date(byAdding: .day, value: -60, to: Date()) ?? Date())...Date(),
                           displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .colorScheme(.dark)
            }
            Toggle(isOn: $knowsPeriod) {
                Text(knowsPeriod ? "I remember (ish)" : "No idea, skip it. Log it later in Cycle.")
                    .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.7))
            }
            .tint(Theme.ember)
        }
    }

    // MARK: Step 6 — the tracker ask (one switch covers Oura, Whoop, Garmin, Apple Watch)

    private var trackerStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("GOT A RING\nOR A WATCH?").displayCaps(34, em: 0.12)
            Text("Oura, Whoop, Garmin, Apple Watch: they all talk to Apple Health. Say yes and I'll read the receipts (sleep, recovery, the truth). Everything stays on this phone.")
                .font(Theme.body()).foregroundStyle(Theme.gold).lineSpacing(4)

            Button {
                wantsHealthKit = true
                Haptics.soft()
                completeFlow()
            } label: {
                Text("YES, SYNC MY TRACKER")
                    .font(Theme.display(17).weight(.medium))
                    .tracking(Theme.tracking(17, em: 0.14))
                    .frame(maxWidth: .infinity).padding(.vertical, 18)
                    .background(Theme.bone).foregroundStyle(Theme.void)
            }
            .padding(.top, 12)

            Button {
                wantsHealthKit = false
                Haptics.light()
                completeFlow()
            } label: {
                Text("NOT NOW")
                    .font(Theme.control(13)).tracking(1.1)
                    .foregroundStyle(Theme.bone.opacity(0.7))
                    .frame(maxWidth: .infinity).padding(.vertical, 14)
                    .overlay(Capsule().strokeBorder(Theme.bone.opacity(0.25), lineWidth: 0.75))
            }

            Text("Either way, your chart is ready. You can flip this any time in YOU.")
                .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.5))
        }
    }

    private var continueButton: some View {
        Button {
            if step == 1 { userName = nameDraft.isEmpty ? "babe" : nameDraft }
            switch step {
            case 1, 2, 3:
                step += 1
            case 4:
                guard resolvedPlace != nil else {
                    geoStatus = "Tap your city in the list first, babe."
                    return
                }
                // Editing from Settings ends here; first run continues to period + tracker.
                if isEditing, let place = resolvedPlace { finish(place) } else { step = 5 }
            case 5:
                if knowsPeriod { CycleStore.shared.logPeriodStart(on: periodDate) }
                step = 6
            default:
                break
            }
        } label: {
            Text(buttonLabel)
                .font(Theme.display(18).weight(.medium))
                .tracking(Theme.tracking(18, em: 0.16))
                .frame(maxWidth: .infinity).padding(.vertical, 18)
                .background(Theme.bone).foregroundStyle(Theme.void)
        }
        .disabled(step == 1 && nameDraft.isEmpty)
    }

    private var buttonLabel: String {
        switch step {
        case 4: isEditing ? "READ MY CHART" : "NEXT"
        case 5: knowsPeriod ? "LOG IT" : "SKIP"
        default: "NEXT"
        }
    }

    private func completeFlow() {
        if let place = resolvedPlace { finish(place) }
    }

    /// A tapped suggestion becomes a real location: MKLocalSearch resolves it to
    /// coordinates and a timezone, both essential for an accurate chart.
    private func select(_ completion: MKLocalSearchCompletion) {
        selectingCity = true
        placeQuery = completion.title
        placeFocused = false
        cities.clear()
        geoStatus = "Pinning it on the map…"
        Task { @MainActor in
            if let place = await CityCompleter.resolve(completion) {
                resolvedPlace = place
                geoStatus = nil
            } else {
                geoStatus = "Couldn't pin that one. Pick another?"
            }
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

/// Live city search for the birth-place step. MKLocalSearchCompleter gives instant
/// suggestions as she types; MKLocalSearch then pins the chosen city's real
/// coordinates and timezone. No location permission needed, nothing leaves the phone.
final class CityCompleter: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var results: [MKLocalSearchCompletion] = []
    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
    }

    /// Feed the current text. Waits for 2+ characters so we don't search on a single letter.
    func update(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else {
            results = []
            completer.queryFragment = ""
            return
        }
        completer.queryFragment = trimmed
    }

    func clear() {
        results = []
        completer.queryFragment = ""
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        results = []
    }

    /// Resolve a chosen suggestion into coordinates + IANA timezone for the chart.
    static func resolve(_ completion: MKLocalSearchCompletion) async -> (name: String, lat: Double, lon: Double, tz: String)? {
        let request = MKLocalSearch.Request(completion: completion)
        guard let response = try? await MKLocalSearch(request: request).start(),
              let item = response.mapItems.first else { return nil }
        let placemark = item.placemark
        let coordinate = placemark.coordinate
        let name = [placemark.locality ?? completion.title,
                    placemark.country ?? completion.subtitle]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
        let tz = item.timeZone?.identifier
            ?? placemark.timeZone?.identifier
            ?? TimeZone.current.identifier
        return (name: name.isEmpty ? completion.title : name,
                lat: coordinate.latitude,
                lon: coordinate.longitude,
                tz: tz)
    }
}
