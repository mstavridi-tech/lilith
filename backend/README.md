# LILITH horoscope backend

One Vercel serverless function that writes the horoscopes. It receives placements only (never a
name, email, or device id), calls the Claude API with the LILITH voice prompt from
`docs/06-VOICE-ENGINE.md`, validates the output against the hard rules, and returns
`{ headline, reading, mantra, affirmation }`.

The Anthropic key lives ONLY in the `ANTHROPIC_API_KEY` environment variable. It is never in the
app and never committed here (see `.gitignore`).

## Files
- `api/horoscope.js` — the function (POST `/api/horoscope`)
- `vercel.json` — runtime config (60s max duration)
- `package.json` — ESM, no dependencies (uses built-in `fetch`)

## Deploy (personal Vercel account)
Run these from inside this `backend/` folder.

```
npm i -g vercel          # once, installs the CLI
vercel login             # opens the browser
vercel link              # choose your PERSONAL scope, create project "lilith-horoscope"
vercel env add ANTHROPIC_API_KEY production   # paste your key when prompted
vercel --prod            # deploys, prints the production URL
```

Then set `HoroscopeService.backendURL` in the app to `https://<that-url>/api/horoscope`.

## Test it
```
curl -s -X POST https://<your-url>/api/horoscope \
  -H 'content-type: application/json' \
  -d '{"scope":"daily","bigThree":"Leo sun, Taurus moon, Scorpio rising","natalSummary":["☉ 13° Leo","☽ 1° Taurus"],"currentTransits":["☽ 1° Taurus"],"moonPhase":"Waning Crescent","cyclePhase":null}'
```

## Models
- daily: `claude-haiku-4-5-20251001` (fast, cheap)
- weekly / monthly: `claude-sonnet-4-6` (stronger for the longer arcs)

## Cost control
Warm-instance cache by (big three + date + scope). Durable caching via Vercel KV is a later
optimization. Server-side validation re-rolls once on any hard-rule violation, then returns a
non-200 so the app shows its own in-voice offline reading.
