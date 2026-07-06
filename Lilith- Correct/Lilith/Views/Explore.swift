import SwiftUI
import AVFoundation

// MARK: - EXPLORE (Maria's master list, July 4; researched July 4)
//
// Market research verdict (Flo: expert content library + anonymous community; Stardust: daily
// cycle-specific content across mind/body/movement/sex/work/beauty plus the searchable Cyclepedia;
// Clue: 300+ expert guides): the winning explore surfaces are (1) phase-specific lifestyle
// guidance, (2) a symptom decoder, (3) lore/meaning content. LILITH v1 ships those three in her
// own voice plus RELIEF with the RAGE outlet, all generated in-app, no editorial backend, all
// wellness-not-medical with the provider bridge where it belongs.

/// The 2x2 glass grid on Today. Four doors, each a sheet.
struct ExploreGrid: View {
    let phase: CyclePhase?

    @State private var showPlaybook = false
    @State private var showRelief = false
    @State private var showLore = false
    @State private var showDecoder = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("EXPLORE")
                .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
                .foregroundStyle(Theme.ember)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible())],
                      spacing: 12) {
                card(.follicular, "THE PHASE PLAYBOOK", "move, eat, work, love, by phase") {
                    showPlaybook = true
                }
                card(.menstrual, "RELIEF", "breathe it out or rage it out") {
                    showRelief = true
                }
                card(.moonlight, "MOON LORE", "tonight's sky, old stories") {
                    showLore = true
                }
                card(.you, "DECODE A SYMPTOM", "what's typical, what's a doctor") {
                    showDecoder = true
                }
            }
        }
        .padding(.top, 28)
        .sheet(isPresented: $showPlaybook) { PhasePlaybookSheet(current: phase) }
        .sheet(isPresented: $showRelief) { ReliefSheet() }
        .sheet(isPresented: $showLore) { MoonLoreSheet() }
        .sheet(isPresented: $showDecoder) { SymptomDecoderSheet() }
    }

    /// July 4 late round (Maria: the flat glass grid read "AI"; Kimi's generated imagery read calm
    /// and sleek). Each door now wears one of our own liquid-light plates, cropped small, with a
    /// scrim so the title stays readable per the readability system. Same art language as the
    /// screens themselves, so Explore feels like four little windows instead of four buttons.
    private func card(_ plate: AuraBackdrop, _ title: String, _ sub: String,
                      action: @escaping () -> Void) -> some View {
        Button {
            Haptics.light(); action()
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Spacer(minLength: 0)
                Text(title)
                    .font(Theme.mono(10.5)).tracking(Theme.tracking(10.5, em: 0.14))
                    .foregroundStyle(Theme.bone)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(sub)
                    .font(Theme.body(12).italic())
                    .foregroundStyle(Theme.bone.opacity(0.72))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(13)
            .frame(height: 116)
            .background(
                ZStack {
                    if let img = UIImage(named: plate.rawValue) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Theme.surface
                    }
                    // the crown rule, miniature: art up top, near-solid ground under the words
                    LinearGradient(
                        stops: [.init(color: .clear, location: 0),
                                .init(color: Theme.void.opacity(0.45), location: 0.45),
                                .init(color: Theme.void.opacity(0.88), location: 1)],
                        startPoint: .top, endPoint: .bottom)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Theme.bone.opacity(0.12), lineWidth: 0.5))
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sheet scaffolding shared by the four doors

private struct ExploreSheet<Content: View>: View {
    let title: String
    let subtitle: String
    var accent: Color = Theme.gold
    var glyph: String = ""
    @ViewBuilder var content: Content
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .displayCaps(26, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(26, em: 0.14))
                    .padding(.top, 44)
                Text(subtitle)
                    .font(Theme.body(15).italic()).foregroundStyle(Theme.gold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)
                content
                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 44)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: glyph, accent: accent)
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

private func exploreLabel(_ text: String, color: Color = Theme.ember) -> some View {
    Text(text)
        .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.26))
        .foregroundStyle(color)
}

private func exploreBody(_ text: String) -> some View {
    Text(text)
        .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.85))
        .lineSpacing(6)
        .fixedSize(horizontal: false, vertical: true)
}

// MARK: - 1. The Phase Playbook

/// Typical-pattern lifestyle guidance per phase, Stardust's winning categories in LILITH's voice.
/// Education about what's classic for each phase, never prescriptions, never her measured anything.
struct PhasePlaybookSheet: View {
    let current: CyclePhase?
    @State private var selected: CyclePhase

    init(current: CyclePhase?) {
        self.current = current
        _selected = State(initialValue: current ?? .follicular)
    }

    private struct Play { let move: String; let eat: String; let work: String; let love: String }

    private func play(_ phase: CyclePhase) -> Play {
        switch phase {
        case .menstrual:
            Play(move: "Walks, stretching, yoga with a blanket within reach. If the gym happens, fine, but there's nothing to prove this week.",
                 eat: "Warm and iron-friendly: stews, greens, and dark chocolate that officially counts as self-care.",
                 work: "Review, don't launch. Your brain is doing quiet strategic work right now; let the calendar be gentle with you.",
                 love: "Cancel guilt-free. The ones who get it, get you. Softness only.")
        case .follicular:
            Play(move: "Energy is coming back online: strength, dance, the class you keep bookmarking. Go.",
                 eat: "Fresh and colourful suits the rising energy: crunchy things, protein for building the comeback.",
                 work: "Start things. Pitch, plan, learn. This is classically the spongiest your brain gets all month.",
                 love: "New people land softer now. You're curious again; follow it and see.")
        case .ovulatory:
            Play(move: "Peak power window: intervals, the heavy lifts, the hard class. Your body wants an audience anyway.",
                 eat: "Lighter and social, because you'll be out. Fibre and plenty of water keep the peak feeling clean.",
                 work: "Present, negotiate, ask for the number you actually want. This is the week your words come out right.",
                 love: "Magnetic is the technical term. Flirt responsibly.")
        case .luteal:
            Play(move: "Downshift on purpose: pilates, long hikes, strength at a slower tempo. Still strong, just quieter.",
                 eat: "The cravings are chemistry, typically. Magnesium-rich things help a lot of girls: seeds, greens, chocolate again.",
                 work: "Edit, finish, close the loops. Detail vision is up and tolerance for nonsense is down. Use both.",
                 love: "Protect your peace. Say no early, mean it kindly, keep the exit open.")
        }
    }

    var body: some View {
        ExploreSheet(title: "THE PHASE PLAYBOOK",
                     subtitle: "What each era of the month classically loves.") {
            HStack(spacing: 8) {
                ForEach(CyclePhase.allCases, id: \.self) { phase in
                    Button {
                        Haptics.light(); selected = phase
                    } label: {
                        Text(phase.name)
                            .font(Theme.mono(9)).tracking(Theme.tracking(9, em: 0.06))
                            .foregroundStyle(selected == phase ? Theme.bone : Theme.bone.opacity(0.7))
                            .padding(.horizontal, 10).padding(.vertical, 10)
                            .background(Capsule().fill(selected == phase ? phase.aura : Theme.surfaceHigh))
                            .shadow(color: selected == phase ? phase.aura.opacity(0.4) : .clear,
                                    radius: 8, y: 2)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 24)

            if current == selected {
                Text("YOU'RE HERE NOW")
                    .font(Theme.mono(8.5)).tracking(Theme.tracking(8.5, em: 0.22))
                    .foregroundStyle(selected.aura)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
            }

            let p = play(selected)
            Group {
                exploreLabel("MOVE").padding(.top, 26)
                exploreBody(p.move).padding(.top, 8)
                exploreLabel("EAT").padding(.top, 22)
                exploreBody(p.eat).padding(.top, 8)
                exploreLabel("WORK").padding(.top, 22)
                exploreBody(p.work).padding(.top, 8)
                exploreLabel("LOVE").padding(.top, 22)
                exploreBody(p.love).padding(.top, 8)
            }

            Text("Typical patterns, not prescriptions.")
                .font(Theme.body(12).italic()).foregroundStyle(Theme.gold.opacity(0.65))
                .padding(.top, 20)
        }
    }
}

// MARK: - The calm voice (PLACEHOLDER: system speech until we record or generate LILITH's real
// voice; the cues, timing, and lines are final, the voice actress is not. Maria decides her.)

enum CalmVoice {
    private static let synth = AVSpeechSynthesizer()
    private static var player: AVAudioPlayer?

    /// The best voice this device actually has: premium beats enhanced beats default, and the
    /// warm US female voices beat the robotic compact ones. Still a placeholder for LILITH's
    /// real cast voice, but a far less anxious one (July 5, Maria).
    private static let voice: AVSpeechSynthesisVoice? = {
        let all = AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix("en") }
        let preferredNames = ["Ava", "Zoe", "Samantha", "Allison", "Susan", "Karen"]
        func rank(_ v: AVSpeechSynthesisVoice) -> Int {
            var score = 0
            if v.quality == .premium { score += 200 } else if v.quality == .enhanced { score += 100 }
            if let i = preferredNames.firstIndex(where: { v.name.contains($0) }) { score += 50 - i }
            if v.language == "en-US" { score += 10 }
            return score
        }
        return all.max { rank($0) < rank($1) }
    }()

    /// Speak a line. Cast recordings (Roxie, chosen by Maria July 5) ship in the bundle as
    /// <key>.m4a; when one exists it plays and no synthesis happens. TTS remains only as the
    /// fallback for lines that don't have a recording yet.
    static func say(_ text: String, key: String? = nil) {
        if let key, let url = Bundle.main.url(forResource: key, withExtension: "m4a")
            ?? Bundle.main.url(forResource: key, withExtension: "mp3") {
            player = try? AVAudioPlayer(contentsOf: url)
            player?.play()
            return
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.40
        utterance.pitchMultiplier = 0.95
        utterance.preUtteranceDelay = 0.1
        utterance.voice = voice
        synth.speak(utterance)
    }

    static func hush() {
        synth.stopSpeaking(at: .immediate)
        player?.stop()
    }
}

// MARK: - 2. Relief (incl. THE RAGE OUTLET)

/// Two doors: cool it down or let it out. The rage side keeps the honest science line (venting
/// tends to keep anger hot; calming settles it faster) and the Apple Maps handoff never
/// recommends a specific business today (partnerships are a later, clearly-labelled decision).
struct ReliefSheet: View {
    @State private var raging = false
    @State private var ragePraise = false
    @State private var rageHeldAt: Date?
    @State private var showBreath = false
    @State private var meditation: Meditation?

    var body: some View {
        ExploreSheet(title: "RELIEF",
                     subtitle: "Girl, we need to breathe. Or scream. Your call.",
                     accent: Theme.ember) {
            // The breath: now a guided session behind one tap, voice and all.
            exploreLabel("BREATHE").padding(.top, 26)
            Button {
                Haptics.open(); showBreath = true
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle().strokeBorder(Theme.gold.opacity(0.35), lineWidth: 0.75)
                            .frame(width: 54, height: 54)
                        Circle().fill(Theme.ember.opacity(0.25)).frame(width: 34, height: 34)
                        Image(systemName: "play.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Theme.bone)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("A GUIDED BREATH")
                            .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.16))
                            .foregroundStyle(Theme.bone)
                        Text("One quiet minute. I'll talk you through it.")
                            .font(Theme.body(13).italic()).foregroundStyle(Theme.bone.opacity(0.65))
                    }
                    Spacer()
                    Text("→").font(Theme.body(18)).foregroundStyle(Theme.gold)
                }
                .padding(16)
                .background(
                    ZStack {
                        if let img = UIImage(named: AuraBackdrop.moonlight.rawValue) {
                            Image(uiImage: img).resizable().scaledToFill()
                        } else {
                            Theme.surface
                        }
                        LinearGradient(
                            stops: [.init(color: Theme.void.opacity(0.35), location: 0),
                                    .init(color: Theme.void.opacity(0.82), location: 1)],
                            startPoint: .top, endPoint: .bottom)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Theme.bone.opacity(0.12), lineWidth: 0.5))
                .contentShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
            .padding(.top, 14)
            .sheet(isPresented: $showBreath) { GuidedBreathSheet() }

            // The meditation shelf (July 5, Maria: Kimi-style options, some serious, some fun).
            // Every script is ours, written in-house in LILITH's voice: original words, original
            // structure, so the copyright is ours too.
            exploreLabel("MEDITATIONS").padding(.top, 30)
            VStack(spacing: 0) {
                ForEach(Meditation.catalog) { m in
                    if m.id != Meditation.catalog.first?.id {
                        Rectangle().fill(Theme.gold.opacity(0.12)).frame(height: 0.5)
                    }
                    Button {
                        Haptics.open(); meditation = m
                    } label: {
                        HStack(alignment: .firstTextBaseline) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(m.title)
                                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.14))
                                    .foregroundStyle(Theme.bone)
                                Text(m.sub)
                                    .font(Theme.body(13).italic())
                                    .foregroundStyle(Theme.bone.opacity(0.6))
                            }
                            Spacer()
                            Text("1 · 3 · 5 MIN")
                                .font(Theme.mono(9)).tracking(Theme.tracking(9, em: 0.12))
                                .foregroundStyle(Theme.gold.opacity(0.7))
                        }
                        .padding(.vertical, 14)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 10)
            .sheet(item: $meditation) { MeditationSheet(meditation: $0) }

            // The rage outlet.
            exploreLabel("THE RAGE OUTLET", color: Theme.blood).padding(.top, 34)
            exploreBody("Real talk first: the research says venting feels incredible and tends to keep the anger hot, while calming actually cools it. Informed queens only. That said, sometimes a girl needs to break a plate.")
                .padding(.top, 8)

            // In-app release: hold, flood the haptics, let it flare.
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Theme.blood.opacity(raging ? 0.45 : 0.18))
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Theme.blood.opacity(raging ? 1 : 0.6), lineWidth: 1)
                Text(raging ? "LET IT ALL OUT" : "HOLD TO SCREAM INTO THE VOID")
                    .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.16))
                    .foregroundStyle(Theme.bone)
            }
            .frame(height: 64)
            .scaleEffect(raging ? 1.03 : 1)
            .animation(.easeInOut(duration: 0.15), value: raging)
            .padding(.top, 16)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !raging { rageHeldAt = Date() }
                        raging = true
                    }
                    .onEnded { _ in
                        raging = false
                        // she really let it out: the friend says so, out loud
                        if let start = rageHeldAt, Date().timeIntervalSince(start) >= 1.2 {
                            CalmVoice.say("Great girl. You needed that.", key: "rage-praise")
                            ragePraise = true
                            Task {
                                try? await Task.sleep(nanoseconds: 4_000_000_000)
                                ragePraise = false
                            }
                        }
                        rageHeldAt = nil
                    }
            )
            .task(id: raging) {
                // a slow drumbeat of haptics while she holds; stops the moment she lets go
                while raging {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    try? await Task.sleep(nanoseconds: 140_000_000)
                }
            }
            Text(raging ? "the void hears you, girl"
                 : ragePraise ? "great girl. you needed that."
                 : "nothing gets recorded, obviously")
                .font(Theme.body(12).italic())
                .foregroundStyle(ragePraise ? Theme.gold : Theme.bone.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
                .animation(.easeInOut(duration: 0.3), value: ragePraise)

            // The real-world handoff: Apple Maps searches, never a specific business (yet:
            // partner placements are a future, clearly-labelled call of Maria's). July 5: the
            // seven stacked capsules read as Minecraft blocks (Maria); now they're two quiet
            // chip constellations.
            exploreLabel("TAKE IT OUTSIDE").padding(.top, 30)
            Text("Tap one and Apple Maps finds it near you.")
                .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.6))
                .padding(.top, 6)

            Text("LET IT OUT")
                .font(Theme.mono(8.5)).tracking(Theme.tracking(8.5, em: 0.24))
                .foregroundStyle(Theme.blood.opacity(0.9))
                .padding(.top, 16)
            FlowLayout(spacing: 9) {
                mapsChip("RAGE ROOMS", query: "rage room")
                mapsChip("AXE THROWING", query: "axe throwing")
                mapsChip("BOXING", query: "boxing gym")
            }
            .padding(.top, 8)

            Text("COOL IT DOWN")
                .font(Theme.mono(8.5)).tracking(Theme.tracking(8.5, em: 0.24))
                .foregroundStyle(Theme.gold.opacity(0.85))
                .padding(.top, 16)
            FlowLayout(spacing: 9) {
                mapsChip("SPA DAY", query: "spa")
                mapsChip("SAUNA & PLUNGE", query: "sauna")
                mapsChip("HOT YOGA", query: "hot yoga")
                mapsChip("POTTERY PAINTING", query: "pottery painting studio")
            }
            .padding(.top, 8)

            Text("I don't pick businesses and I never know where you went.")
                .font(Theme.body(12).italic()).foregroundStyle(Theme.bone.opacity(0.5))
                .padding(.top, 12)

            Text("If the anger feels bigger than a bad week and it keeps coming back, that's worth a real conversation with a professional. That's not weakness, that's maintenance.")
                .font(Theme.body(12)).foregroundStyle(Theme.gold.opacity(0.7))
                .lineSpacing(4)
                .padding(.top, 22)
        }
    }

    private func mapsChip(_ title: String, query: String) -> some View {
        Link(destination: URL(string: "maps://?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)")!) {
            HStack(spacing: 6) {
                Text(title)
                    .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.12))
                    .foregroundStyle(Theme.bone.opacity(0.9))
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(Theme.gold.opacity(0.8))
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Capsule().fill(.ultraThinMaterial)
                .overlay(Capsule().strokeBorder(Theme.gold.opacity(0.3), lineWidth: 0.5)))
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 3. Moon lore

/// Tonight's real phase plus the old stories, clearly labelled as story. The red/white moon lore
/// already lives on the Cycle tab when it applies; here it gets the full telling.
struct MoonLoreSheet: View {
    private let moon = (try? ChartEngine.moonPhase()) ?? .fullMoon

    private func lore(_ p: MoonPhase) -> String {
        switch p {
        case .newMoon: "The blank page. Old-school witches set intentions now; modern girls write the list and tell no one yet. Beginnings like the dark."
        case .waxingCrescent: "The first commitment. Whatever you planted at the new moon, water it once and walk away. Sprouts hate being watched."
        case .firstQuarter: "The friction point. Halfway to full, the universe asks if you actually meant it. Say yes and push."
        case .waxingGibbous: "The final polish. Almost full, almost ready. Don't rush the reveal; the last coat of gloss is the one people notice."
        case .fullMoon: "Everything is loud: feelings, group chats, the city outside. Harvest what's yours and release what isn't. Lore says charge your crystals; at minimum charge your phone."
        case .waningGibbous: "The gratitude beat. Share what worked, teach it, toast it. Abundance is a better look when it circulates."
        case .lastQuarter: "The clear-out. Forgive, delete, unsubscribe. You're traveling into the dark half; pack light."
        case .waningCrescent: "The exhale before the blank page. Rest is productive here, and the sky is doing it too."
        }
    }

    var body: some View {
        ExploreSheet(title: "MOON LORE",
                     subtitle: "Tonight's sky and the old stories.", glyph: "☾") {
            VStack(spacing: 14) {
                Image(systemName: CycleView.moonSymbol(moon))
                    .font(.system(size: 44, weight: .ultraLight))
                    .foregroundStyle(Theme.bone)
                Text(moon.rawValue.uppercased())
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.26))
                    .foregroundStyle(Theme.gold)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 30)

            exploreLabel("TONIGHT").padding(.top, 26)
            exploreBody(lore(moon)).padding(.top, 8)

            exploreLabel("RED MOON, WHITE MOON").padding(.top, 28)
            exploreBody("The old lore sorts cycles by the sky. Bleeding with the new moon is the White Moon cycle: the mother, the nurturer, energy folded inward, the classic rhythm of rest. Bleeding with the full moon is the Red Moon cycle: the healer, the wild woman, energy turned outward while everyone else is winding down. Neither is better and both drift; your body changes its mind whenever it wants to.")
                .padding(.top, 8)

            Text("None of this is science, it's story, and stories are allowed to be useful. Wear it if it fits, leave it if it doesn't.")
                .font(Theme.body(12)).foregroundStyle(Theme.gold.opacity(0.7))
                .lineSpacing(4)
                .padding(.top, 24)
        }
    }
}

// MARK: - 4. Decode a symptom (the Cyclepedia move, LILITH-sized)

/// Every symptom she can log, decoded: what's classically behind it, what tends to help, and the
/// clearly-marked line where it stops being an app's business and becomes a provider's.
struct SymptomDecoderSheet: View {
    private struct Decode { let symptom: CycleSymptom; let what: String; let doctor: String }

    private let decodes: [Decode] = [
        Decode(symptom: .cramps,
               what: "The uterus is a muscle doing heavy work, and prostaglandins are the chemical foreman. Heat, gentle movement, and magnesium classically take the edge off.",
               doctor: "Cramps that derail your life every single month are not the price of womanhood. That's a provider conversation, and you deserve to have it."),
        Decode(symptom: .headache,
               what: "Hormone dips, especially the estrogen drop right before your period, are classic headache windows. Water, sleep, and knowing your pattern help.",
               doctor: "A sudden, worst-ever headache is a doctor thing immediately, not a cycle thing."),
        Decode(symptom: .bloating,
               what: "Progesterone slows digestion in the luteal phase, typically, which is why jeans lie in week four. It usually eases once the bleed starts.",
               doctor: "Bloating that's painful, persistent, and doesn't follow your cycle deserves a check, not a bigger waistband."),
        Decode(symptom: .tender,
               what: "Breasts often get dramatic when progesterone runs the show, and it classically settles as the period arrives.",
               doctor: "A new lump, one-sided change, or skin change is always a provider visit, no waiting, no googling spirals."),
        Decode(symptom: .lowEnergy,
               what: "The premenstrual dip and the bleed are low-battery by design; both hormones are at the floor. Rest counts as doing something.",
               doctor: "Exhausted every day of every cycle is different. Ask a provider about iron and thyroid; that's their department, not mine."),
        Decode(symptom: .breakout,
               what: "The pre-period breakout is textbook: hormones shift, oil production reacts. A gentle, boring routine beats panic-scrubbing.",
               doctor: "Deep, painful, scarring acne deserves professional backup. Dermatologists exist and they're good at this."),
        Decode(symptom: .nausea,
               what: "Some girls get a queasy day one; prostaglandins don't stay in their lane. Small warm meals and ginger classically help.",
               doctor: "Nausea that's frequent, severe, or paired with serious pain is a provider question, today rather than someday."),
        Decode(symptom: .insomnia,
               what: "Sleep classically goes shallow in late luteal; the progesterone slide stirs the night. Cool room, boring book, no 2am scroll.",
               doctor: "Insomnia that ignores your cycle and runs every week deserves real help. Sleep is not a luxury item.")
    ]

    var body: some View {
        ExploreSheet(title: "DECODE A SYMPTOM",
                     subtitle: "What's typical, what helps, what's a doctor.") {
            ForEach(decodes, id: \.symptom) { d in
                VStack(alignment: .leading, spacing: 8) {
                    Text(d.symptom.label)
                        .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.2))
                        .foregroundStyle(Theme.ember)
                    exploreBody(d.what)
                    Text(d.doctor)
                        .font(Theme.body(13)).foregroundStyle(Theme.gold.opacity(0.8))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.leading, 12)
                        .overlay(Rectangle().fill(Theme.gold.opacity(0.4)).frame(width: 0.5),
                                 alignment: .leading)
                }
                .padding(.top, 26)
            }

        }
    }
}

// MARK: - The guided breath (July 5, Maria's spec: tap to start, a timer, and a calm voice
// walking her through it: in, hold, exhale, release all negative energy)

struct GuidedBreathSheet: View {
    @Environment(\.dismiss) private var dismiss

    private enum Stage { case ready, running, done }
    private enum BreathPhase: String { case inhale = "BREATHE IN", hold = "HOLD", exhale = "LET IT GO" }

    @State private var stage: Stage = .ready
    @State private var minutes = 1
    @State private var phase: BreathPhase = .inhale
    @State private var secondsLeft = 0
    @State private var full = false          // ring swell state
    @State private var session: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 0) {
            Text("A GUIDED BREATH")
                .displayCaps(24, em: 0.14)
                .padding(.leading, Theme.tracking(24, em: 0.14))
                .padding(.top, 54)
            Text(stage == .done ? "Lighter already." : "In, hold, out. I've got you.")
                .font(Theme.body(15).italic()).foregroundStyle(Theme.gold)
                .padding(.top, 8)

            Spacer()

            ZStack {
                Circle().strokeBorder(Theme.gold.opacity(0.25), lineWidth: 0.75)
                    .frame(width: 230, height: 230)
                Circle().fill(Theme.ember.opacity(0.22))
                    .frame(width: 200, height: 200)
                    .scaleEffect(full ? 1.0 : 0.5)
                VStack(spacing: 8) {
                    Text(stage == .running ? phase.rawValue : stage == .done ? "DONE" : "READY?")
                        .font(Theme.mono(13)).tracking(Theme.tracking(13, em: 0.26))
                        .foregroundStyle(Theme.bone)
                    if stage == .running {
                        Text(timeString)
                            .font(Theme.data(22)).foregroundStyle(Theme.bone.opacity(0.7))
                    }
                }
            }

            Spacer()

            if stage == .ready {
                HStack(spacing: 10) {
                    ForEach([1, 2, 3], id: \.self) { m in
                        Button {
                            Haptics.light(); minutes = m
                        } label: {
                            LuxChip(label: "\(m) MIN", on: minutes == m, accent: Theme.gold)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Button {
                    Haptics.soft()
                    session = Task { await run() }
                } label: {
                    Text("BEGIN")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.2))
                        .foregroundStyle(Theme.void)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Theme.gold))
                        .background(Capsule().fill(Theme.gold).opacity(0.4).blur(radius: 18))
                }
                .buttonStyle(.plain)
                .padding(.top, 18)
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            } else if stage == .running {
                Button {
                    endSession()
                } label: {
                    Text("THAT'S ENOUGH")
                        .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.16))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 28).padding(.vertical, 13)
                        .overlay(Capsule().strokeBorder(Theme.gold.opacity(0.45), lineWidth: 0.75))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 46)
            } else {
                Button {
                    dismiss()
                } label: {
                    Text("BACK TO IT")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.2))
                        .foregroundStyle(Theme.void)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Theme.gold))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 30)
                .padding(.bottom, 46)
            }
        }
        .glassSheet(glyph: "", accent: Theme.ember)
        .overlay(alignment: .topTrailing) {
            Button { endSession(); dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
        .onDisappear { endSession() }
    }

    private var timeString: String {
        String(format: "%d:%02d", secondsLeft / 60, secondsLeft % 60)
    }

    private func endSession() {
        session?.cancel()
        session = nil
        CalmVoice.hush()
        if stage == .running { stage = .done }
    }

    /// The session itself: 4 in, 4 held, 6 out, the voice leading each turn, until time is up.
    private func run() async {
        stage = .running
        let total = minutes * 60
        secondsLeft = total
        let started = Date()
        CalmVoice.say("Settle in. Shoulders down from your ears. We breathe together now.",
                      key: "breath-settle")
        try? await Task.sleep(nanoseconds: 3_500_000_000)

        let script: [(BreathPhase, Double, [String], String)] = [
            (.inhale, 4, ["Breathe in. Slow and deep.", "In through the nose. Fill all the way up."], "breath-in"),
            (.hold, 4, ["Hold it right there.", "Hold. You're safe."], "breath-hold"),
            (.exhale, 6, ["Exhale. Release every bit of negative energy.", "Out, slow. Let all of it go."], "breath-out"),
        ]
        var round = 0
        while !Task.isCancelled, Date().timeIntervalSince(started) < Double(total) {
            for (p, dur, lines, keyPrefix) in script {
                guard !Task.isCancelled else { return }
                phase = p
                if p == .inhale { withAnimation(.easeInOut(duration: dur)) { full = true } }
                if p == .exhale { withAnimation(.easeInOut(duration: dur)) { full = false } }
                CalmVoice.say(lines[round % lines.count], key: "\(keyPrefix)-\(round % lines.count)")
                try? await Task.sleep(nanoseconds: UInt64(dur * 1_000_000_000))
                secondsLeft = max(0, total - Int(Date().timeIntervalSince(started)))
            }
            round += 1
        }
        guard !Task.isCancelled else { return }
        stage = .done
        Haptics.soft()
        CalmVoice.say("That's it. Lighter already. Great girl.", key: "breath-done")
    }
}

// MARK: - The meditation library (July 5, Maria's spec: options like Kimi's, serious and fun)
//
// Legal note, because she asked: these scripts are ORIGINAL writing, in-house, in LILITH's voice.
// Meditation techniques themselves (breathing, body scans, counting) are not copyrightable; only
// specific wording is, and this wording is ours. Never copy Headspace/Calm scripts, never use a
// cloned voice of a real person without written consent. Guided relaxation is wellness content,
// same rules as everything: no medical claims, and it never replaces treatment for anxiety.

struct Meditation: Identifiable {
    let id: String
    let title: String
    let sub: String
    let script: [(line: String, pause: Double)]

    var minutes: Int {
        max(1, Int((script.reduce(0) { $0 + $1.pause } / 60).rounded()))
    }

    static let catalog: [Meditation] = [
        Meditation(id: "morning", title: "MORNING RESET",
                   sub: "before the day starts asking things",
                   script: [
                    ("Good morning. Before the phone, before the list, before anyone needs you. This minute is yours.", 8),
                    ("Breathe in slow, and let the day wait outside the door.", 8),
                    ("Exhale. You don't owe the morning speed.", 8),
                    ("Think of one thing today that's actually yours. Not a task. A moment.", 10),
                    ("Whatever happens today, you've survived every single day so far. Undefeated, actually.", 9),
                    ("One more slow breath. In... and out.", 9),
                    ("Now go. Softly at first. The day can catch up to you.", 6),
                   ]),
        Meditation(id: "offswitch", title: "THE OFF SWITCH",
                   sub: "for evenings that will not log off",
                   script: [
                    ("The day is done. Whether it went well is no longer today's business.", 9),
                    ("Unclench your jaw. Drop your shoulders. Yes, they were up again.", 9),
                    ("Breathe out longer than you breathe in. That's the whole trick to switching off.", 10),
                    ("Whatever you didn't finish will still be there tomorrow, and tomorrow-you is very capable.", 10),
                    ("Let the last replay of that conversation go. You said what you said. It was fine.", 10),
                    ("In... and all the way out. The night is yours now.", 9),
                    ("Rest isn't a reward you earn. It's just yours. Take it.", 6),
                   ]),
        Meditation(id: "coworker", title: "THE COWORKER ONE",
                   sub: "for professional composure, barely",
                   script: [
                    ("Okay. Deep breath. We are not getting fired today over this person.", 8),
                    ("Breathe in patience. Exhale the email you want to send but should not.", 9),
                    ("They are someone's problem forever. They are only yours until five.", 9),
                    ("Unclench the jaw. They are not worth the dental work.", 9),
                    ("Picture your peace as a door. They knock. You simply do not answer.", 10),
                    ("One more breath. In... and out. Composure restored, allegedly.", 8),
                    ("Now go be unbothered. It drives them crazy anyway.", 6),
                   ]),
        Meditation(id: "pms", title: "PMS PEACE TREATY",
                   sub: "for week four diplomacy",
                   script: [
                    ("First things first: you're not crazy, it's chemistry. Progesterone is doing this, not you.", 9),
                    ("Breathe in. The rage is real, and it's also temporary.", 9),
                    ("Exhale. You don't have to fix anything tonight. Not the house, not the people, not yourself.", 10),
                    ("The bar is on the floor this week and that's exactly where it belongs.", 9),
                    ("Warmth helps. Snacks help. Saying no helps most of all.", 9),
                    ("In... and out. Softer plans, softer people. That's the treaty.", 9),
                    ("A few more days and the sun comes back up. It always does.", 6),
                   ]),
        Meditation(id: "sleep", title: "CAN'T SLEEP, WON'T SLEEP",
                   sub: "for the 2am brain",
                   script: [
                    ("Hi. It's late. The brain is doing its little tour of everything since 2016. We're closing the exhibit.", 10),
                    ("Breathe in slow... and out even slower. Nothing needs solving at this hour.", 10),
                    ("That embarrassing thing? Everyone forgot it. You're the only visitor it gets.", 10),
                    ("Let the bed hold you. That's its whole job. You don't have to help.", 10),
                    ("In... and a long way out. Heavy arms. Heavy eyes.", 10),
                    ("Tomorrow's problems open at nine. You're not on shift.", 10),
                    ("Time to sleep. Goodnight, girl. I'll be here in the morning.", 5),
                   ]),
        Meditation(id: "maincharacter", title: "MAIN CHARACTER PREP",
                   sub: "for right before you walk in",
                   script: [
                    ("Alright. Shoulders back. We're walking in like we were invited, because we were.", 8),
                    ("Breathe in. You've done harder things than this on worse sleep.", 9),
                    ("Exhale the doubt. It never once helped you.", 8),
                    ("You're not asking to be there. You're arriving. There's a difference and everyone feels it.", 10),
                    ("Stop. Breathe. You got this. Who slays all day? You do.", 9),
                    ("One more breath, deep and slow. That's the walk-in breath.", 9),
                    ("Remember: you are the prize. Act accordingly.", 7),
                    ("Now go. Let them look.", 5),
                   ]),
    ]
}

/// One meditation, played: the voice reads each line on its own pace while the ring breathes.
/// Same session grammar as the guided breath so nothing needs relearning.
struct MeditationSheet: View {
    let meditation: Meditation
    @Environment(\.dismiss) private var dismiss

    @State private var running = false
    @State private var done = false
    @State private var currentLine = ""
    @State private var swell = false
    @State private var minutes = 1
    @State private var session: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 0) {
            Text(meditation.title)
                .displayCaps(22, em: 0.14)
                .padding(.leading, Theme.tracking(22, em: 0.14))
                .padding(.top, 54)
            Text(meditation.sub)
                .font(Theme.body(15).italic()).foregroundStyle(Theme.gold)
                .padding(.top, 8)

            Spacer()

            ZStack {
                Circle().strokeBorder(Theme.gold.opacity(0.25), lineWidth: 0.75)
                    .frame(width: 210, height: 210)
                Circle().fill(Theme.ember.opacity(0.20))
                    .frame(width: 180, height: 180)
                    .scaleEffect(swell ? 1.0 : 0.6)
                    .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: swell)
            }
            .padding(.bottom, 26)

            Text(done ? "You did it, queen. Carry it lightly." : currentLine)
                .font(Theme.body(16).italic())
                .foregroundStyle(Theme.bone.opacity(0.9))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .frame(minHeight: 90, alignment: .top)
                .padding(.horizontal, 34)
                .animation(.easeInOut(duration: 0.4), value: currentLine)

            Spacer()

            if !running && !done {
                HStack(spacing: 10) {
                    ForEach([1, 3, 5], id: \.self) { m in
                        Button {
                            Haptics.light(); minutes = m
                        } label: {
                            LuxChip(label: "\(m) MIN", on: minutes == m, accent: Theme.gold)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 14)
                Button {
                    Haptics.soft()
                    session = Task { await run() }
                } label: {
                    Text("BEGIN")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.2))
                        .foregroundStyle(Theme.void)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Theme.gold))
                        .background(Capsule().fill(Theme.gold).opacity(0.4).blur(radius: 18))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 30)
                .padding(.bottom, 46)
            } else if running {
                Button {
                    endSession()
                } label: {
                    Text("THAT'S ENOUGH")
                        .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.16))
                        .foregroundStyle(Theme.gold)
                        .padding(.horizontal, 28).padding(.vertical, 13)
                        .overlay(Capsule().strokeBorder(Theme.gold.opacity(0.45), lineWidth: 0.75))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 46)
            } else {
                Button { dismiss() } label: {
                    Text("BACK TO IT")
                        .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.2))
                        .foregroundStyle(Theme.void)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Capsule().fill(Theme.gold))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 30)
                .padding(.bottom, 46)
            }
        }
        .glassSheet(glyph: "", accent: Theme.ember)
        .overlay(alignment: .topTrailing) {
            Button { endSession(); dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.18))
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
        .onAppear { swell = true }
        .onDisappear { endSession() }
    }

    private func endSession() {
        session?.cancel()
        session = nil
        CalmVoice.hush()
        if running { running = false; done = true }
    }

    /// Play the script, stretched to her chosen length: pauses scale up for longer sessions, and
    /// anything past the script becomes quiet time with a soft cue every half minute, so a 5-minute
    /// sit is mostly silence held open, exactly like a real guide does it.
    private func run() async {
        running = true
        let target = Double(minutes * 60)
        let base = meditation.script.reduce(0) { $0 + $1.pause }
        let scale = min(2.2, max(1.0, target / base))
        let started = Date()

        for (index, step) in meditation.script.enumerated() {
            guard !Task.isCancelled else { return }
            currentLine = step.line
            // cast-voice files, when they exist, are named <meditationID>-<lineIndex>.mp3
            CalmVoice.say(step.line, key: "\(meditation.id)-\(index)")
            try? await Task.sleep(nanoseconds: UInt64(step.pause * scale * 1_000_000_000))
        }

        let fillers = [
            "Just breathe. I've got you.",
            "In... and slowly out.",
            "Still here. No rush at all.",
            "Let the shoulders fall again.",
        ]
        var i = 0
        while !Task.isCancelled, Date().timeIntervalSince(started) < target - 12 {
            currentLine = fillers[i % fillers.count]
            CalmVoice.say(fillers[i % fillers.count], key: "filler-\(i % fillers.count)")
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            i += 1
        }

        guard !Task.isCancelled else { return }
        currentLine = "You did it, queen."
        CalmVoice.say("You did it, queen. Carry it lightly.", key: "closing")
        running = false
        done = true
        Haptics.soft()
    }
}
