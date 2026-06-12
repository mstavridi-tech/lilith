# LILITH — Architecture

## Big picture

```
┌─────────────────────────────┐         ┌──────────────────────────┐
│   iPhone app (SwiftUI)      │         │  Backend (small, later)  │
│                             │  HTTPS  │                          │
│  • Onboarding + birth data  │ ──────► │  • Claude API: writes    │
│  • Chart engine (on-device) │         │    daily/monthly         │
│  • Today view, Chart view   │ ◄────── │    horoscopes from       │
│  • Local storage (SwiftData)│         │    transit data          │
│  • Apple Health (Phase 2)   │         │  • Push notifications    │
└─────────────────────────────┘         └──────────────────────────┘
```

Key decision: **the astrology math runs on the phone, the words come from the cloud.** Chart calculations are deterministic math, free to run, and work offline. The AI-written horoscopes need an API key that must never live in the app, so a tiny backend does that.

## The astrology engine (on-device)

What we need to compute:
- Planet positions (Sun through Pluto, plus Chiron, North Node, Black Moon Lilith) for any date/time
- Ascendant (rising) and house cusps for a birth time + location (Placidus or Whole Sign houses — offer Whole Sign as default, it's simpler and trendy)
- Aspects between planets (conjunction, sextile, square, trine, opposition, with orbs)
- Current transits vs natal placements
- Moon phase for any date
- Retrograde detection (a planet is retrograde when its ecliptic longitude is decreasing)

### Library choice
Two options, in order of preference:

1. **SwiftAA** (github.com/onekiloparsec/SwiftAA) — Swift wrapper of the respected AA+ astronomical algorithms. MIT licensed, free for commercial use. Gives planetary ecliptic longitudes, which is exactly what astrology needs. We compute signs, houses, and aspects ourselves (that part is simple math, see ChartEngine.swift).
2. **Swiss Ephemeris** (the astrology industry standard) — more precise for asteroids/Lilith, BUT it's AGPL-licensed: using it in a closed-source commercial app requires buying a professional license from Astrodienst. Flag for later if we need its precision; verify current license terms and pricing at astro.com before committing.

Start with SwiftAA. Accuracy difference is irrelevant at horoscope level (arc-minutes).

Note: Black Moon Lilith (mean lunar apogee) can be computed from lunar orbital elements; the starter ChartEngine has a documented stub for it. Verify the formula against a known chart (e.g. astro.com's free chart) during testing.

### Verification rule
Before shipping, every computed chart MUST be checked against astro.com's free natal chart for at least 5 test birthdays, including a southern-hemisphere city and a birth near midnight at a timezone boundary. Timezones and historical DST are where every astrology app has bugs. Use the IANA timezone database via Swift's TimeZone, and store birth moment as date + time + place, resolving to UTC at calculation time.

## Accounts (Phase 1, kept frictionless)

- **Sign in with Apple only at launch.** One tap, FaceID, gives verified name + email. No passwords to build, store, or reset. (App Review note: offering ONLY Sign in with Apple is allowed; adding Google/email later just requires keeping Apple as an option)
- **Backend: Supabase** (free tier) — auth, user table, and later the Phase 4 social features, so the choice does double duty. The app exchanges the Apple identity token for a Supabase session
- **What the account stores server-side:** user id, name, email, subscription status, and (for cross-device restore) birth data. That's it
- **What NEVER goes server-side:** cycle data, chat memory, mood logs, location history. Identity and diary are separated by design
- Important practical detail: the Sign in with Apple entitlement requires a paid Apple Developer account ($99/yr), so enrollment moves to the top of the to-do list

## Data model (SwiftData, on-device)

- `UserProfile`: name, birthDate, birthTime (optional but pushed hard in onboarding), birthPlace (lat, lon, timezone ID)
- `NatalChart`: cached computed chart (recompute is cheap, but cache anyway)
- `CycleEntry` (Phase 2): date, flow, symptoms, mood
- `Person` (Phase 3): saved people for compatibility
- All sensitive data stays on-device. iCloud sync optional and off by default for cycle data.

## The horoscope backend (Phase 1, kept tiny)

A single serverless function (Vercel, free tier to start) that:
1. Receives: natal placements summary + today's transits (computed on phone, sent as JSON — no name or identity needed, which is great for privacy)
2. Calls Claude API with the LILITH voice prompt (see docs/03-BRAND-VOICE-DESIGN.md)
3. Returns the horoscope text
4. Caches per (sun+moon+rising × date) bucket to control cost

Cost estimate: with caching, well under $0.01 per daily horoscope. Fully personal (per exact chart) horoscopes can be a LILITH+ perk to manage spend.

App ships with a fallback: if offline or backend is down, show a transit-based templated reading so the app never feels dead.

## Project structure

```
Lilith/
  LilithApp.swift          — app entry
  Theme.swift              — colors, fonts, spacing (the vibe, centralized)
  Models.swift             — ZodiacSign, Planet, Placement, NatalChart, BirthData
  ChartEngine.swift        — all astrology math
  HoroscopeService.swift   — backend client + offline fallback
  Views/
    OnboardingView.swift   — birth data collection
    TodayView.swift        — daily horoscope + moon + affirmation (home screen)
    ChartView.swift        — natal chart breakdown
```

## Phase 2 notes (so we don't paint ourselves into a corner)
- HealthKit: read `HKCategoryTypeIdentifier.menstrualFlow`, sleep analysis, resting heart rate. Requires entitlement + privacy strings. Data never leaves device
- Cycle phase model: simple rule-based on cycle day first (menstrual / follicular / ovulatory / luteal), refine later
- The merged insight runs on-device: rules pick the top "explanation" (moon event vs retrograde vs cycle phase), then the daily horoscope request includes it as context
- Tarot: 78-card deck as local data (card, upright/reversed meanings, house-style artwork). The pull is local and instant; the interpretation calls the backend with card + her chart + her day for an in-voice reading

## Phase 3 notes — LILITH chat (the big one)
- Same pattern as horoscopes: the app sends context, the backend holds the key and the persona prompt, Claude API does the talking. Streaming responses for that real-conversation feel
- **Context bundle per message:** her placements, cycle day/phase, today's transits, recent mood logs, and a rolling on-device memory summary (recurring people, ongoing situations, preferences). The bundle is assembled on the phone and sent per-request; the server stores nothing
- **Memory:** after each chat, the app asks the model for a short updated memory summary and stores it on-device only. She can view and edit "What LILITH knows about me" in settings — transparency as a feature
- **Safety layer in the backend prompt:** crisis detection → soften persona, point to real resources; no medical/contraception advice; reality-check rule enforced in the system prompt. Log nothing identifiable
- **Cost control:** this is the expensive feature, and the tier ladder is the business model: free = taste, LILITH+ = daily allowance (~25 messages, tune from data), LILITH BFF = unlimited. Enforce allowances server-side, not in the app. Use a fast cheap model for casual chat, escalate to a stronger model for chart readings. Track cost per user per day from day one; alert if any user exceeds budget

## Phase 4 notes
- Friends + messaging needs accounts and a real backend (Supabase recommended: auth, Postgres, realtime messaging out of the box, generous free tier). Do not build accounts before this phase — anonymous-first is faster and more private
- **Astrocartography:** planetary lines (where each planet would be angular: on the ASC/DSC/MC/IC) are computed on-device from her natal chart — pure math, no API. Map rendering with MapKit
- **Location-aware readings, staged carefully:**
  1. Ship v1 with When-In-Use location only: she opens the app somewhere new, it notices and reads the place (relocated chart + nearby lines). No background anything
  2. Background mode later, only if v1 proves demand: `CLLocationManager` significant-change monitoring (cell-tower granularity, battery-cheap), triggering a local notification ("You just landed in your Venus line"). Requires Always permission, an honest purpose string, and App Review will scrutinize it — have the justification ready
  3. Location never leaves the device except as a city-level coordinate in the horoscope request, never stored server-side, never alongside cycle data
