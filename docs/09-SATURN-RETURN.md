# 09 — SATURN RETURN (feature spec)

Status: proposed, net-new. On-device, no backend. Likely Phase 2.x (after the July 1 first draft) unless pulled earlier. Honors the hard rules: real math from SwiftAA, voice everywhere, no medical claims, affirmations must be personal.

## The idea

A section that tells her about *her* Saturn return: what it is, when hers actually happens, what it is asking of her, and what to lean into versus what to let go of. Not a generic "around age 29" blurb. Lilith computes her real return window from her chart and meets her where she is in it.

Saturn takes about 29.5 years to orbit, so around ages 28 to 31 it returns to the exact spot it held at her birth (the first return), and again around 57 to 60 (the second). Astrology reads this as the big maturation reckoning: the structures of her life (career, commitments, identity) get tested and rebuilt. It is one of the most culturally famous transits, which makes it a perfect best-friend moment: personal, time-bound, and lore she will want to screenshot.

This is the north star in one feature. A best friend remembers, shows up at the right moment, and knows the lore. A Saturn return section that says "yours runs from this date to that date, and babe, you are in it right now" is exactly that.

## The moment, computed for real

Everything below uses the existing engine. No new astronomy, just a new question asked of it.

**Inputs already available**
- Natal Saturn longitude: from the chart's Saturn placement. Add a `saturn` accessor to `NatalChart` (mirroring `sun`, `moon`, `lilith`).
- Transiting Saturn longitude at any date: `ChartEngine.longitude(of: .saturn, at: date)` already exists and already matches astro.com. It is currently `private`; expose it (or add a thin `transitLongitude(of:at:)` wrapper) so the return engine can call it.

**Finding the return window**
The return is the moment transiting Saturn conjoins natal Saturn, i.e. when the signed shortest separation crosses zero:

```
delta(t) = ((saturnNow(t) - natalSaturn + 180) mod 360) - 180   // in (-180, 180]
```

Scan the relevant age band (first return: birth + 27y to + 32y; second: birth + 56y to + 61y) in coarse steps (weekly is plenty), find each sign change of `delta`, then refine each crossing to the day with bisection. Because Saturn retrogrades, it can cross the natal point up to three times in one season, so collect *all* hits in the band.

- Window = [first hit, last hit]. One hit when no retrograde overlaps (a single day); a triple hit spans roughly 9 to 14 months.
- Expose the exact hit dates too; the "peak" days are meaningful to show.

**Where she is in it (phase), relative to today**
- `upcoming` (hasn't reached this return yet: anyone under about 28 for the first, or anyone between returns for the second): the "when to expect it" state. Show the year and the age it arrives, as a friendly countdown ("your first Saturn return lands in 2031, the year you turn 29"). Every under-28 user sees this, so the section is never empty for them.
- `approaching`: two nudges. A year out, quiet ("it's on the horizon"). A month out, louder ("this is about to begin"). Optionally also when transiting Saturn comes within a few degrees.
- `active`: today is inside [first hit, last hit] (optionally widen with a small experiential orb of about 3 to 5 degrees so it feels like the season, not a single day).
- `completed`: today is past the window. The "here is what you built" framing.
- `between`: first return done, second not yet near. Honor the first, and give the when-to-expect countdown for the second.

**Birth time is not required for the timing.** Saturn moves slowly, so its longitude (and therefore the return dates) is reliable even when birth time is unknown and we fall back to noon. Birth time only affects the *house* layer of the reading. So: the sign reading and the timing always work; the house reading appears only when she gave us a time. Good graceful-degradation story, and it keeps the "no idea (rising stays a mystery)" onboarding path fully supported.

## The reading (personalization + content)

Driven by three things: natal Saturn **sign** (always), natal Saturn **house** (only if birth time known), and current **phase**.

Mirror the existing `ChartReadings.json` pattern with a new on-device file, `SaturnReturnReadings.json`, loaded the same way `ReadingStore` loads chart readings:

```jsonc
{
  "explainer": "What a Saturn return even is, in plain language for a beginner.",
  "signs": {
    "aries": "What Saturn in Aries comes back to rebuild: what to lean into, what to avoid.",
    "taurus": "…",
    // …12 total
  },
  "houses": {            // optional layer, shown only when birth time is known
    "1": "The area of life (self/identity) being restructured.",
    // …12 total
  },
  "phases": {
    "approaching": "Framing for the run-up.",
    "active": "Framing for being in the thick of it.",
    "completed": "Framing for the morning after."
  }
}
```

The reading composes: phase framing, then the sign reading (the heart of the do/avoid), then the house layer if available. Each sign and house entry must pass the personal-affirmation rule: if a line would comfort literally anyone, it fails review. Saturn in Capricorn rebuilding her relationship to ambition reads differently from Saturn in Pisces rebuilding her boundaries, and the copy has to earn that difference.

**Voice (docs/03, docs/07).** The whole section runs on "this is the rebuild, not the breakdown." Saturn is the strict mentor who actually believes in her, never the punisher. The "what to avoid" is gentle BFF guidance ("don't sign the thing you already know is wrong just because you're tired"), never a warning label, never doom, never clinical. No em dashes anywhere.

## Where it lives

Two surfaces, in priority order.

1. **A Saturn Return reading sheet.** Reachable from the Chart tab: tapping Saturn opens its existing reading sheet, and that sheet gains a "Your Saturn return" block (timeline + the composed reading). Styled in the house language (cosmicScreen, displayCaps, dark glass), with Saturn given a little gravity the way Lilith's own sheet is special.
2. **A Today-screen surfacing when she is `active`.** A dedicated Today card ("You are in your Saturn return") that links into the sheet. This is the "shows up at the right moment" payoff and should not appear when she is not in the window. An `approaching` heads-up (a quieter line) is a nice v2 touch.

Longer term this is the first of a family of timed transits, so the engine and sheet could generalize into a small "Moments" concept. Note it; do not build for it yet.

## Code shape

- `NatalChart.saturn: Placement?` accessor.
- Expose `ChartEngine.longitude(of:at:)` or add `transitLongitude(of:at:)`.
- `SaturnReturn` model: `ordinal` (1 or 2), `windowStart`, `windowEnd`, `exactHits: [Date]`, `natalSaturn: Placement`, and a `phase` enum (`tooYoung`, `approaching(daysUntil:)`, `active`, `completed`, `between`).
- `SaturnReturnEngine.saturnReturn(for: NatalChart, on: Date = .now) -> SaturnReturn?` (or an extension on ChartEngine), implementing the scan + bisection above.
- `SaturnReturnReadings.json` + a loader alongside `ReadingStore`. Add the JSON to the target.
- `SaturnReturnView` / sheet content, plus the Today card variant.

## Build order

- **v1 (lean):** both first and second return. Compute the window + phase, show the explainer, the sign reading, her dates, and the right phase framing, including the when-to-expect countdown for users who haven't reached their return. Sign-only, opened from the Chart tab's Saturn sheet. The year-out and month-out "approaching" lines render in-app here. No Today card yet.
- **v2:** add the house layer (when birth time known), the Today `active` card, and push notifications for the year-out and month-out nudges (needs the paid Apple Developer push entitlement, currently pending).
- **v3 (later):** generalize into "Moments" for other big transits.

## Verification (hard rule)

Before declaring the timing done, verify computed return windows against astro.com for at least 5 birthdays, including:
- a clean single-hit return,
- a retrograde triple-hit return (verify all three exact dates within a day or two),
- a second-return case,
- a southern-hemisphere birth,
- an unknown-birth-time case (confirm the dates are unchanged and only the house layer drops out).

## Decisions (locked June 18 2026)

1. Cover BOTH returns. The first lands about ages 28 to 31, the second about ages 57 to 60 (a rare third comes near 87 to 90). For anyone who hasn't reached a return yet, every under-28 user and anyone sitting between returns, tell them when to expect it: the year and the age it arrives. Nobody opens this section and finds nothing for them.
2. v1 ships the sign reading (plus explainer, dates, phase framing, and the when-to-expect countdown). The house layer comes in v2, shown only when birth time is known.
3. Lives inside the Chart tab: tapping Saturn opens its reading sheet, which carries the Saturn return block. Today-card surfacing when active stays a v2 addition.
4. "Approaching" speaks twice: a year out (quiet) and a month out (louder). In-app in v1; as push notifications in v2.
