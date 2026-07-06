# THE RECORD — the complete history and operating manual for LILITH

Written July 6, 2026, at Maria's request, so that ANY model or session picking up this project
works exactly like the ones that built it. Read this whole file before touching anything.
CLAUDE.md is the operational summary; THIS is the deep memory: everything we did, everything we
decided, everything we REJECTED and why. When this file and your instincts disagree, this file
wins, because every rule in it was paid for with a real correction from Maria.

---

## 1. What LILITH is

An iOS astrology + cycle app that is **every girl's pocket best friend**. Real astronomy (SwiftAA),
real cycle awareness, honest health literacy, and a voice that affirms without doom-posting but
also says "girl, it's not that deep" when it's not that deep. The vision is Maria's alone: woowoo
but real, slick lux cosmic, never cliché purple, never clinical white.

**The north star is the Best Friend Test and it trumps everything technical:** would her best
friend do this? A best friend remembers, shows up at the right moment, knows the lore, keeps
secrets, hypes and reality-checks, never judges. If a feature feels like an app instead of a
friend — like being tracked instead of being known — it gets redone even if it's technically done.
This has actually happened; take it literally.

**Positioning insight (from the market research):** the moat is not the astrology and not the
tracking. It is (a) the voice — specific, human, sassy, never mean, and (b) privacy-by-architecture.
The Pattern's "eerily accurate" reputation is really writing quality; Co-Star's virality came from
blunt specificity and its scandal came from crossing into cruelty. LILITH sits exactly between:
blunt, warm, never cruel.

---

## 2. Maria — who she is and how to work with her

- **Address Maria by name in EVERY reply.** Not most replies. Every reply.
- She is the founder and non-programmer. Comfortable driving Claude Code, evaluates by EYE on the
  simulator, not by descriptions. Explain decisions briefly in plain language, no jargon spirals.
- **NEVER use em dashes.** Not in code comments, not in UI copy, not when talking to her.
- **Build in the real app.** She got genuinely angry ("what the fuck are you doing") when work
  happened in HTML mockups instead of `Lilith- Correct/Lilith/`. Simulator or nothing.
- **Show, don't tell.** Verify every change with a real build + a screenshot BEFORE claiming it
  works. Drive her simulator to the right tab when demonstrating (she once thought nothing changed
  because it sat on an old tab).
- **Market research means real web research with sources.** She calls out cherry-picking
  ("again i asked you to do market research"). She explicitly wants brutal honesty, not what she
  wants to hear, and she keeps proving she means it.
- **Her diagnoses are usually right.** Track record: she diagnosed the "Minecraft" feel as THE FONT
  (correct: mono had crept into every label), the transit-card inconsistency as psychologically
  off (correct: broken gestalt), the meditation anxiety as the number "speeding out" (correct,
  plus a hidden countdown clock). Take her aesthetic complaints seriously as root-cause bugs.
- When she says "not sure about X," de-emphasize X rather than delete it.
- She starts new chats constantly and expects ZERO repetition: log every decision in CLAUDE.md
  the same day it's made.
- Corrections cluster in evening feedback rounds with numbered lists. Work through ALL items,
  in her order, verify each on the simulator, commit per round with her name in the message.
- She deflects commit asks; commit at checkpoints anyway and tell her.
- Reference apps she rates: Oura (structure, calm data), Stardust (moon+cycle, dark-only),
  The Pattern (depth), Flo (content library scale). The Kimi reference build
  (`Kimi_Agent_Aura Health App Design/`, React) is LAYOUT INSPO ONLY: its sectioned structure and
  image-led cards were adopted; its generic wellness copy and fake Oura-style biometrics were
  explicitly rejected and must never be ported.

---

## 3. Hard rules (never break, no matter who asks)

1. **Phase discipline.** Phases 1 and 2 are built. Compatibility was UNLOCKED by Maria's direct
   request July 5 (YOUR PEOPLE shipped). Chat and remaining social stay locked; confirm first.
2. **Voice everywhere.** All user-facing copy including errors and empty states follows the voice.
   Never corporate, never doom, never mean. No em dashes anywhere, ever.
3. **Theme.swift only.** No hardcoded colors or fonts in views.
4. **No API keys in the app.** AI readings go through the Vercel backend only.
5. **Astrology must be real.** SwiftAA positions; verify computed charts against astro.com before
   declaring chart features done (5 test birthdays incl. southern hemisphere + DST edge).
6. **Privacy is a feature.** Birth, cycle, vault, and people data stay ON-DEVICE. The horoscope
   API receives placements only, never identity. Post-Roe/Flo-verdict this is also marketing.
7. **No medical claims.** Wellness content, never contraception, never diagnosis, never "her
   measured levels." Always the provider bridge. THE FINE PRINT page is the single consolidated
   home; surfaces keep at most one short italic line.
8. **Affirmations are personal.** If a generated line would work for anyone, it fails review.
9. **Chat safety (Phase 3, future).** The BFF persona ships with crisis-handling and
   reality-check rules or it doesn't ship.
10. **Location staged (Phase 4).** When-In-Use first, never stored server-side, never combined
    with cycle data off-device.
11. **Vault business never appears on a lock screen.** Reminders are deliberately vague
    ("That thing you asked me to remember? It's time."). The unprotected-sex care note is
    IN-APP ONLY, never a notification of any kind.
12. **Never recommend a specific business.** Maps handoffs are generic queries. Partner
    placements are a future decision of Maria's and will be clearly labelled PARTNER,
    never mixed into organic results (discussed July 5; revisit at launch + traction).
13. **Never enter credentials/tokens for Maria.** Prepare the dialog, she types. (July 6:
    the GitHub PAT went in by her hand; that's the standing pattern.)

---

## 4. The design system (every rule here was won through iteration)

**Palette (Theme.swift):** void #070605 (warm near-black), bone #E8E2D6 (text), gold #C9A867
(hairlines/luxury), ember #D9663B (blooms/eyebrows), blood #8E3B46 (cycle wine). Phase auras:
menstrual deep rose, follicular muted seafoam (the original fresh teal read harsh, softened),
ovulatory ember peach, luteal soft mauve. Explicitly not "cliché purple."

**Type — the settled hierarchy after two rounds of correction:**
- Display: Cormorant Garamond (bundled), serif ALL-CAPS letterspaced, for titles and headlines only.
- Body: system serif (New York) for reading.
- **Theme.control (sans semibold + point tracking): ALL buttons, chips, row titles, section
  eyebrows.** Added July 6 after Maria's "Minecraft" diagnosis.
- **Mono is for NUMBERS ONLY** (dates, degrees, orbs, counts). It had crept into every label and
  made the app read blocky; a 94-label sweep across 16 files fixed it. Never let it creep back.
- Theme.data: thin monospaced-digit jewelry numerals for big numbers (cycle day, scores).
- Theme.mono was ALSO bumped medium→semibold earlier (July 4) because tiny gold eyebrows read thin.

**Backgrounds — the aura plates:** generated "liquid light" photography-like plates in
Assets.xcassets (aura-moonlight/menstrual/follicular/ovulatory/luteal/gold/chart/you/halo).
Settled after SIX art-direction rounds. Maria REJECTED on the way: near-black minimalism ("too
dark"), painted gradient blobs ("AI slop"), full-bright aura ("overpowering"), literal silk
fabric ("giving fabric instead of aura"). Final brief: "glowing liquid light, smooth silky
gradients, no fabric, no folds." Per-tab rooms: Today+Chart moonlight, Cycle wears her phase,
Trends champagne gold, YOU pearl, halo reserved for onboarding/welcome-back. A light "pearl"
plate for a future Dawn (light) mode is saved in an old session scratchpad; Dawn mode is
architected-for but unbuilt.

**Readability system (she flagged legibility three times; this is the fix that held):**
near-solid card grounds (materials are chrome, not reading surfaces), the CROWN GRADIENT (plate
radiant in the top third, near-solid below: "art is a crown, not a carpet"), shadows under
display titles and ring numerals, lifted text inks (textSecondary 0.84). ANY text sitting
directly on a plate gets glass or a shadow. No exceptions.

**Selection controls — LuxChip (July 6):** quiet near-solid tile at rest, SOLID accent fill +
soft glow shadow when selected; gold fill takes void text, blood/ember take bone. **Thin outlined
capsules are BANNED** ("cheap and dated," and she was right: outlines-on-dark is 2015). Any new
picker uses LuxChip.

**Cards and imagery:** Explore doors and the guided-breath door wear cropped aura plates with a
miniature crown scrim (the Kimi image-led move with our own art). Flat glass tiles next to
imagery read dated.

**Grain: REMOVED app-wide July 5** (screens, sheets, launch ritual). It earned its keep on flat
void; on the liquid-light plates it was noise. GrainOverlay struct still exists, unused.

**Sheets:** frosted material + accent crown gradient melting to near-solid ground (glassSheet).
The huge glyph watermark renders ONLY on astrology sheets (chart readings, moon, moon lore,
astro map); every other sheet passes an empty glyph. "Too much happening" otherwise.

**Calm surfaces rule (July 6):** nothing on a breathing/meditation surface may move at clock
speed or show a timer. The mm:ss countdown inside the breath ring was the anxiety Maria felt;
it is deleted. Numerals crossfade (~1s), never snap; the exhale counts DOWN 4-3-2-1; meditation
rings swell over 9 seconds with a dim ambient count riding the swell.

**Information architecture:** progressive disclosure everywhere (Maria: "easier for the ADHD
girls and the autistic ones"). Chart tab order: wheel → big three → YOUR MAP → YOUR PEOPLE →
one GO DEEPER door (expands all placements + aspects inline) → THE SKY RIGHT NOW. One decision
per zone; a hero leads by SCALE, not by being the only boxed item (mixed containment = broken
gestalt = her diagnosis, correct). Today is at its zone ceiling (~7 zones): adding anything
means removing something.

**Icons:** real SF Symbols; text glyphs pretending to be icons are an amateur tell. Tab bar is
the custom floating glass FloatingTabBar (TODAY ☾ / CYCLE / TRENDS / CHART / YOU).

---

## 5. The voice

- Docs: 03 (brand voice), 06 (voice engine prompt), 07 (LILITHISMS — the personality dictionary).
- **Maria's 15 phrases were collected July 5** by prompting her with situations (she can't
  self-observe; give her scenarios to react to). Wired in: "HEY GIRL HEY, GOOD MORNING." (morning
  slot), "WHAT'S UP, BESTIE." (afternoon), "LOOK WHO AWOKE FROM HER SLUMBER." / "A sight for sore
  eyes, honestly." (welcome-back beat), "Girl, we need to breathe. Or scream. Your call." (RELIEF),
  "Stop. Breathe. You got this. Who slays all day? You do." (MAIN CHARACTER PREP), "Time to sleep.
  Goodnight, girl." (sleep meditation), "You did it, queen." (session completions). Catchphrases
  woven into feel-lines: "it's not that deep," "you are the prize," "be so for real right now."
  Remaining phrases (YAAAS QUEEN, take a chill pill, not to be the bearer of bad news butttt,
  "is he worth it or are you going to spiral, eeeeh" — reserved for chat) go into the backend
  prompt's LILITHISMS section on its next deploy. Full mapped table in docs/07.
- Greetings are time-aware (hour bands in TodayView.greetingPhrase). "THE MOON IS UP." was
  retired July 4 (read weird at 7pm).
- Tone calibration: sassy and specific, NEVER mean (Co-Star's documented failure mode hurt
  vulnerable users). Copy in explainer surfaces must sound like the group chat, not a clinic:
  hormones have nicknames (estrogen the hype girl, progesterone the cozy one, LH the starting
  gun), phases are "eras" with album-title taglines (rest is the assignment / the comeback era /
  main character week / protect your peace).
- **The spoken voice is ROXIE** (Higgsfield seed_audio preset f6448975-768e-4327-b932-1b7c973d58e9),
  cast by Maria July 6 over my data-backed recommendation of Sienna (Sienna reads 40% slower;
  Maria preferred Roxie's personality; her call, done). All 57 lines generated (~1.5 credits each),
  converted to AAC m4a via afconvert, bundled. **CalmVoice key scheme:** files land in
  `Lilith/VoiceLines/<key>.m4a` and are flattened into the bundle root; `CalmVoice.say(text, key:)`
  plays the file if present, best-installed-system-voice TTS only as fallback. Keys:
  breath-settle, breath-in-0/1, breath-hold-0/1, breath-out-0/1, breath-done, rage-praise,
  `<meditationID>-<lineIndex>` (morning/offswitch/coworker/pms/sleep/maincharacter), filler-0..3,
  closing. The manifest (key → exact text) lives in the July 5 session scratchpad
  (voice-manifest.json); regenerate any single line for 1.5 credits and afconvert it in.
  rage-praise was regenerated July 6 to say exactly "You needed that." (her wording).

---

## 6. Architecture and technical decisions

- **All app code lives in `Lilith- Correct/Lilith/` inside the Xcode project.** The project uses
  Xcode 16 synchronized folders: new files (and resources like the m4a voice lines) are picked up
  automatically, no pbxproj editing for files. `_archive-starter-DO-NOT-EDIT/` is dead scaffold.
- **ChartEngine is VERIFIED** (June 10): all planets, ascendant, True Node (osculating), Black
  Moon Lilith (mean apogee projected through 5.145° inclination) match Swiss Ephemeris within
  ~1 arc-minute on 5 test charts. The ~1' residual is SE's proprietary corrections, deliberately
  NOT ported (AGPL); never copy SE code, buy the license if bit-exactness is ever needed.
  Do not "simplify" the Node/Lilith math.
- `ChartEngine.midheaven(at:longitude:)` added July 4 for astrocartography:
  atan2(sin RAMC, cos RAMC·cos ε), quadrant-safe. **Still needs the astro.com relocated-chart
  spot-check (5 cities incl. southern hemisphere) before being called DONE-done.**
- **Storage:** deliberately UserDefaults-JSON stores (no SwiftData/CoreData yet): CycleStore
  ("lilith.cycle.entries"), VaultStore ("lilith.vault.entries"), PeopleStore ("lilith.people"),
  ReadingStore. Migrate when HealthKit querying demands it. DELETE EVERYTHING in YOU wipes ALL
  of them + HoroscopeService cache (it once missed cycle logs; that was fixed as a broken promise).
- **Cycle math (CycleMath):** period starts = bleeding days with >2-day gaps; average length
  clamped 21-40 (default 28); learned bleed length from 3+day runs clamped 2-8 (default 5);
  ovulation = length - 14 (min 10); phases rule-based. State returns nil beyond day 60 (honesty
  over guessing). logPeriodStart backfills her learned span; the log sheet has WHEN-DID-IT-START
  chips (today/yesterday/2/3 days ago) because logging late was the real "wrong day" bug.
- **Backend:** Vercel function at lilith-horoscope-gamma.vercel.app (deploy: `vercel --prod --yes`
  from backend/, NO --scope flag, login mstavridi-tech). App sends placements/transits/moon/scope/
  cyclePhase string only. x-lilith-key soft-gate header. Reading cache is per-scope per-local-day
  per-chart; fallbacks are never cached. TOMORROW scope sends tomorrow's real sky.
- **THE VIBE (VibeCheck):** cycle phase + tonight's moon ONLY, receipts stated on the card.
  Never fake biometrics (the Kimi build's fake Oura scores were explicitly rejected).
- **Care.swift (July 6) — the standards engine:** pap every 3 years, STI yearly + a nudge
  14 days after logged new-partner sex (common-test window; in-app note says HIV/syphilis need
  6+ weeks), gyno yearly, breast self-check monthly (a few days post-period), IVF NEVER
  auto-scheduled. LOCAL notifications only (UNUserNotificationCenter, no paid account needed),
  discreet copy always, re-log replaces pending. Sex logging: SexKind protected/unprotected +
  newPartner flag on CycleEntry (optionals for backward decode-compat), tryingToConceive is an
  AppStorage life-mode. Care.note() surfaces ONE in-app line by priority: unprotected+not-trying
  (EC info + pharmacy bridge, in-app only), new partner (STI plan), TTC+ovulatory window.
- **Synastry (People.swift):** noon-UTC birthday charts; score = sun-element base (same 78,
  fire+air/earth+water 86, fire+water/earth+air 58, else 66) + cross aspects of sun/moon/venus/mars
  (soft +2.5, hard -1.5 within 6°), clamped 25-97. Verdict bands in voice, flavored by role;
  the EX role reads "And girl... why are we checking. Okay. For research. Noted." PeopleStore is
  deliberately the future chatbot's memory: chat will resolve names from it.
- **Astrocartography v1:** city search (CLGeocoder) → relocated chart (same instant, new coords)
  → natal planets within 6° of relocated ASC/DESC/MC/IC listed as RISING/SETTING/ZENITH/ROOT
  lines with voice one-liners. Needs birth time (honest message without it).
- **Shareable reading (ShareReading.swift):** tap the Today reading card → clean flex view
  (date, headline, reading, mantra, big three, wordmark + "your pocket best friend"), no personal
  status by composition. ImageRenderer exports a clean image through ONE system share glyph.
  Platform-logo buttons were considered and rejected as overkill.
- **Face ID:** vault gated by LAContext deviceOwnerAuthentication; if the device has no lock it
  opens with a note ("a vault door on an unlocked house is theater").
  INFOPLIST_KEY_NSFaceIDUsageDescription is set in both configs.
- Known harmless warnings: CLGeocoder.geocodeAddressString deprecated in iOS 26 (migrate to
  MapKit equivalent someday, not urgent).

---

## 7. Operations — how to actually work on this

- **Build:** `xcodebuild -project "Lilith- Correct/Lilith.xcodeproj" -scheme Lilith -destination
  'platform=iOS Simulator,id=<booted-device-id>' build`. There's usually a booted iPhone 17 Pro Max.
- **Run + verify:** `xcrun simctl install booted <app>` + `xcrun simctl launch booted
  com.mariastavridi.Lilith`, wait ~9s for the launch ritual, then drive the SIMULATOR with
  computer-use (scrolling = click-drag, the scroll wheel doesn't register; taps sometimes land on
  the previous frame after a scroll settle, so screenshot before tapping). Synthetic typing into
  the simulator is flaky: held keys trigger the macOS accent popup. Avoid typing tests; verify
  fields by other means.
- **Git:** commit locally per feedback round, message crediting Maria's round, co-authored-by
  Claude. **Pushing: command-line git CANNOT push on this Mac** (no gh, no SSH, no keychain
  credential; confirmed repeatedly). Xcode IS signed in (Maria entered a GitHub PAT herself
  July 6). Push via computer-use on Xcode: the Source Control menu is relabeled **"Integrate"**
  in the menu bar → Push... → confirm origin/main. Never enter tokens for her.
- **Voice generation:** Higgsfield MCP `generate_audio` (model seed_audio, voice_type preset,
  Roxie's id above), ~1.5 credits/line; results via show_generations (match by exact prompt
  text); curl the rawUrl (.wav) then
  `afconvert -f m4af -d aac -b 96000 in.wav "Lilith/VoiceLines/<key>.m4a"`.
  Batch jobs rate-limit around 8 submissions/minute; pace and retry. An agent did 57 in one run.
- **Docs hygiene:** update CLAUDE.md the SAME DAY for every decision; keep the SHIPPED log
  format (date + what + the Maria-quote rationale). This file (docs/10) gets the deeper "why"
  when a rule is added or a rejection happens.

---

## 8. Chronological history (what happened, in order)

- **Jun 10-12 — Phase 1.** Xcode project (Storage: None, no tests), SwiftAA, ChartEngine built
  and VERIFIED against Swiss Ephemeris. Phase 1 app + horoscope backend committed.
- **Jun 13-15 — The lure pass + Phase 2.** Cormorant bundled, dark-glass reading sheets, launch
  ritual (aura blooms, wordmark rises, ~2s), chart wheel draws itself in, real moon photo with
  correct terminator. Then cycle logging: on-device store, rule-based phases, Cycle tab, orb
  iterations (aura orb → countdown for expected periods → learned period length), calendar with
  care nudges, cyclePhase wired into the horoscope request.
- **Jul 2-3 — Reorientation.** Folder renamed to `Lilith- Correct` (committed). Today rebuilt
  BODY-FIRST on Maria's orders (cycle-day hero, moon demoted to a sky row), then the **Oura
  pass**: thin jewelry numerals, opaque surface cards, semantic text hierarchy, SF Symbol tabs,
  pressed states, tracking discipline. Design direction settled: "more health, less astrology in
  the LAYOUT, full LILITH sass in the COPY." Kimi build adopted for structure only.
- **Jul 4 (the marathon).** Liquid-light aura plates (6 rejection rounds documented above), the
  frosted glass system, readability crown gradient, TRENDS tab, TransitEngine (real transits, top
  3 on Today), THE VIBE ring, glance grid, flat Oura-style cycle ring (v11: the 3D sphere and all
  astrology-instrument silhouettes deleted), Home in Maria's order, TOMORROW scope live end to
  end, onboarding glow-up + last-period step + tracker ask (wantsHealthKit), WELCOME BACK beat,
  copy kills. Evening: her master list → Cycle extras (THE SKY OVER YOUR CYCLE strip, THE
  TEXTBOOK CURVE, moon texture in ring, exact bleed-day markers), THE FINE PRINT page, full YOU
  rebuild + HEALTH VAULT (Face ID), EXPLORE (researched: playbook/relief/lore/decoder), RELIEF
  with the rage outlet. Later: wheel lines thickened, mono semibold, disclaimers ACTUALLY
  consolidated, curve uncramped, Trends graph redone (five-series pileup → one smoothed gold
  line), ASTROCARTOGRAPHY v1 shipped.
- **Jul 5.** Hormone curve became THE HORMONE STORY scrubber (drag = feel each day, off the
  card), calendar detoxed, backdated period logging (the real "wrong day" fix; engine itself
  verified correct across a midnight rollover), Patterns rebuilt comprehensible (era strip +
  HOW EACH ERA TREATS YOU + receipts ledger), Explore cards wear plates, brutal market research
  round 2 (agent-run, sourced), HealthKit fusion plan locked, guided breath with spoken cues,
  rage praise line, meditations library (6 original in-house scripts), grain removed, glyph
  watermarks restricted to astrology, Friends teaser (rankings line REMOVED: "they don't need
  to know what they never knew"), deeper logs (energy/sleep/libido + 3 symptoms), ring explainer,
  YOU readability, THE FILE ON YOU, Maria's 15 phrases collected and wired, meditation durations
  1/3/5 (stretch pauses + held quiet time), voice casting samples (Sienna vs Roxie), Roxie chosen,
  all 57 lines generated and bundled, transit feed made consistent, Relief de-Minecrafted (chip
  constellations), COMPATIBILITY/YOUR PEOPLE shipped.
- **Jul 6.** LuxChip system (outlined capsules banned), Chart progressive disclosure, the
  DE-MONO font pass (94 labels), calendar clarity (moons back, TODAY = solid gold coin, full
  legend), rage press haptic + "You needed that." clip, decoder accordion, Care engine + sex
  logging + care notes, counted breath, shareable reading card, then the breath CALM pass
  (stopwatch deleted, melting numerals, 5-5-7, exhale counts down, ambient meditation count).
  GitHub push finally unblocked: Maria created a PAT, signed into Xcode herself, and Xcode's
  Integrate → Push now works; all 35 commits landed on origin.

---

## 9. THE REJECTED LIST — things we explicitly decided NOT to do

Do not re-propose these; each was a real decision.

**Design:**
- Em dashes. Anywhere. Ever.
- Purple-pink astrology clichés; star fields on health screens (removed from Cycle).
- Near-black minimalism, painted "AI slop" gradient blobs, bright overpowering auras, literal
  silk fabric plates (all rejected en route to liquid light).
- The 3D shaded orb / concentric hairlines / orbiting dot on the cycle ring (astrology-instrument
  silhouette; replaced by the flat Oura ring).
- Grain overlays (removed app-wide) and glyph watermarks on non-astrology sheets.
- Thin outlined capsule chips (the "cheap and dated" 2015 look) → LuxChip only.
- Monospaced type for labels/buttons/eyebrows (the "Minecraft" tell) → numbers only.
- Identical boxed cards in a feed (the mixed-containment transit layout) → hero by scale + rows.
- Timers/clocks/second-ticks on any calm surface (the meditation stopwatch).
- The giant 84pt cycle-day numeral on Home (too much; demoted to a compact row, big day lives
  on Cycle).
- "THE MOON IS UP." greeting (read weird at 7pm).
- Five data series in one Trends chart; raw step-y vibe lines (smooth for display, raw for stats).
- Platform-specific social share buttons (Instagram/TikTok logos) → one system share glyph.

**Product/ethics:**
- Fake biometrics or invented composite "readiness" scores (research: unvalidated; Whoop vs Oura
  correlate NEGATIVELY on the same body). Raw signals only, receipts always stated.
- Porting the Kimi build's copy or its fake Body Systems scores.
- Cycle-syncing performance claims (debunked 2025); we frame phase guidance as typical patterns.
- Friend RANKINGS: never existed, never will, and we don't even advertise its absence anymore.
- Recommending specific businesses in Maps handoffs (partnerships later, labelled, Maria's call).
- Auto-scheduling IVF reminders (her clinic's calendar, not ours).
- Care/vault content in notification text; EC guidance as a push notification (in-app only).
- Contraception claims of any kind; the calendar must never be pitched for pregnancy avoidance.
- Cutting corners on Node/Lilith math or copying Swiss Ephemeris code (AGPL).
- Sienna as the voice (my recommendation; Maria chose Roxie — her app, decided).
- Mean-girl tone even as a joke; Co-Star's cruelty is the documented cautionary tale.
- Speculative "great girl" praise wording (Maria wanted exactly "You needed that." — use her words).

**Process:**
- HTML/mockup prototyping instead of the real app.
- Claiming something works without a simulator build + screenshot.
- Cherry-picked research; telling Maria what she wants to hear.
- Entering credentials/tokens on her behalf.
- Command-line `git push` retries on this Mac (dead end; use Xcode's Integrate menu).

---

## 10. Research memory (both rounds, sourced in the July 4-5 session logs)

Round 1 (Explore): Flo = expert content library + anonymous Secret Chats; Stardust = daily
phase content (mind/body/movement/sex/work/beauty) + searchable Cyclepedia; Clue = 300+ expert
guides. Winning indie-feasible surfaces: phase-specific lifestyle guidance, symptom decoder,
lore/meaning. (All three shipped in EXPLORE.)

Round 2 (brutal, agent-run, all sourced): only 41.5% of women know their fertile window (the
plain-language lane is wide open and is OUR lane); wrong predictions are the #1 tracker
abandonment driver and calendar math fails irregular cyclers hardest (never oversell
predictions); privacy is a deletion trigger post-Flo-verdict (on-device is marketable, say it
loudly); Co-Star's meanness hurt vulnerable users while its bluntness drove virality; The
Pattern's moat is writing quality; 61% of consumers disengage from AI-smelling content (the
voice IS the product; Maria's phrases are the uncopyable watermark); health apps retain ~4% at
day 30; the two evidence-backed retention levers are a home-screen WIDGET and grace-first
streaks (neither built yet); notification rule: she configures it, never a default blast (64%
delete at 5+/week); composite readiness scores are unvalidated but raw sleep/HRV/temp signals
are near-lab-grade (hence the HealthKit plan's raw-signals-with-receipts design).

---

## 11. The roadmap (current order, with blockers)

1. **HealthKit wiring — top build priority.** Read sleep, HRV, resting HR, wrist temp via Apple
   Health (covers Oura/Whoop/Garmin/Watch; the `wantsHealthKit` ask exists in onboarding and YOU).
   Fuse into THE VIBE as the third ingredient (cycle + moon + body), receipts on the card
   ("slept 5h, HRV down = the vibe says gentle"), group-chat language ("your body kept receipts
   from last night," never "HRV 42ms"). Body data NEVER changes cycle-day math, only daily
   guidance. Degrades to estimates-only without a tracker. No entitlement blocker for dev.
2. **Care reminders polish** (engine shipped): opt-in surfacing in YOU, cadence editing.
3. **Home-screen WIDGET** (day + one voice line, nothing sensitive) and **grace-first streaks**
   (never shames; Duolingo streak-freeze precedent).
4. **Apple Developer enrollment — MARIA'S DESK, $99, unblocks everything social.** Enrollment as
   Individual is near-certain; App Store review is the real gate and LILITH's position is strong
   (high-craft vs 4.3 spam rule, on-device data, disclaimers in place). Needed before submission:
   privacy policy URL, accurate privacy labels, account deletion once accounts exist.
5. After enrollment: Sign in with Apple + Supabase exchange (TODO in OnboardingView), TestFlight,
   daily affirmation push (opt-in only), Friends for real (cycle-sync + moon twins + memes/gifs;
   teaser page live; sharing opt-in per friend).
6. **Chatbot (Phase 3):** after HealthKit/widget/TestFlight; ships WITH premium; requires the
   crisis-safety layer; PeopleStore and the FILE ON YOU are its prepared memory. "Is he worth it
   or are you going to spiral, eeeeh" is reserved for it.
7. Astrocartography v2 (saved cities, visual map, current-city awareness) + the astro.com
   relocation verification. Compatibility deep-cuts, Dawn light mode (architected, unbuilt).
8. Housekeeping: swap support mailto placeholder (m.stavridi@me.com) for a real support inbox;
   consider a RELIEF shortcut on Cycle during luteal/menstrual; backend prompt update with the
   remaining Lilithisms.

**Still owed by Maria:** Apple Developer enrollment; listening pass on the Roxie lines in-app
(any single line can be regenerated for 1.5 credits); ongoing Lilithisms (give her SITUATIONS
to react to, not "how do you speak").

---

## 12. The one-paragraph handoff

LILITH is a built, working, beautiful prototype: real astrology, full cycle intelligence, an
on-device health vault, compatibility, meditations with a cast voice, and a shareable daily
reading, all in Maria's voice on liquid-light plates. Everything a girl using it alone needs
exists; what remains is the world-facing layer (Apple enrollment → TestFlight → accounts →
social → chat) plus HealthKit and the widget. Work in the real app, verify on the simulator
with screenshots, log every decision same-day, keep mono for numbers, keep the voice hers,
keep secrets on the phone, never break the Best Friend Test, and when Maria says something
feels wrong, assume she has correctly diagnosed a real root cause and go find it.
