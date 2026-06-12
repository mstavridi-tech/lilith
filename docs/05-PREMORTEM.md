# LILITH — Premortem

It is June 2027. LILITH is dead. We are at the funeral. What killed her? Causes ranked by how likely they are, with the prevention plan for each.

---

## 1. She never shipped (likelihood: HIGH — this kills most apps like this)

**The autopsy:** The feature list was a whole universe: charts, cycles, tarot, AI chat, astrocartography with live location, friends, messaging. Every week the scope grew, nothing reached the App Store, and after eight months of building Maria burned out with a 70-percent-done everything-app no one ever used.

**Prevention:** Phase discipline is law. Phase 1 ships even though it's "just" charts and horoscopes. A live app with 50 users teaches more than six more months of building. The CLAUDE.md hard rule exists precisely because future-Maria will be tempted, and future-Claude will be agreeable.

## 2. The chat ate the margin (likelihood: HIGH once Phase 3 ships)

**The autopsy:** The BFF chat was the best feature, so the heaviest users talked to it for hours daily, and the chat allowances were set by vibes instead of unit math. The top 5 percent of users cost more in API fees than they paid. Growth made losses bigger.

**Prevention:** The tier ladder exists for this: free gets a taste, LILITH+ ($14.99) gets a daily allowance, LILITH BFF ($24.99) gets unlimited — so the heaviest chatters are the highest payers by design. But tiers only work if the numbers are watched: track API cost per user per day with an alert threshold, set the + allowance from real cost data not vibes, use a cheap fast model for everyday talk and reserve the expensive model for deep readings. Soft-cap with grace ("LILITH needs her beauty sleep, talk tomorrow"), never a paywall slap. If even BFF-tier users cost more than $24.99, that's a model-routing problem to fix immediately.

## 3. Privacy scandal (likelihood: MEDIUM, severity: FATAL)

**The autopsy:** An app holding cycle data plus location data plus intimate chat logs got caught doing something careless — a leaky analytics SDK, a server log with chat content, a subpoena story in the press. For a women's health adjacent app, one screenshot of a bad data practice was the end. Trust is the entire product.

**Prevention:** On-device by default for everything sensitive. No third-party ad or analytics SDKs, ever. Server stores nothing identifiable; chat memory lives on the phone where she can see and delete it. Publish a plain-language privacy promise and treat it as marketing. Cycle data and location data never travel together. If we wouldn't be comfortable with the data practice on the front page of TikTok, we don't do it.

## 4. The AI said something it can never say (likelihood: MEDIUM, severity: FATAL)

**The autopsy:** A vulnerable user in real crisis got hype-girl deflection instead of care, or the bot affirmed a genuinely harmful delusion, or it gave confident medical advice about a missed period. The screenshot went viral. App Store rating cratered, press ran "the delulu app that tells girls everything is fine."

**Prevention:** The safety layer is in the system prompt from the first chat build, not bolted on later: crisis signals soften the persona and surface real resources; medical, contraception, and self-harm topics have hard rails; the reality-check rule is itself a safety feature. Red-team the persona before launch with the darkest inputs we can think of. This is the one feature where "ship fast" loses to "ship right."

## 5. Day-30 ghost town (likelihood: MEDIUM)

**The autopsy:** Downloads were great, the aesthetic went viral, and 30 days later everyone was gone. The horoscopes, on reread, felt samey. The app was a beautiful toy, not a habit.

**Prevention:** The product is the morning ritual: notification → card → screenshot. Variety engineering in the AI prompts (rotate structure, length, mood so dailies never feel templated). The cycle layer is the retention anchor — an app that knows your luteal phase gets opened in week 4 when the novelty is gone. Measure D7/D30 from the first TestFlight and treat retention below 15 percent at D7 as a fire alarm, not a detail.

## 6. App Review hell (likelihood: MEDIUM, severity: delays not death)

**The autopsy:** Rejected for background Always-location with a fuzzy justification. Rejected because the AI chat lacked moderation controls. Flagged for health claims in cycle copy. Each rejection cost weeks.

**Prevention:** Stage the risky features: location is When-In-Use first, background later with an airtight purpose string. Chat ships with the safety layer and a report mechanism. Cycle copy says wellness, never diagnosis or contraception. Read the current App Review Guidelines before each submission with AI chat, health data, and location sections in mind.

## 7. Co-Star ships the same thing (likelihood: LOW-MEDIUM)

**The autopsy:** A funded competitor added an AI companion and cycle layer, and had millions of users already.

**Prevention:** Can't prevent, can outrun in spirit: the voice is the moat, and big-company committees are bad at "girl, take a chill pill." Ship fast, own the niche community hard (the girls and gays evangelize), and keep the personal-context depth (chart + cycle + memory) that a bolt-on chatbot won't match.

## 8. The chart math was wrong (likelihood: LOW, severity: brand-breaking embarrassment)

**The autopsy:** A timezone bug put thousands of users' rising signs one sign off. Astrology Twitter noticed. "The app that reads your chart to the T" became a joke.

**Prevention:** The verification rule: five known birthdays checked against astro.com before any chart feature ships, including southern hemisphere and midnight-boundary cases. Never skip it, even when the demo looks right.

---

## Kill criteria (honest checkpoints, set now while heads are cool)

- If Phase 1 hasn't shipped to TestFlight within 3 months of starting the Xcode project: stop adding, cut scope, ship what exists
- If D7 retention stays under 15 percent after two serious voice/content iterations: the concept needs rethinking, not more features
- If chat API costs exceed 40 percent of subscription revenue for two consecutive months: pricing or metering changes immediately, not "next quarter"

The good news, Maria: every one of these deaths is preventable, and numbers 1 and 2 — the most likely ones — are entirely within your control.
