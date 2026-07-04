# LILITH — Instructions for Claude Code

You are building LILITH, an iOS astrology app that is every girl's pocket best friend. Real astrology math, real cycle awareness, an AI BFF, and a voice that affirms instead of doom-posting (but also says "girl, it's not that deep" when it's not that deep).

## Read these before any work
- `docs/01-PRODUCT-BRIEF.md` — what we're building and in what order
- `docs/02-ARCHITECTURE.md` — how it's built; do not deviate without flagging it
- `docs/03-BRAND-VOICE-DESIGN.md` — every word and pixel follows this
- `docs/07-LILITHISMS.md` — Maria's quirks are the app's personality; greetings and phrases come from here
- `docs/05-PREMORTEM.md` — the known ways this fails; don't walk into them
- `docs/inspo/` — Maria's visual reference board; look at it before any UI work

## Hard rules
1. **Phase discipline.** Phase 1's free scope is complete and Maria has opened Phase 2 (June 11, 2026): cycle tracking per docs/01 and docs/02 may now be built. Compatibility, chat, and social features remain locked behind their phases — confirm first.
2. **Voice everywhere.** All user-facing copy (including error messages and empty states) follows the voice guide. Never corporate, never doom, never mean. NEVER use em dashes in any user-facing text, and don't use them when talking to Maria either.
3. **Theme.swift only.** No hardcoded colors or fonts in views.
4. **No API keys in the app.** AI horoscopes go through the backend only.
5. **Astrology must be real.** Positions come from SwiftAA. Verify any computed chart against astro.com before declaring chart features done (5 test birthdays minimum, see ARCHITECTURE.md verification rule).
6. **Privacy is a feature.** Birth and cycle data stay on-device. The horoscope API receives placements only, never identity.
7. **No medical claims.** Cycle features are wellness content, not contraception or diagnosis. Keep the in-app disclaimer. This extends to the Phase 2 hormone literacy layer (education about typical phase patterns, never claims about her actual levels, always the "talk to a real doctor if extreme" bridge) and the Phase 2.5 care reminders (guideline-based nudges to book screenings with her provider, source stated, country-adjustable). See docs/01 Trust and safety.
8. **Affirmations are personal.** Generated from her chart, transits, and (later) cycle. If a generated affirmation would work for anyone, it fails review.
9. **Chat safety (Phase 3).** The BFF persona always includes the crisis-handling and reality-check rules from the architecture doc. Never ship a persona prompt without them.
10. **Location is staged (Phase 4).** When-In-Use first, background only after demand is proven, never stored server-side, never combined with cycle data off-device.
11. **The Best Friend Test trumps everything.** Every feature, screen, and sentence must pass "would her best friend do this?" (see the north star in the product brief): remembers, shows up at the right moment, knows the lore, keeps secrets, hypes and reality-checks, never judges. If something feels like an app instead of a friend — feels like being tracked instead of being known — redo it, even if it's technically done.

## Current state
- **All app code lives inside the Xcode project: `Lilith- Correct/Lilith/`** (the outer folder was renamed from `Lilith` in Finder on June 18, 2026; the rename is committed). Edit ONLY those files. The folder `_archive-starter-DO-NOT-EDIT/` is the dead pre-Xcode scaffold; never edit it, Maria can delete it from Finder whenever. The stale iCloud duplicate at `~/Documents/lilith-OLD-DO-NOT-OPEN/` was deleted on July 2, 2026
- The Xcode project was created with Storage: None, no testing system. SwiftAA is added
- **ChartEngine is implemented and VERIFIED (June 10, 2026):** all planets, ascendants, True Node, and Black Moon Lilith match Swiss Ephemeris within ~1 arc-minute across 5 test charts (incl. southern hemisphere and DST edge cases). Node = osculating node from lunar angular momentum; Lilith = mean apogee projected through the 5.145° orbital inclination. Do not "simplify" these. The ~1' residual vs SE is their proprietary corrections, deliberately not ported (AGPL); if bit-exact SE agreement is ever needed, buy the Astrodienst license, never copy the code
- Onboarding includes account creation: Sign in with Apple only (one tap), exchanged for a Supabase session. Identity server-side; cycle/chat data on-device. See docs/02 "Accounts"
- Paid Apple Developer enrollment is still pending. Until then: no Sign in with Apple entitlement, no push, no TestFlight. The DEBUG skip button in OnboardingView is the intended path — don't remove it, and don't block other work on the account wiring (next-task 1 below)
- **Verified done, as of a real build to the simulator on July 2, 2026** (this list was stale for a while; most of the original roadmap actually shipped without the doc catching up, confirm against the code before trusting either list again):
  - Design glow-up pass: TodayView, CycleView, ChartView, and SettingsView all hit docs/03 standard (grain, ember blooms, gold hairline geometry, letterspaced editorial type, real moon photo, glass cards). The one piece that was still stock iOS chrome, the tab bar (default TabView + SF Symbols), is now `Views/FloatingTabBar.swift`: a floating glass bar with the ☾ ◗ ✶ ✦ glyphs, fixed July 2, 2026
  - Horoscope backend deployed: `HoroscopeService.backendURL` points at the live Vercel function, `mantra` field included
  - Time-aware greeting eyebrow (docs/07 table), chart readings (`ChartReadings.json`, every placement tappable, explainer + sign reading in `ReadingSheet`), the real chart WHEEL on `ChartView`/`ChartWheel.swift`, the DAILY/WEEKLY/MONTHLY scope switcher, the moon detail sheet, and the Settings screen
  - THE LURE PASS (docs/08): Cormorant Garamond bundled and registered, cascade-in + moon-settle motion, restrained haptics, the eclipse-sweep pull-to-refresh, the launch ritual, and a real app icon (the moon photo, not the default gray square)
  - Phase 2 cycle logging: manual entry, on-device phase computation, the Cycle tab, `cyclePhase` wired into the horoscope request
- **Design direction (settled with Maria, July 4, 2026):** "more health, less astrology" in the LAYOUT, full LILITH sass in the COPY. The Kimi reference build at `Kimi_Agent_Aura Health App Design/` (React/Vite, runs with `npm run dev`, needs `source ~/.nvm/nvm.sh`) is DESIGN INSPO ONLY, we build native SwiftUI. Verdicts on it: keep the sectioned layout and the ring language; its copy is generic wellness-speak (and used em dashes), never port it; its Body Systems scores are fake Oura biometrics we don't have, never fake data. The synergy piece shipped: `Views/VibeCheck.swift`, "THE VIBE" ring on Today, filled from cycle phase + tonight's moon only (never biometrics), receipts stated on the card, all copy in voice
- **The aura pass shipped (July 4, 2026):** generated aura-photography background plates live in Assets.xcassets (`aura-moonlight/menstrual/follicular/ovulatory/luteal/halo`, ~1MB jpg each), rendered via `AuraStage`/`auraScreen` in Theme.swift (breathing image, top scrim for credits legibility, painted-atmosphere fallback if an asset is missing). Today/Cycle/Trends wear the phase plate; halo is reserved for vibe/onboarding moments; a light "pearl" plate is saved in the session scratchpad for a future Dawn (light) mode. Cards/pills are real `.ultraThinMaterial` frosted glass. Rationale in-session: research says dark canvas + luminous aura (Stardust precedent, dark-mode phone preference) but long-form reading should eventually get the light "paper card" treatment, and a full Dawn mode is architected-for but not built
- Next tasks, in order:
  1. Wire accounts: Sign in with Apple capability in Xcode + Supabase project. The button and DEBUG skip path are already wired in OnboardingView; only the `credential.identityToken` → Supabase exchange is left (TODO at OnboardingView.swift:92) — BLOCKED until paid Apple Developer enrollment
  2. Daily push notification with the affirmation — needs paid Apple Developer (push entitlement); nothing built yet
  3. HealthKit import for cycle data, now that manual logging works and is the fallback. Free, can start now
  4. NEW, approved by Maria July 4, 2026, from the Kimi review: Relief (breathing/meditation sessions), Streaks (rituals + activity grid, must be reworked so a broken streak never shames her, "never judges" rule), and Friends (leaderboard energy but NEVER ranking anyone last, "never judges" again). All three need a design-in-voice pass before any code; Friends additionally stays behind Phase 3 social
  5. Compatibility, chat, and remaining social features stay locked behind their phases per the phase-discipline rule — confirm with Maria before starting any of it
- Known warnings, harmless, low priority: CLGeocoder/geocodeAddressString deprecated in iOS 26 — migrate OnboardingView geocoding to the MapKit replacement during some future cleanup, not urgent

## Maria's working style
- **Address Maria by name in every reply.** Not occasionally — every reply
- Explain decisions briefly and in plain language. She's comfortable driving Claude Code but is not a career programmer
- When something breaks, say what broke and fix it, no jargon spirals
- The vision is hers: pocket BFF, woowoo but real, slick lux cosmic not cliché purple. When a technical choice would water that down, say so instead of silently complying
