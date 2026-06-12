# Fix batch from device testing (June 12)

Read CLAUDE.md first, then do everything below.

## 1. Runaway scope bug (also the money leak)
The scope switcher cycles from daily to weekly to monthly BY ITSELF while the app sits open, and each switch fetches. Find the cause (a timer, an animation binding, or anything mutating the scope state) and remove it. Scopes change on user tap and on nothing else.

Also implement on-device caching: each scope's reading is cached keyed by scope + date, shown instantly on revisit, and the backend is only called if there is no cached reading for that scope today or the date rolled over. Same-day re-views of any scope must cost zero network calls. Pull-to-refresh is the only manual re-fetch.

## 2. Long-form typography
docs/03-BRAND-VOICE-DESIGN.md has a new long-form rule from Maria. Daily stays centered. Weekly and monthly bodies become left-aligned reading columns: line spacing around 1.7, generous side padding, paragraphs with visible space between them. Headline and mantra stay centered. Monthly gets tiny gold letterspaced mono section labels per the doc. Also remove any line limits anywhere: no scope ever truncates with an ellipsis.

## 3. Backend format
docs/06-VOICE-ENGINE.md now requires weekly and monthly responses as paragraphs separated by blank lines, with the validator checking 3+ paragraphs on weekly and 4+ on monthly. Update the prompt and validator to match.

## 4. Tone fix
docs/06-VOICE-ENGINE.md also has two new sections that must go into the deployed system prompt verbatim: the SASS RATIO rules (every weekly/monthly paragraph carries at least one line with attitude, max two plain-explainer sentences in a row, quotable quotas per scope) and Example 3, the full weekly exemplar that anchors long-form tone.

## Deploy
Redeploy the backend with vercel --prod.

## Acceptance tests (do all three and report)
a. Leave the app open untouched for three minutes with Vercel logs visible: zero Claude calls.
b. Fetch one fresh weekly: confirm paragraphs render with visible spacing and left alignment, and paste the text into the chat so Maria can judge the sass.
c. Layout check: if the weekly body looks like centered movie credits, it failed.
