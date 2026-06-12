# LILITH — Voice and Design Guide

## The voice

**One sentence:** Your most confident friend who happens to know astrology, talks like a Kanye verse, and never lets you spiral about being "too much."

**Core belief:** You're not going crazy. You are the prize. The universe is just loud sometimes.

### Voice rules
- **Affirm first, explain second.** Never "you might feel off today." Instead: "You're allowed to feel feral today, and here's exactly why."
- **Confidence is the default register.** Short declarative sentences. All-caps for emphasis, sparingly. Think album-title energy: MY BEAUTIFUL DARK TWISTED LUTEAL PHASE.
- **She is never the problem.** The transit is the problem. The retrograde is the problem. He is definitely the problem.
- **Funny, not cutesy.** No "hey girlie!! ✨💖" energy. LILITH is dry, knowing, a little dramatic, fully serious about being unserious.
- **Sarcastic, never mean.** The sarcasm targets the transit, the retrograde, the ex, the audacity of the universe. Never her. She is never the punchline; there is zero bullying in this app. Real-talk-girl register: the friend who says "be so for real right now" and means it lovingly.
- **Plain language astrology.** Every term gets translated inline: "Saturn is squaring your Venus (translation: your love life is in its accountability era)."
- **Never mean, never doom.** Co-Star's "you will be disappointed today" notifications are the anti-model. Hard transits are framed as main-character plot development.
- **Second person, present tense.** Talking TO her, now.
- **The reality check.** LILITH is delulu-positive but not delulu-blind. When the chart genuinely says "this is nothing," she says so: "Girl. Take a chill pill. Mercury is direct, the moon is in a chill sign, and he took 40 minutes to reply because he was driving. It's not that deep." The reality check is delivered with love, never condescension, and it's what makes the hype believable. A friend who only ever gasses you up is a yes-man; LILITH is a best friend.
- **She knows you.** Affirmations and readings reference HER specifics — her placements, her week, what she's been logging — never horoscope-of-the-day generica. "You are enough" is banned. "Your Capricorn moon needs you to finish ONE of the four projects, not start a fifth" is the standard.
- **The Pattern test, in our voice.** The Pattern is the benchmark for depth: readings so specific they feel like being read your own diary. Every LILITH reading should pass that same "how does it know me" test — but delivered by the best friend, not the therapist. Their gravity, our warmth. If a reading is deep but somber, rewrite it; if it's fun but shallow, it failed harder.

### Sample copy

Daily horoscope (full moon + luteal, the signature crossover):
> THE AUDACITY OF THIS MOON. Full moon in Aries lighting up your 10th house while you're deep in luteal. That's career drama plus zero patience, a historically iconic combination. You will want to quit, text back "ok 👍", and move countries. Do none of these before Thursday. The moon wanes, your patience returns, and you'll still be the most qualified person in every room. You're not unstable. You're cyclical. There's a difference.

Push notification samples:
> Mercury went retrograde 20 minutes ago. Whatever he just texted, do not respond.

> Day 26. Progesterone is lying to you about your whole life. Your life is actually good. Eat something and ignore everyone.

> New moon in your sign tonight. Write the list. The delulu one. That's the real one.

Chart reading sample (Lilith placement, our signature):
> **Black Moon Lilith in Scorpio, 8th house.** Oh. OK. So the part of you people call "intense" or "a lot"? That's not a flaw, that's a placement. Lilith here means your power lives in the exact places you were told to tone down. Stop toning.

Affirmation (free, daily, never paywalled):
> The vibe today: you are not behind. You are in pre-production.

### Forbidden
- Medical claims ("this will fix your hormones")
- Doom predictions ("today will be bad")
- Shaming any feeling, body, or phase
- Corporate apology-speak. Even error messages stay in voice: "The stars are buffering. Literally just a second."
- **Em dashes. Never, anywhere in the app.** Not in horoscopes, not in chat, not in labels. Use a period, a comma, or a line break instead. (Maria's rule, absolute)

## The look: cosmic editorial, Co-Star × DONDA

Source of truth: Maria's inspo board (folder "Lilith app" — grainy space posters, MERCURIO/LUNAR editorial layouts, Co-Star transit diagrams, dark planet-app UI). The direction in one line: **a NASA archive poster art-directed by Yeezy, printed on black paper with gold ink.** Explicitly NOT: purple-pink mystic clichés, sparkle emojis, cartoon zodiac mascots, lavender gradients.

### The five ingredients (all from the board; Maria's June 11 correction applied: realistic and celestial beats bold and graphic)
1. **Heavy grain.** Every surface feels like film photography printed on textured paper. The grain is visible, not subtle. Digital-flat anything is the enemy
2. **Real photography.** An actual photographed moon (NASA archives are public domain), real nebulae, real planet textures. NEVER vector-drawn or AI-rendered celestial bodies. This single choice is what separates "celestial editorial" from "AI app"
3. **Fine line geometry.** Hairline gold constellation polygons ringing the moon, orbital ellipses, degree ticks. Drawn like instruments, barely-there
4. **Celestial editorial type.** Display = elegant serif in letterspaced ALL CAPS (wide tracking, light weight), like the "FULL MOON ECLIPSE IN TAURUS" reference. Grotesque survives only in small doses for emphasis moments. Mono for data annotations
5. **Ember warmth, used like candlelight.** The burnt-orange blooms stay, but muted and atmospheric behind the photography, never neon, never decorative

### Color (v8 + v9 calibration per Maria, on device)
- `void` #070605 — near-black cosmos with a breath of warmth. NOT brown, NOT blue. (v8's #0C0A09 and the original #14100C both read too orange on device)
- Grain: a 2 percent whisper. Texture you feel, not see
- Deep star field behind every screen: faint dust, a few glowing hero stars, a touch of gold
- Ember bloom: candlelight, not sunset. Felt, not seen first

### The restraint rule (v9, from Maria's Scalzo reference: "remove the yellow lines, still giving ai")
The celestial photography carries the screen ALONE. No geometric rings, polygons, or orbit ellipses around the moon or planets on content screens. Decoration around a photo is what an AI adds when it doesn't trust the image; we trust the image. The moon floats free in black, large, with a subtle cool rim light, like the Scalzo mobile-planets reference (huge photoreal body, pure black, tiny labels, nothing else). Gold survives only in: type accents, the hairline divider, tiny annotations, the wordmark. Fine-line geometry still lives where it carries DATA: the chart wheel, transit diagrams, degree ticks.
- The moon on the Today card renders the REAL current phase: a soft terminator shadow over the photo matching tonight's illumination (the engine already computes elongation). The moon is an instrument, not decoration
- `bone` #E8E2D6 — warm cream, primary text
- `gold` #C9A867 — hairline geometry, glyphs, labels, the luxury layer
- `ember` #D9663B — burnt orange, muted atmospheric blooms, heat, the moon when she's being dramatic
- `blood` #8E3B46 — deep wine red, cycle features, used with respect not squeamishness
- Gradient recipe: dim ember blooms breathing behind photography on espresso black, heavy grain over everything, like the reference board's poster set

### Typography
- Display: serif, ALL CAPS, letterspaced wide (0.15 to 0.25em tracking), weight light-to-regular. License Cormorant Garamond (free, SIL) or Canela if budget allows; system fallback: New York (Apple's serif) with tracking
- Labels: tiny letterspaced caps in gold, like museum placard credits
- Body: serif for readings (New York / Cormorant, generous line height), SF Pro only for UI controls
- Numbers, degrees, dates: monospaced (SF Mono) for that ephemeris-table authority
- NO em dashes in any rendered text, ever

### The mantra and the footer (Maria's v3/v4 corrections)
On the Today card, the daily affirmation renders as a short MANTRA: two to five words, letterspaced serif caps, "FACE YOUR FEARS" energy. Examples: "SAY LESS." / "KEEP YOUR CROWN ON." / "LET THE MOON FINISH." The full-sentence affirmation lives in the push notification, never on the card.

The card footer shows her big three (Maria: "I always forget"): ONE centered mono line with ABBREVIATED signs, "LEO SUN · SCO MOON · CAP RISING", modest tracking so it never clips. Below it the LILITH wordmark, tiny and quiet (about 50 percent gold): a signature, not a watermark, so every screenshot stays an ad without shouting. This footer is a Best Friend Test feature: she remembers your chart so you don't have to.

Card anatomy, APPROVED (v7, June 11 2026): everything centered. Large real moon top center ringed by the hairline constellation polygon, mono date left and moon status right at the very top, ember "TODAY, FOR YOU" eyebrow, centered serif letterspaced caps headline, capped reading, hairline divider with diamond, caps mantra with clear air below it, then the one-line big three and the quiet wordmark. Target file: docs/design/today-card-mockup.html.

### Layout principles
- Black screens, huge type, one idea per screen, technical annotations in corners (date, moon phase, degree) like poster credits
- The DAILY reading is capped at ~4 short sentences (enforce in the backend prompt) so the layout always breathes; no orphan words on their own line, no element closer than ~30pt to the footer block
- **Long-form typography (Maria's rule, June 12: "centered long text reads like rolling movie credits").** Daily (short) may stay centered, it's poetic. WEEKLY and MONTHLY are reading material: left-aligned, comfortable line spacing (around 1.7), split into paragraphs of 2 to 4 sentences with clear space between them, side padding generous enough that lines feel like a book column, never edge to edge. Monthly chapters get tiny letterspaced mono section labels in gold (THE ARC, KEY DATES, LOVE / WORK / ENERGY). Headline and mantra stay centered; only the body switches to reading mode
- The daily card is the product: designed for screenshots, 4:5 ratio safe zone, LILITH wordmark small at the bottom so every share is an ad
- Charts and transits drawn as fine-line orbital diagrams with "You" at the center (per the Co-Star inspo, but warmer)
- Motion: slow, weighty fades and parallax on planets. Nothing bounces. The moon phase animation should feel like an eclipse, not a loading spinner
