# LILITH — The Lure Pass

Maria's verdict on the first working build: "it looks basic, I want more lure, it looks like an amateur built it." Correct diagnosis. The function is real and the layout follows the design law, but four layers of craft are missing. This file is the punch list, in priority order. The rule from docs/03 governs everything here: motion is slow and weighty, nothing bounces, the moon behaves like an eclipse and never like a loading spinner. And no em dashes in any copy.

## 1. The real typeface (highest impact, do first)

The system serif is the single biggest "amateur" tell. Bundle Cormorant Garamond (free, SIL license):
- Maria downloads the family from fonts.google.com/specimen/Cormorant+Garamond and drags `CormorantGaramond-Medium.ttf`, `-Regular.ttf`, and `-MediumItalic.ttf` into Xcode (copy, add to target)
- Add the fonts to Info.plist (UIAppFonts), switch `Theme.display`, `Theme.body` to Cormorant with New York as fallback
- Re-check every screen after the swap: Cormorant runs smaller than New York at equal point size, so bump display sizes until the optical size matches the v9 mockup

## 2. Motion (the difference between a screen and a window)

- **The card arrival.** The daily reading does not pop in. It develops: moon settles first, then the eyebrow, headline, reading, and mantra cascade up with soft fades, roughly 120ms apart, 600ms each, heavy ease-out. Once per fresh load, never on tab return
- **The moon breathes.** The ember bloom behind the moon slowly swells and dims on an 8 second loop, opacity moving maybe 10 percent. Subliminal, not noticeable unless you stare
- **Parallax.** As she scrolls, the moon and star field drift a few points slower than the content. Depth without gimmick
- **Stars live.** Three or four hero stars very slowly shift opacity, on independent 6 to 12 second cycles. The sky should feel faintly alive, never twinkly
- **Pull to refresh.** Custom: while loading, the moon's terminator shadow sweeps once across the moon (the eclipse, our signature gesture). No spinner, ever
- **Scope and tab changes** crossfade (250ms). Nothing slides, nothing bounces
- **Chart wheel entrance.** First open per session: the gold hairlines draw themselves in over about 1 second, ring first, then spokes, then glyphs fade on. The wheel should feel like an instrument assembling

## 3. Haptics (she touches back)

- Soft impact when the daily card finishes arriving
- Light tick on scope switch and on placement tap
- Subtle success tap when a reading sheet opens
- Nothing on scroll, nothing repeated, restraint is the brand

## 4. Ritual and dressing

- **Launch screen:** pure void with grain, the wordmark fading in letterspaced, then the app. Two seconds of theater
- **App icon:** the phase-lit moon photo on void, no text, no ring. It should look like a porthole on her home screen (needs a 1024px export; Claude Code generates the asset catalog sizes)
- **Reading sheets** rise as dark glass (dark ultraThinMaterial over void) with a single gold hairline along the top edge and the body's glyph watermarked huge and faint behind the text
- **Edge vignette:** a barely-there darkening at screen edges on every screen, pulls the eye inward, makes the black feel deep instead of flat
- **All loading and empty states** rewritten in voice (docs/03), no system defaults anywhere

## Acceptance test

Build, then hand the phone to someone for 60 seconds with no explanation. If they don't touch the moon, switch a tab just to feel it, or screenshot something, the pass isn't done. The bar: it should feel like a window with weather behind it, not a screen with content on it.
