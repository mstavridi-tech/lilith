import SwiftUI

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
                card("rectangle.grid.2x2", "THE PHASE PLAYBOOK", "move, eat, work, love, by phase") {
                    showPlaybook = true
                }
                card("wind", "RELIEF", "breathe it out or rage it out") {
                    showRelief = true
                }
                card("moon.stars", "MOON LORE", "tonight's sky, old stories") {
                    showLore = true
                }
                card("text.magnifyingglass", "DECODE A SYMPTOM", "what's typical, what's a doctor") {
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

    private func card(_ symbol: String, _ title: String, _ sub: String,
                      action: @escaping () -> Void) -> some View {
        Button {
            Haptics.light(); action()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(Theme.gold)
                Text(title)
                    .font(Theme.mono(10.5)).tracking(Theme.tracking(10.5, em: 0.14))
                    .foregroundStyle(Theme.bone)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(sub)
                    .font(Theme.body(12).italic())
                    .foregroundStyle(Theme.bone.opacity(0.55))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(RoundedRectangle(cornerRadius: 18).fill(Theme.void.opacity(0.35)))
                    .overlay(RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Theme.bone.opacity(0.10), lineWidth: 0.5))
            )
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

            Text("Typical patterns, not prescriptions. Your body sets the real schedule, and it's allowed to disagree with the textbook.")
                .font(Theme.body(12)).foregroundStyle(Theme.gold.opacity(0.7))
                .lineSpacing(4)
                .padding(.top, 24)
        }
    }
}

// MARK: - 2. Relief (incl. THE RAGE OUTLET)

/// Two doors: cool it down or let it out. The rage side keeps the honest science line (venting
/// tends to keep anger hot; calming settles it faster) and the Apple Maps handoff never
/// recommends a specific business, per the hard rule.
struct ReliefSheet: View {
    @State private var breathing = false
    @State private var raging = false

    var body: some View {
        ExploreSheet(title: "RELIEF",
                     subtitle: "Cool it down, or let it out. Your call.",
                     accent: Theme.ember, glyph: "❋") {
            // The breath: a slow ring. In for four, out for four.
            exploreLabel("BREATHE").padding(.top, 26)
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .strokeBorder(Theme.gold.opacity(0.25), lineWidth: 0.75)
                        .frame(width: 150, height: 150)
                    Circle()
                        .fill(Theme.ember.opacity(0.22))
                        .frame(width: 130, height: 130)
                        .scaleEffect(breathing ? 1.0 : 0.55)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true),
                                   value: breathing)
                    Text("IN · OUT")
                        .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.3))
                        .foregroundStyle(Theme.bone.opacity(0.8))
                }
                Text("In for four, out for four, shoulders down from your ears. Stay a minute; the nervous system catches up fast.")
                    .font(Theme.body(14)).foregroundStyle(Theme.bone.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
            .onAppear { breathing = true }

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
                    .onChanged { _ in raging = true }
                    .onEnded { _ in raging = false }
            )
            .task(id: raging) {
                // a slow drumbeat of haptics while she holds; stops the moment she lets go
                while raging {
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    try? await Task.sleep(nanoseconds: 140_000_000)
                }
            }
            Text(raging ? "the void hears you, girl" : "nothing gets recorded, obviously")
                .font(Theme.body(12).italic()).foregroundStyle(Theme.bone.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)

            // The real-world handoff: Apple Maps searches, never a specific business.
            exploreLabel("TAKE IT OUTSIDE").padding(.top, 30)
            VStack(spacing: 12) {
                mapsButton("RAGE ROOMS NEAR ME", query: "rage room")
                mapsButton("SPAS NEAR ME", query: "spa")
                mapsButton("BOXING GYMS NEAR ME", query: "boxing gym")
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

            Text("Pattern talk, never diagnosis. I describe what's classic; your body and your provider hold the actual facts.")
                .font(Theme.body(12)).foregroundStyle(Theme.gold.opacity(0.7))
                .lineSpacing(4)
                .padding(.top, 26)
        }
    }
}
