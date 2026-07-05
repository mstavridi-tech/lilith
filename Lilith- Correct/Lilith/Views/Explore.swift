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
    var glyph: String = "✶"
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
                            .font(Theme.mono(9)).tracking(Theme.tracking(9, em: 0.1))
                            .foregroundStyle(selected == phase ? Theme.bone : Theme.bone.opacity(0.6))
                            .padding(.horizontal, 10).padding(.vertical, 9)
                            .background(
                                Capsule().fill(selected == phase ? phase.aura.opacity(0.25) : .clear)
                                    .overlay(Capsule().strokeBorder(
                                        selected == phase ? phase.aura.opacity(0.8) : Theme.bone.opacity(0.2),
                                        lineWidth: 0.75))
                            )
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

    static func say(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = 0.42
        utterance.pitchMultiplier = 0.9
        utterance.preUtteranceDelay = 0.1
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synth.speak(utterance)
    }

    static func hush() { synth.stopSpeaking(at: .immediate) }
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

    var body: some View {
        ExploreSheet(title: "RELIEF",
                     subtitle: "Cool it down, or let it out. Your call.",
                     accent: Theme.ember, glyph: "❋") {
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
                    RoundedRectangle(cornerRadius: 18).fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(Theme.gold.opacity(0.3), lineWidth: 0.5))
                )
                .contentShape(RoundedRectangle(cornerRadius: 18))
            }
            .buttonStyle(.plain)
            .padding(.top, 14)
            .sheet(isPresented: $showBreath) { GuidedBreathSheet() }

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
                            CalmVoice.say("Great girl. You needed that.")
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
            // partner placements are a future, clearly-labelled call of Maria's).
            exploreLabel("TAKE IT OUTSIDE · LET IT OUT").padding(.top, 30)
            VStack(spacing: 12) {
                mapsButton("RAGE ROOMS NEAR ME", query: "rage room")
                mapsButton("AXE THROWING NEAR ME", query: "axe throwing")
                mapsButton("BOXING & KICKBOXING NEAR ME", query: "boxing gym")
            }
            .padding(.top, 12)

            exploreLabel("TAKE IT OUTSIDE · COOL IT DOWN").padding(.top, 22)
            VStack(spacing: 12) {
                mapsButton("SPAS NEAR ME", query: "spa")
                mapsButton("SAUNA & COLD PLUNGE NEAR ME", query: "sauna")
                mapsButton("HOT YOGA NEAR ME", query: "hot yoga")
                mapsButton("POTTERY PAINTING NEAR ME", query: "pottery painting studio")
            }
            .padding(.top, 12)
            Text("Apple Maps shows you what's nearby. I don't pick businesses and I never know where you went.")
                .font(Theme.body(12)).foregroundStyle(Theme.bone.opacity(0.5))
                .padding(.top, 10)

            Text("If the anger feels bigger than a bad week and it keeps coming back, that's worth a real conversation with a professional. That's not weakness, that's maintenance.")
                .font(Theme.body(12)).foregroundStyle(Theme.gold.opacity(0.7))
                .lineSpacing(4)
                .padding(.top, 22)
        }
    }

    private func mapsButton(_ title: String, query: String) -> some View {
        Link(destination: URL(string: "maps://?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query)")!) {
            HStack {
                Text(title)
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.14))
                    .foregroundStyle(Theme.gold)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.gold.opacity(0.7))
            }
            .padding(.horizontal, 18).padding(.vertical, 14)
            .background(Capsule().fill(.ultraThinMaterial)
                .overlay(Capsule().strokeBorder(Theme.gold.opacity(0.35), lineWidth: 0.5)))
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
                     subtitle: "What's typical, what helps, what's a doctor.", glyph: "✧") {
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
                            Text("\(m) MIN")
                                .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.14))
                                .foregroundStyle(minutes == m ? Theme.bone : Theme.bone.opacity(0.6))
                                .padding(.horizontal, 20).padding(.vertical, 11)
                                .background(Capsule().fill(Theme.ember.opacity(minutes == m ? 0.28 : 0))
                                    .overlay(Capsule().strokeBorder(
                                        Theme.ember.opacity(minutes == m ? 0.9 : 0.35), lineWidth: 0.75)))
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
        .glassSheet(glyph: "❋", accent: Theme.ember)
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
        CalmVoice.say("Settle in. Shoulders down from your ears. We breathe together now.")
        try? await Task.sleep(nanoseconds: 3_500_000_000)

        let script: [(BreathPhase, Double, [String])] = [
            (.inhale, 4, ["Breathe in. Slow and deep.", "In through the nose. Fill all the way up."]),
            (.hold, 4, ["Hold it right there.", "Hold. You're safe."]),
            (.exhale, 6, ["Exhale. Release every bit of negative energy.", "Out, slow. Let all of it go."]),
        ]
        var round = 0
        while !Task.isCancelled, Date().timeIntervalSince(started) < Double(total) {
            for (p, dur, lines) in script {
                guard !Task.isCancelled else { return }
                phase = p
                if p == .inhale { withAnimation(.easeInOut(duration: dur)) { full = true } }
                if p == .exhale { withAnimation(.easeInOut(duration: dur)) { full = false } }
                CalmVoice.say(lines[round % lines.count])
                try? await Task.sleep(nanoseconds: UInt64(dur * 1_000_000_000))
                secondsLeft = max(0, total - Int(Date().timeIntervalSince(started)))
            }
            round += 1
        }
        guard !Task.isCancelled else { return }
        stage = .done
        Haptics.soft()
        CalmVoice.say("That's it. Lighter already. Great girl.")
    }
}
