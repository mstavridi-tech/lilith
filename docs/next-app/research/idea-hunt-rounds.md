# New app idea hunt: round 1 + 2 findings (Oct 19, 2026)

## The big lesson
Stardust copied LILITH because LILITH competed on features in a category a funded player owned. Features get copied in a sprint. What actually holds for solo devs:
1. Your own face and voice as distribution (TikTok/creators). Cal AI, 75 Days: Her Challenge, Floga all won this way.
2. Owning a specific identity, not a broad category ("Her Challenge" vs generic 75 Hard).
3. Personal history that lives in the app (switching cost).
4. Being first and best on a new Apple surface (6 to 18 month lead). Flighty, Widgetsmith.

Economics: Health & Fitness is the best-paying category (39.9% median trial-to-paid, annual plans dominate). Hard paywall converts ~5x freemium. "AI apps" churn ~30% faster: AI as ingredient, never the pitch.

## Ideas tested and verdicts
| Idea | Verdict | Why |
|---|---|---|
| PMDD + ADHD "receipts" tracker | Standalone: weak. Module: GO | 4+ DRSP + doctor-PDF apps exist (Belle is funded, RCT-backed). Scoring = medical device. Realistic indie ceiling ~$20-75k/yr. The unclaimed piece: ADHD meds effect by cycle phase + PME, beautifully designed. |
| GLP-1 companion for women | Standalone: KILL. Module: maybe | 20+ apps, Noom made theirs free, women-specific versions exist, HealthKit meds is read-only, ED and contraception liability. |
| Perimenopause tracker | KILL | Apple iOS 27, Flo premium, Midi ($250M). Stardust repeat. |
| AI best friend companion | KILL for solo | Tolan ($1M+/mo, $30M raised), Character.AI, OpenAI. Safety liability. |
| Couples mental-load app | KILL | 5+ launches in 2026, structural problem. |
| AlarmKit ritual alarms | GO as a feature | Nobody doing voiced lux rituals yet; fits the Roxie voice pack. |
| Friendship keeper (non-networking) | Lovable, low pay | Basically LILITH's People store + voice. |

## Untested lanes worth a look next
- iOS 27 free Private Cloud Compute Foundation Models (no API bill, privacy story); very few polished consumer apps use it.
- Customizable widgets via App Intents (a Widgetsmith moment for someone with taste).
- Music Understanding framework (iOS 27): zero consumer incumbents ("your sonic aura").
- Siri / Spotlight entity schemas for lifestyle apps.
- Non-femtech identity niches where voice + design win.

## The honest pattern
Every femtech gap pointed back at LILITH's foundation (cycle engine, voice, privacy, receipts). The femtech feature space is saturated; the defensible assets are Maria's voice, taste, and (if she wants it) her face on TikTok.

# Round 3: music + movement (Oct 19, 2026)

## Music tech reality check
- Apple Music Understanding (iOS 27) is real: key, BPM, beats/bars, song sections, pace, instruments, loudness. NO mood output.
- It CANNOT analyze Apple Music streams or DRM songs. Spotify shut its audio-features API to new apps in 2024.
- So: "analyze her own playlist" is closed. What works: music the app OWNS (commissioned tracks), or songs she picks as a ritual cue without analysis.
- Licensing is dangerous: publishers sued Peloton for $300M+.

## Retention truth
- Health & Fitness day-30 retention ~8%. "Pay then forget" is the industry's business model.
- What sticks: tie to a ritual she already does, content that only unlocks during the activity and keeps refreshing, social/identity (Strava clubs, Ladder teams).
- Music measurably improves mood and lowers perceived effort (139-study meta-analysis).

## Five concepts
1. WALK-OUT SONG: gym confidence for beginners. Pick your walk-out song, Maria's voice talks you through the first awkward 10 minutes at the gym. 53% of UK women felt gym-intimidated.
2. SIDE A / SIDE B: each workout is one song or album side, original commissioned music, chorus = effort, verse = recovery, synced to the music's actual sections. Weekly new drops. Hardest to copy.
3. THE WALK: daily 20-30 min audio walk with Maria + original score (main character walk, breakup walk, Sunday reset). Hot Girl Walk has no app. Monthly live city walks.
4. BARE MINIMUM: low-energy-day movement, 3 songs 3 moves done. Could be a LILITH module.
5. POD: 3-6 friends, shared weekly soundtrack, voice-note check-ins, no leaderboards. Needs accounts.

Research pick: THE WALK as the way in, SIDE A/SIDE B's owned music as the long-term moat.

# Round 4: the limbo era (Oct 19, 2026)

## Demand
- Keyes: ~17% of adults flourishing, ~57% "moderately ok, not flourishing", ~12% languishing. Maria's "not happy not sad" is the big middle.
- Gallup: US 18-29 thriving fell from 64% (2010) to 44% (2026).
- 49% of Gen Z and 41% of millennials bed rot often or sometimes (Morning Consult 2025). "Brain rot" was Oxford Word of the Year 2024.

## Competitors
- Finch (self-care pet): ~5M downloads, ~4.95 stars, maybe ~$1M/mo (unverified). Proves the tiny-self-care loop pays. Never shows WHY you feel how you feel.
- How We Feel (free), Daylio, Bearable (clinical), Exist.io (nerdy) do mood or correlations. Nobody does "hype friend + receipts".
- Opal / one sec block screen time but shame you and never link it to mood.

## Tech reality
- Auto-collected for free: sleep, steps, workouts, daylight (Watch), moods logged in Apple Health.
- Screen time: the app can SHOW it but cannot read the numbers back. Only rough buckets ("social over 1h today"). Needs Apple's approval for the entitlement.
- Apple's on-device AI is free; the voice must still be hand-tuned (people bail on AI-smelling copy).
- The one unavoidable input: one mood tap a day.

## Concepts
- A. RECEIPTS (7/10): passive inputs + one mood tap, Sunday "your week, receipted" reveal.
- B. GET UP, GIRL (8/10): one tiny daily quest (5 min of sun, walk to the corner), auto-verified by Health so nothing to log, hype not guilt, grace-first streaks. Finch loop with Maria's hype voice instead of a pet.
- C. THE SWAP (5/10): screen time interrupt with a swap. Crowded, better as a feature.
- D. LIMBO ERA 90 DAYS (6/10): paid cohort season, creator-led, needs accounts.

Research pick: B as the daily app, A as its Sunday payoff, C later.

# Round 5: wearables + woo + friends (Oct 19, 2026)

## Market
- Oura S-1 (Sept 2026): 5.0M paid members, ~72% women, female members growing ~143%/yr, ~85% 12-month retention. Fastest growing: women in their early 20s. Maria's user IS Oura's core customer.
- Oura and Ultrahuman are both pushing hard in the UAE (Oura Ring 5 from AED 1,599, GluCare partnership; Ultrahuman Dubai office). No public UAE ring-share data.
- Official social features are weak: Oura Circles = scores + emoji (reviewers forget to check, dislike sleep as competition). Whoop = leaderboards. Bevel friends still unshipped. Nobody does CARE between friends.

## Data access
- HealthKit works day one: Apple Watch = full depth (HRV, sleep stages, temp). Oura exports sleep + heart rate, NOT HRV/temp/readiness to Health (verify on device).
- Oura API: OAuth only, 10 users until approved, possible 2026 restrictions on AI use (UNVERIFIED, read terms). Whoop similar. Ultrahuman partner apply-only.

## The science (honest)
- Moon + sleep: CONTESTED. Casiraghi 2021 found later, shorter sleep in the days before the full moon; larger reanalyses found nothing at group level. Group nulls don't rule out personal patterns, so "does it affect YOU" is a fair personal experiment.
- Moon + periods: debunked at population level (Clue, 7.5M cycles).
- Cycle phase vs temp/HR/HRV: solid.

## Competitors
- No app found that reads wearable data through a moon/astro lens. Stardust: no wearables. Co-Star / The Pattern: friends but no body data.

## Concepts
- A. ALMANAC (7.5/10): the woo fact-checked against your own body. Monthly verdict card: "Full moon: no effect on you. Luteal week: you lose 40 min. Late dinners: the real villain." Experiments compound.
- B. ORBIT (7 alone, 8.5 with A): 3-8 friends see each other's state as weather, never scores, each with a care prompt.
- C. MOON PACTS (7/10): two friends start an experiment on the new moon, reveal on the full moon.
- D. HILAL (6 alone, 8 as launch wedge): Hijri/Ramadan-aware sleep + recovery for the Gulf.

Research pick: A core + B social + C mechanic + D as Gulf launch campaign.

# Round 6: the complicated-body app (Oct 19, 2026)

## Demand (strong pairs)
- PMDD x ADHD: 31.4% of women with ADHD screened positive for PMDD vs 9.8% of controls (2025, n=700+).
- Perimenopause x ADHD: 54% of women with ADHD had debilitating peri symptoms vs ~33% without (Iceland, n=5,392).
- PCOS x GLP-1: prescriptions among women with PCOS went 2.4% (2021) to 17.6% (2025), before telehealth/compounded.
- Tirzepatide cuts the pill's estrogen 55-66%: backup birth control for 4 weeks after starting AND after every dose increase.
- Communities: r/ADHDwomen ~584k, r/PCOS ~238k, r/PMDD ~147k (stale snapshots).

## Competitors
- Oura (biggest threat): Cycle Insights, $99 blood panels, Advisor AI, GLP-1 Insights + Health Radar (Oct 2026). Oura-ring only, no PMDD/ADHD, no multi-med, no doctor report.
- Guava ($78/yr): symptoms + meds + wearables + correlations + doctor sharing, but gender-neutral, clinical, no cycle phase. ~40% of the concept.
- Bearable ($35/yr): overwhelms users. Visible: proves people pay for "HRV says rest".
- Nobody does all four: cycle-phase lens on everything + multi-med/condition timeline + any wearable via HealthKit + doctor report.

## Risks
- Cold start: phase patterns need many cycles (~6 luteal weeks in 6 months). Show "early hunches" with counts, value must exist on day 1.
- Logging overwhelm (Bearable's problem).
- Regulatory: describe her data, never interpret meds ("your dose isn't working" = no). UAE health-data law: stay on-device. 1-hour UAE consult before launch.
- Peptides: free-text "other compound" logging only, no catalogs, dose calculators, or stacks; never in marketing.

## Tone
- Women-first by design. Ages 22-55: adult, dry, warm, specific. Cut slang ~80%. Humor from honesty ("your HRV and your Saturday disagree"). Moon layer opt-in, off by default.

## Shapes
- A. THE CHART YOUR DOCTOR WANTS (8/10 wedge): daily charting + meds timeline + Health overlays + labs vault + one-tap doctor PDF. Value on day 1. ~$39.99/yr.
- B. BODY LAB pattern engine (8/10 grown from A): phase-aware patterns across meds, doses, social/activity/rest, wearable. ~$69.99/yr.
- C. DOSE x CYCLE module (fold into A/B): GLP-1 backup-contraception windows, side effects by phase, stimulant luteal notes.

Recommended path: launch A, unlock B after 3+ cycles of data, fold in C.

# Round 7: alter ego + where the woo lives (Oct 19, 2026)

## Alter ego: IN
- Evidence: self-distancing / third-person self-talk lowers anxiety (Kross et al.); the "Batman effect" (White et al. 2017) kids persisted longer when acting as a hero; Todd Herman's Alter Ego Effect (Beyonce's Sasha Fierce).
- Warning: generic positive affirmations can BACKFIRE for people with low self-esteem (Wood, Perunovic & Lee 2009). So confidence must be EARNED and personal: built from her own receipts and chart, never generic.
- Never body/weight-based praise (GLP-1 + body-image sensitivity).

## The structure: two halves
- BODY = receipts. Science only, honest, doctor-ready.
- SELF = myth. Astrology, moon, alter ego. Identity and confidence, clearly labelled as story.
- Astrology seeds the alter ego (Mars = how she fights, Venus = how she shines, Rising = how she walks in).
- Moon = the app's rhythm: new moon, she picks what her alter ego does this month; full moon, the receipts card.
- WOO DIAL in settings: Off / A little / Full sky. Health works fully at Off.

## Hard-day example
"Luteal week and your HRV is low. The last 4 times this happened you still showed up for Thursday. [Her alter ego] doesn't need to be loud this week. She needs to be on time."
