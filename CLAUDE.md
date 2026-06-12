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
- **All app code lives inside the Xcode project: `Lilith/Lilith/`.** Edit ONLY those files. The folder `_archive-starter-DO-NOT-EDIT/` is the dead pre-Xcode scaffold; never edit it, Maria can delete it from Finder whenever
- The Xcode project was created with Storage: None, no testing system. SwiftAA is added
- **ChartEngine is implemented and VERIFIED (June 10, 2026):** all planets, ascendants, True Node, and Black Moon Lilith match Swiss Ephemeris within ~1 arc-minute across 5 test charts (incl. southern hemisphere and DST edge cases). Node = osculating node from lunar angular momentum; Lilith = mean apogee projected through the 5.145° orbital inclination. Do not "simplify" these. The ~1' residual vs SE is their proprietary corrections, deliberately not ported (AGPL); if bit-exact SE agreement is ever needed, buy the Astrodienst license, never copy the code
- Onboarding includes account creation: Sign in with Apple only (one tap), exchanged for a Supabase session. Identity server-side; cycle/chat data on-device. See docs/02 "Accounts"
- Paid Apple Developer enrollment is pending (expected within a week or two). Until then: no Sign in with Apple entitlement, no push, no TestFlight. The DEBUG skip button in OnboardingView is the intended path — don't remove it, and don't block other work on the account wiring (next-task 5)
- Next tasks, in order (1-4 of the original list are DONE: project created, SwiftAA added, engine implemented and verified):
  1. Design glow-up pass: bring every screen up to docs/03 and docs/inspo/ standard (grain, ember gradients, gold hairline geometry, editorial type, the screenshot-worthy Today card). Free, can start now
  2. Wire accounts: Sign in with Apple capability in Xcode + Supabase project (auth via Apple identity token), per the TODO in OnboardingView — BLOCKED until paid Apple Developer enrollment
  3. Deploy the horoscope backend (single Vercel function calling Claude API) and point `HoroscopeService.backendURL` at it — needs a small Anthropic API credit purchase. The prompt, IO contract, and QA checklist are specified in docs/06-VOICE-ENGINE.md; follow it exactly and add the `mantra` field to HoroscopeResponse
  4. Daily push notification with the affirmation — needs paid Apple Developer (push entitlement)
  5. Time-aware greeting eyebrow on TodayView per the table in docs/07-LILITHISMS.md (morning slots are Maria's locked signatures: "GOOD MORNING, SUNSHINE." and "RISE AND SHINE."). App-side, free, can be done any time
  6. Chart readings: `Lilith/Lilith/ChartReadings.json` now exists with 121 voice-approved entries: `sun`/`moon`/`rising`/`mercury`/`venus`/`mars`/`jupiter`/`saturn`/`lilith` × 12 signs each, plus `explainers` (13 entries: every body explained in plain language for beginners). Add the file to the Xcode target and make EVERY placement on ChartView tappable. The reading sheet shows: the explainer first ("what even is Mercury"), then her sign reading below it. For uranus/neptune/pluto/northNode show the explainer alone (no sign sets, they're generational). Lilith's sheet gets special styling, she's the namesake. Tone is intentionally warm with light roast, do not punch it up
  7. The actual birth chart WHEEL on ChartView: circular wheel drawn from real data (house cusps, sign ring, planet glyphs at true degrees, aspect lines inside), gold hairlines on void. Per docs/03 restraint rule, the chart wheel is exactly where fine-line geometry belongs, because there it IS the data
  8. Horoscope scope switcher on TodayView: DAILY / WEEKLY / MONTHLY tabs in small caps, all three scopes hit the same backend with the `scope` field (docs/06), with in-voice offline fallbacks until the backend exists
  9. Moon detail sheet (tap the moon: phase, sign, what it means for HER chart) and a Settings screen (edit birth data, the privacy promise in voice, delete everything)
  10. THE LURE PASS per docs/08-LURE-PASS.md: real typeface, motion, haptics, launch ritual, app icon. Maria's verdict on the current build is "basic, amateur"; this pass is the cure. Free, high priority
  11. PHASE 2 OPENS: cycle logging (manual entry first: period dates, flow, mood), on-device phase computation (menstrual/follicular/ovulatory/luteal from cycle day), a Cycle tab in the house style, and wiring `cyclePhase` into the horoscope request per docs/06. Keep the wellness-not-medical disclaimer in voice. HealthKit import comes after manual logging works
- Known warnings, harmless, low priority: CLGeocoder/geocodeAddressString deprecated in iOS 26 — migrate OnboardingView geocoding to the MapKit replacement during some future cleanup, not urgent

## Maria's working style
- **Address Maria by name in every reply.** Not occasionally — every reply
- Explain decisions briefly and in plain language. She's comfortable driving Claude Code but is not a career programmer
- When something breaks, say what broke and fix it, no jargon spirals
- The vision is hers: pocket BFF, woowoo but real, slick lux cosmic not cliché purple. When a technical choice would water that down, say so instead of silently complying
