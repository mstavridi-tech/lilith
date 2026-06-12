# LILITH — Your Build Guide

Step by step, from this folder to the app running on your iPhone. Budget a weekend for steps 1 to 5.

## Step 1 — Get the tools (everything here is free)
1. Install **Xcode** from the Mac App Store (it's big, start the download now)
2. Open Xcode once and let it install its extras
3. Supabase account: done. Claude Code wires it up in Step 6
4. You already have Claude Code, so you're set

**What's free vs paid, so there are no surprises:** the entire prototype is free — Xcode, the simulator, and even running on your own iPhone (sign into Xcode with your regular Apple ID; free builds just expire after 7 days, re-run from Xcode to refresh). The **$99/yr Apple Developer Program** is only needed for three things: Sign in with Apple, push notifications, and TestFlight/App Store. Until then, the sign-in screen has a "DEV: skip" button that exists only in development builds. When the money lands: enroll at developer.apple.com (approval takes a day or two), then do the accounts half of Step 6.

## Step 2 — Create the Xcode project (~15 min)
1. Xcode → Create New Project → iOS → App
2. Product Name: **Lilith**. Interface: **SwiftUI**. Language: **Swift**. Storage: **None** for now
3. Save it INSIDE this folder, so the project sits next to `docs/` and `CLAUDE.md`
4. Delete the auto-generated `ContentView.swift`, then drag everything from the `LilithStarter/` folder into the project (check "copy items if needed"). Replace the generated `LilithApp.swift` with ours. Once everything builds, `LilithStarter/` can be deleted

## Step 3 — Add the astronomy library (~10 min)
1. Xcode → File → Add Package Dependencies
2. Paste: `https://github.com/onekiloparsec/SwiftAA`
3. Add it to the Lilith target

## Step 4 — Let Claude Code do the math (~1 to 2 sessions)
Open Terminal in this folder, run `claude`, and say:

> Read CLAUDE.md and do next task 3: implement the stubbed functions in ChartEngine.swift using SwiftAA. Then write a small test that prints my chart so we can verify it.

Then THE VERIFICATION MOMENT: go to astro.com → Free Horoscopes → Natal Chart, enter your own birth data, and compare every planet against what the app computes. They must match (within a degree). If anything is off, tell Claude Code exactly which planet and by how much — it's almost always a timezone bug. Repeat with a friend's birthday or two.

## Step 5 — Run it on your phone (~15 min)
1. Plug in your iPhone, select it as the run target in Xcode, press ▶
2. First time: your phone will ask you to trust the developer (Settings → General → VPN & Device Management)
3. You now have LILITH on your phone. Screenshot the moment. This is the founding artifact

## Step 6 — Accounts + AI horoscopes (~2 sessions)
First the accounts. Tell Claude Code:

> Read CLAUDE.md and do next task 5: wire Sign in with Apple to Supabase per docs/02-ARCHITECTURE.md and the TODO in OnboardingView.

(It will have you add the Sign in with Apple capability in Xcode — two clicks — and paste your Supabase project URL.)

Then the horoscopes. Tell Claude Code:

> Read CLAUDE.md and do next task 6: create the Vercel serverless function for horoscopes per docs/02-ARCHITECTURE.md, using the voice rules from docs/03-BRAND-VOICE-DESIGN.md in the prompt.

You'll need two free-tier accounts: vercel.com (hosting) and an Anthropic API key from console.anthropic.com (the key lives ONLY in Vercel's environment settings, never in the app). Claude Code will walk you through deploying. Then update `backendURL` in HoroscopeService.swift.

## Step 7 — Ship to your girls (TestFlight)
1. Your Apple Developer membership from Step 1 covers this
2. In Xcode: Product → Archive → Distribute → TestFlight
3. Invite your friends by email. Their reactions are your first user research

## When something breaks
Paste the exact error into Claude Code and ask it to fix it. Don't try to interpret the error yourself first — full errors with file names fix faster. If a session goes in circles, start a fresh session with: "Read CLAUDE.md, then look at <the broken thing>."

## What NOT to do yet
No accounts, no cycle tracking, no friends, no Android. Phase 1 first. An app that does one thing beautifully beats a half-built everything app. The girlies can't screenshot a feature list.
