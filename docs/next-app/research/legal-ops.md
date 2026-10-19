# LILITH: Legal and Ops Checklist for a Solo Founder Launching a Paid iOS Health App from Dubai

Researched October 19, 2026. This is research, not legal or tax advice. Items marked **[UNVERIFIED]** come from secondary sources (consultancy blogs, forums) or could not be confirmed against a primary source. Items marked **[LAWYER]** need a UAE-qualified lawyer or tax advisor before acting.

Context: Maria lives in Dubai, is employed on an employer-sponsored visa, wants a TestFlight beta by December 2026 and paid launch around Jan to Feb 2027. App: women's health tracker (HealthKit wearable data, cycle, meds incl. GLP-1s and stimulants, check-ins, lab result storage, doctor-ready PDF, pattern insights, optional astrology). Data on-device. Subscriptions via App Store.

---

## 1. Apple Developer Program from the UAE

**Fee:** USD 99/year, billed in local currency ([magora-systems](https://magora-systems.com/duns-number-apple-developer/)).

**Individual enrollment**
- Needs an Apple Account with two-factor auth, your legal name (no nickname or company name, or review is delayed), and a government photo ID (passport accepted in most regions), verified in the Apple Developer app on one device for the whole flow ([Apple: Enrolling with the Apple Developer app](https://developer.apple.com/support/app-account)).
- Pitfall: the Apple Account region must match the ID. Forum users were rejected when account region and passport country disagreed; non-local passports sometimes need a manual upload link from Apple support ([forum](https://developer.apple.com/forums/thread/813667), [forum](https://developer.apple.com/forums/thread/839579)). Maria's account region is presumably UAE; if her passport is non-UAE (likely), expect a possible manual-verification detour. **[UNVERIFIED for UAE specifically]**
- Typical approval: often 24 to 48 hours, but forum reports show 2+ weeks stuck "In Review" ([forum](https://developer.apple.com/forums/thread/829509)). Budget 1 to 2 weeks.
- Seller name on the App Store = her personal legal name.

**Organization enrollment**
- Requires a legal entity (sole proprietors, DBAs, trade names and branches are not accepted), a D-U-N-S number, a public website on the company's domain, and a person with signing authority ([median.co](https://median.co/blog/how-to-change-your-apple-developer-account-from-individual-to-organization), [mobiloud](https://www.mobiloud.com/docs/convert-individual-apple-developer-account-to-organizational)).
- D-U-N-S: free via Apple's lookup tool; new numbers take up to 5 business days from D&B plus up to 2 business days for Apple to receive it ([tapcart help quoting Apple](https://help.tapcart.com/en/articles/11120069-d-u-n-s-number)). A brand-new UAE free zone company will need a new number.
- Review: highly variable. One org enrollment reported "being processed" for 4+ months in 2026 ([forum](https://developer.apple.com/forums/thread/840217)). Realistic budget: 2 to 6 weeks after you have the trade license.
- Implication: the org route needs a trade license FIRST (2 to 4 weeks), then D-U-N-S (1 to 2 weeks), then Apple review (2 to 6 weeks). That is 5 to 12 weeks, which **puts a December TestFlight at risk**.

**Converting / transferring later**
- You can request conversion of an individual membership to organization through Apple Developer support ("Account Information Update"); third-party guides say it takes several days once docs are in order ([mobiloud](https://www.mobiloud.com/help-knowledge-base/convert-apple-developer-program-individual-to-organization)). Apps can also be transferred between accounts via App Store Connect's App Transfer feature; ratings, reviews and existing subscribers move with the app. **[UNVERIFIED: confirm in App Store Connect Help that apps with auto-renew subscriptions and HealthKit entitlement transfer cleanly before relying on this]**

**Recommendation:** Enroll as **Individual now** (this week). It unblocks TestFlight, Sign in with Apple, push, and the paid launch. Convert to an organization later once a company exists.

**EU trader status (important for an individual):** Under the EU Digital Services Act, any developer earning revenue (paid apps, IAP, ads) must declare trader status; **individuals must display an address (or P.O. Box), phone number and email publicly** on the EU App Store, while organizations show only phone and email. Apps without trader info were pulled from the EU store on Feb 18, 2025 ([TechCrunch](https://techcrunch.com/2025/02/18/apple-purges-apps-without-contact-info-from-eu-app-store-as-dsa-deadline-hits), [9to5Mac](https://9to5mac.com/2024/10/17/developers-address-phone-number-eu-app-store)). Options: a company, a virtual office/P.O. Box and a dedicated number, or exclude EU storefronts at launch.

**TestFlight**
- Internal testers: up to 100 members of the App Store Connect team, no Beta App Review, builds available almost immediately.
- External testers: up to 10,000 per app, invited by email or public link; the first build of each version requires Beta App Review, usually 24 to 48 hours ([Apple: Invite external testers](https://www.developer.apple.com/help/app-store-connect/test-a-beta-version/invite-external-testers), [Kodeco](https://www.kodeco.com/10868372-testflight-essentials-quickstart-guide-for-ios-beta-testing)). Builds expire after 90 days. Beta review applies the App Store Review Guidelines, so the health disclaimers, privacy policy URL and HealthKit purpose strings must already be in place.

**Small Business Program:** enroll for 15% commission instead of 30% (under USD 1M proceeds/year, all associated accounts combined) via a short form in App Store Connect ([Adapty 2026](https://adapty.io/blog/app-store-small-business-program/)). Note: auto-renew subscriptions already drop to 15% after a subscriber's first year; SBP makes it 15% from day one.

---

## 2. UAE business setup while employed

**Can she start a side business?**
- Every source agrees paid work needs some authorization; there is no legal "quiet freelancing" ([Gulf News](https://gulfnews.com/living-in-uae/ask-us/9-ways-to-legally-earn-a-side-income-in-the-uae-1.1696424182119)).
- Free zone company license: several free zones say an employer NOC is **not** required to issue a license where you remain on your employer's visa and don't take a free zone visa ([Meydan FZ](https://www.meydanfz.ae/blog/can-you-start-a-business-while-still-being-employed-in-dubai)). This is the zone's own marketing, so **[UNVERIFIED]**.
- MOHRE freelance work permit: requires an NOC from the current sponsor, and the activity must not compete with the employer or clash with working hours ([Takween](https://takweenadvisory.ae/en/blog/uae-freelance-visa-vs-freelance-license-difference)). MOHRE part-time permit ~AED 600/year, NOC generally required (degree holders may be exempt) **[UNVERIFIED]**.
- Dubai GoFreelance (Dubai Development Authority) tech permit: software development is an eligible field; NOC listed among required docs; fees reported as AED 7,500/yr (older) or AED 2,750 (1 yr) / 5,000 (3 yr) plus establishment card ~AED 2,000 ([Khaleej Times](https://www.khaleejtimes.com/life-and-living/visa-and-immigration-in-uae/freelance-visa-in-uae-explained-types-cost-eligibility), [Bayut](https://www.bayut.com/mybayut/freelance-visa-dubai-guide/)). **[UNVERIFIED current price; check gofreelance.ae]**
- Regardless of the license route, her **employment contract governs**: a full-time employee runs personal business "within the restrictions set by the employer" and must not breach contract duties under the Labour Law ([Gulf News, quoting a legal adviser](https://gulfnews.com/living-in-uae/ask-us/is-it-legal-to-start-a-business-while-working-in-the-uae-1.1651756897278)). Article 10 of Federal Decree-Law 33/2021 governs non-competes (max 2 years, limited in geography and scope) ([MOHRE text](https://www.mohre.gov.ae/assets/download/3bde4984/Federal%20Decree-Law%20No.%2033%20of%202021%20Regarding%20the%20Regulation%20of%20Employment%20Relationship%20and%20its%20amendments_638990571068264034.pdf.aspx), [RemotePass](https://remotepass.com/country/uae/employment-laws)).
- Golden Visa holders: self-sponsored residency; blogs say holders may run their own business or freelance freely, but the Golden Visa is residency, not a trade license, so a license is still needed for commercial activity **[UNVERIFIED]** ([Virtuzone](https://virtuzone.com/blog/golden-visa-uae-benefits/)).

**Free zone license costs (2026, starting packages, no visa)** ([BCL 2026 guide](https://bcl.ae/blogs/cheapest-free-zone-licence-dubai/), [businessdubai.ae](https://www.businessdubai.ae/blogs/cheapest-free-zones-uae-ranked)):

| Zone | From (AED/yr) | Notes |
|---|---|---|
| Ajman (ANCFZ) | ~4,888 | Prices from agents, not zone **[UNVERIFIED]** |
| SHAMS (Sharjah Media City) | ~5,760 | Fully digital setup, media/IT friendly |
| RAKEZ | ~6,000 | Scalable |
| Dubai Silicon Oasis | ~11,900 | **[UNVERIFIED]** |
| Meydan (Dubai) | ~12,500 | Dubai address, digital setup |
| IFZA (Dubai) | ~12,900 | IFZA does not publish prices **[UNVERIFIED]** |
| Dubai Internet City / in5 | ~15,000+ | Tech prestige, in5 is the incubator route |
| DMCC | ~20,000+ | Overkill for a solo app **[UNVERIFIED]** |

Activities to request: "Software Publishing", "Computer Systems & Software Design", or "E-commerce / Mobile Applications Development". Confirm the exact activity code covers selling apps via a marketplace. Add-ons: establishment card, flexi-desk, D-U-N-S (free), corporate bank account. Visa (if ever needed) ~AED 4,000 to 5,000 per person.

**Is a license needed to receive App Store payouts as an individual?** No source answers this directly. UAE practice is that ongoing commercial activity requires a license, and Apple's individual track will pay into a personal bank account. Many residents do receive indie app income personally; whether this is compliant is a grey area. **[LAWYER]** Practical view: fine for a free beta; get licensed before paid launch or soon after first meaningful revenue.

**Banking:** Individual: Apple pays to a personal UAE bank account (IBAN); AED payout supported **[UNVERIFIED, check App Store Connect bank currencies]**. Company: UAE corporate accounts for new free zone entities commonly take 2 to 8 weeks with KYC; digital banks (Wio Business, etc.) are faster **[UNVERIFIED]**.

**UAE taxes**
- No UAE personal income tax.
- Corporate tax for **individuals**: only applies if business turnover exceeds **AED 1,000,000** in a calendar year (Cabinet Decision 49/2023, effective June 1, 2023); below that, no registration ([PwC](https://pwc.com/m1/en/services/tax/me-tax-legal-news/2023/uae-ct-cabinet-decision-no-49-2023.html), [WAM/MoF](https://www.wam.ae/en/article/hszrh3wv-ministry-finance-announces-uae-cabinet-decision)). So App Store income as an individual is untaxed in the UAE until AED 1M turnover.
- For a **company**: corporate tax registration is mandatory regardless of income; 9% on taxable income above AED 375,000; Small Business Relief (revenue up to AED 3M) available for tax periods ending on or before Dec 31, 2026 per Ministerial Decision 73/2023 **[UNVERIFIED whether extended past 2026; LAWYER/tax advisor]**. Free zone "qualifying" 0% regime is complex and probably irrelevant at this size.
- VAT: mandatory registration at AED 375,000 taxable supplies in 12 months, voluntary from AED 187,500 ([neolegal](https://neolegal.ae/insights/vat-uae-services-digital-businesses)). Apple is the merchant of record for App Store sales; how a UAE developer's proceeds are treated for VAT is not settled in sources. **[LAWYER/tax advisor]**

**US tax forms:** Individuals file **W-8BEN** in App Store Connect (companies W-8BEN-E). The **US has no income tax treaty with the UAE**, so no treaty reduction; Apple applies 30% withholding to US-sourced proceeds where no exemption applies ([Apple forum](https://developer.apple.com/forums/thread/29204), [Apple USTI notice](https://apple.com/legal/procurement/docs/USTI.pdf)). Form valid ~3 years. **[UNVERIFIED: confirm the exact withholding behavior in App Store Connect's Tax Forms section; US sales may lose 30% of proceeds]**

---

## 3. IP: making sure the employer can't claim LILITH

- UAE Copyright Law (Federal Decree-Law 38/2021) Article 28, per commentators: works made by an employee **during and related to the job** vest in the employer; works **not related to the employer's business and not using the employer's experience, information or tools** vest in the employee; contracts can override the default ([CMS](https://cms.law/en/are/legal-updates/uae-amended-ip-laws-take-effect), [Morgan Lewis](https://www.morganlewis.com/ru/blogs/sourcingatmorganlewis/2022/10/protecting-online-data-and-ip-new-copyright-law-provides-clarity-for-uae-businesses)). Apps and software are expressly protected works.
- What to check in her contract and handbook: (1) IP assignment clauses that go beyond Article 28, e.g. "all inventions/works created during employment"; (2) outside-work/moonlighting/conflict-of-interest clauses requiring disclosure or written consent; (3) non-compete (Art. 10); (4) confidentiality; (5) policies on use of company laptop, network, software licenses.
- Hygiene: never use the employer's devices, accounts, Wi-Fi, paid tools, or work hours for LILITH; keep the git history (dated commits) as evidence of independent creation; keep the app outside the employer's line of business; consider a short written acknowledgement/NOC from the employer that LILITH is personal IP. **[LAWYER: 1-hour contract review, roughly AED 1,000 to 3,000, UNVERIFIED rate]**

---

## 4. Health data and privacy

**UAE PDPL (Federal Decree-Law 45/2021):** in force on paper, but the Executive Regulations still appear unpublished as of 2026 commentary, making it not fully enforceable ([Primerus PDF, Mar 2026](https://www.primerus.com/sites/default/files/2026-03/UAE%20Data%20Privacy%20Law.pdf), [Pinsent Masons](https://www.pinsentmasons.com/out-law/guides/business-in-the-uae-navigating-data-protection-regime)). It excludes health data governed by other legislation, deferring to the ICT Health Law. Applies extraterritorially to UAE residents' data. **[UNVERIFIED current status]**

**ICT Health Data Law (Federal Law 2/2019):** applies to "all ICT methods and uses in health fields" in the UAE, defines health data broadly, and restricts storing/processing/transferring health data **outside the UAE** (fines AED 500k to 700k) ([Latham](https://lw.com/thoughtLeadership/lw-new-uae-law-regulates-healthcare-data), [Taylor Wessing](https://www.taylorwessing.com/en/insights-and-events/insights/2021/08/me-health-data-in-the-uae-how-the-health-data-law-works-what-it-protects-and-what-exemptions-exist)). Whether it reaches a consumer wellness app is unsettled. **[LAWYER]** The on-device design is the key mitigation: data stays on the user's phone, no server copy, no cross-border transfer by the developer.

**GDPR / UK GDPR:** offering the app to EU/UK users brings it into scope (Art. 3(2)); health data is special category (Art. 9, explicit consent). Non-EU controllers generally must appoint an **EU representative (Art. 27)** and a UK representative; the exemption doesn't cover special-category data ([TechGDPR](https://techgdpr.com/blog/eu-article-27-representative-explained/)). Whether purely on-device processing makes the developer a "controller" at all is an open question ([sota.io](https://sota.io/blog/gdpr-art-27-eu-representative-non-eu-controllers-developer-guide-2026)). Rep services run roughly EUR 100 to 300/month each **[UNVERIFIED]**. Anything that does leave the device (horoscope API placements, crash logs, analytics, Supabase account) is processing.

**US:**
- **Washington My Health My Data Act:** no revenue threshold, opt-in consent, separate consumer health privacy policy, private right of action ([Sidley](https://datamatters.sidley.com/?p=4971), [Jones Day](https://www.jonesday.com/en/insights/2023/04/my-health-my-data-washington-enacts-first-state-comprehensive-health-privacy-law)). Nevada SB 370 and Connecticut have similar laws ([MoFo](https://www.mofo.com/resources/insights/251215-a-mofo-privacy-minute-q-a-new-york-s-nyhipa-faces-veto)). New York's NYHIPA was vetoed Dec 2025; a revised bill (S9269) passed both houses June 2026, signature status unconfirmed ([Nixon Peabody](https://www.nixonpeabody.com/insights/alerts/2026/07/23/new-york-renews-push-to-enact-consumer-health-information-privacy-act-nyhipa)). **[UNVERIFIED]**
- **FTC Health Breach Notification Rule** (amended, effective July 29, 2024): covers health apps outside HIPAA; a "breach" includes unauthorized **sharing** (e.g. ad SDKs), not just hacks ([Hogan Lovells](https://hoganlovells.com/en/publications/ftc-finalizes-revised-health-breach-notification-rule-expanding-its-scope-and-updating-companies-obligations)).

**What on-device-only avoids:** no server breach surface; no data localization problem; no data broker/ad sharing; most "collection" obligations shrink. **What it does NOT avoid:** the privacy policy, consent for HealthKit, GDPR/MHMDA duties on anything that leaves the device (backend calls, Supabase identity, analytics, crash reporting, the generated PDF once shared), and App Store privacy nutrition labels.

**Privacy policy must include:** identity and contact of the developer; exactly what data is collected, where it lives (on-device vs server), and why; HealthKit data used only for the user's benefit, never for ads, never sold; third parties (Supabase, Vercel, AI provider, Apple) and what each receives; legal bases and explicit consent for health data (GDPR); user rights (access, deletion, withdrawal) and how in-app delete works; retention; international transfers; children (not for under 13/16); a separate Consumer Health Data Privacy Policy linked from the homepage for Washington; breach notification; change log and date. Privacy policy URL is mandatory in App Store Connect.

---

## 5. App Store Review Guidelines (quoted from the live guidelines, Oct 2026)

Source: [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/).
- **1.4.1** Medical apps "may be reviewed with greater scrutiny"; must disclose data and methodology for accuracy claims; "should remind users to check with a doctor in addition to using the app and before making medical decisions." Cite sources for hormone/med content.
- **5.1.1(v)** If accounts exist, **account deletion must be in-app**; don't require login unless core.
- **5.1.2** No use/sharing of personal data without permission; disclose sharing "including with third-party AI" and get explicit permission.
- **5.1.3(i)** HealthKit/health data may not be used for advertising, marketing, or data mining; must disclose the specific health data collected. **5.1.3(ii)** must not write false data to HealthKit and **"may not store personal health information in iCloud"** (still current). Implication: no CloudKit/iCloud backup of cycle, med, or lab data; check that the app's local stores are excluded from iCloud Drive syncing and consider `isExcludedFromBackup` for health files.
- **3.1.1/3.1.2** Digital subscriptions must use IAP; auto-renew must provide ongoing value, minimum 7 days, available across the user's devices. **3.1.2(c)**: before asking to subscribe, clearly describe what she gets for the price and meet Schedule 2 of the Developer Program License Agreement (title, length, price per period, auto-renew terms, links to privacy policy and Terms of Use/EULA in the paywall and App Store metadata, restore purchases).
- **4.3(b) Spam:** "fortune telling" is listed as a saturated category; forum rejection letters show astrology/horoscope apps rejected as spam ([forum](https://developer.apple.com/forums/thread/737999)). Mitigation: position and categorize LILITH as **Health & Fitness**, make health tracking the core, astrology an optional layer; screenshots and description lead with health. Prepare an appeal note listing differentiators (real ephemeris, HealthKit fusion, cycle).
- **Age rating:** new tiers 4+, 9+, 13+, 16+, 18+; questionnaire mandatory since Jan 31, 2026, with medical/wellness questions; frequent medical/treatment info may push to 16+ ([9to5Mac](https://9to5mac.com/2025/07/24/apple-notifies-developers-of-new-app-store-age-rating-system/)). Sex logging + contraception/EC content + meds: expect 16+ or 18+.

---

## 6. Safe wording (FDA general wellness / MHRA / EU MDR)

FDA revised its General Wellness guidance on Jan 6, 2026 (two-factor test unchanged: wellness intended use + low risk) ([Covington](https://www.cov.com/news-and-insights/insights/2026/01/fda-issues-revised-guidance-on-general-wellness-products)). MHRA lists symptom tracking that feeds treatment decisions among functions likely to be a medical device; general information without personalised advice usually isn't ([gmp-compliance](https://gmp-compliance.org/gmp-news/mhras-guidance-for-software-as-a-medical-device-including-apps)). Intended purpose is judged by your claims, so wording is everything:

1. "LILITH helps you notice your own patterns. It doesn't diagnose, treat, or tell you how to take any medication."
2. "Your notes show you logged lower energy on days after a missed dose. Worth bringing up with your prescriber." (observation of her own logs, never "your medication is causing X")
3. "Never change, stop, or time a medication based on this app. That's a conversation for your doctor or pharmacist."
4. "Cycle predictions are estimates for wellness, not contraception and not a fertility test."
5. "The doctor report is a summary of what you logged, to help you talk with your provider. It isn't a medical record or a clinical interpretation."

Avoid: dose suggestions, interaction warnings framed as clinical, "detects", "predicts risk", "diagnoses", lab-value interpretation ("your TSH is abnormal"), GLP-1 titration advice. **[LAWYER/regulatory consultant if the insights layer goes beyond correlation display]**

---

## 7. Trademark

- **UAE (Ministry of Economy and Tourism):** search the online register first (free) or via an agent. Government fees about AED 6,500 per class (filing 750 + publication 750 + registration 5,000); a 2026 guide claims Cabinet Resolution 102/2025 (from Nov 14, 2025) raised this, possibly to AED 6,500 filing + 7,500 registration; expedited exam +AED 2,250/class; 50% discount for National SME Programme members ([ATB Legal](https://atblegal.com/blog/intellectual-property-laww/uae-trademark-fees/), [businessdubai.ae](https://www.businessdubai.ae/blogs/trademark-registration-uae)). **[UNVERIFIED final fee]** Timeline: ~3 to 6 months. Classes: 9 (downloadable app) and 44 (health/wellness info) or 42 (SaaS); 45 arguably for astrology services. Two classes = AED 13,000 to 28,000 plus agent fees.
- **USPTO:** base fee **USD 350 per class** since Jan 18, 2025; +USD 100/class if info is insufficient; +USD 200/class for free-form IDs (use the ID Manual) ([Perkins Coie](https://perkinscoie.com/insights/update/usptos-significant-restructuring-trademark-fees-takes-effect-january-18-2025)). Foreign-domiciled applicants **must use a US-licensed attorney** (roughly USD 500 to 1,500 per filing **[UNVERIFIED]**). Search via USPTO's free Trademark Search. Timeline 8 to 14 months.
- "LILITH" is a common word/name; a clearance search in classes 9/42/44/45 is essential before spending (expect existing marks). A compound mark may register more easily. **[LAWYER]**
- **App Store name:** must be unique across the store, max 30 characters; the name is reserved when you create the app record in App Store Connect (create it early; Apple may reclaim unused reservations). Subtitle can carry the descriptor.

---

## 8. Dated checklist (Oct 19, 2026 to Feb 2027)

| When | Task | Time | Cost |
|---|---|---|---|
| Oct 20 to 24 | Read employment contract + handbook for IP, moonlighting, non-compete, disclosure clauses | 2 h | 0 |
| Oct 20 to 24 | Enroll Apple Developer Program as **Individual** (legal name, passport, Developer app) | 1 h + 1 to 14 days review | USD 99 |
| Oct 20 to 31 | Book 1-hour UAE employment/IP lawyer: contract, NOC question, whether personal payouts need a license | 1 to 2 wks | ~AED 1,000 to 3,000 [UNVERIFIED] |
| Oct 27 | Create App Store Connect app record to reserve the name; bundle ID; enable HealthKit capability | 1 h | 0 |
| Oct 27 to Nov 7 | Trademark clearance search (UAE register, USPTO, App Store, EUIPO) | 1 wk | 0 to agent fee |
| Nov 1 to 14 | Decide entity: (a) stay individual for launch, or (b) free zone company (SHAMS/RAKEZ/Meydan). If (b): apply now; license 1 to 3 wks, then D-U-N-S 1 to 2 wks | 2 to 5 wks | AED 5,760 to 12,900/yr |
| Nov 1 to 14 | Domain + simple website with support email (also needed for org enrollment and DSA) | 1 day | ~USD 20 to 50/yr |
| Nov 1 to 21 | Write privacy policy, WA Consumer Health Data policy, Terms of Use/EULA, in-app disclaimer; host on site | 1 to 2 wks | 0 (templates) to USD 1,000 to 3,000 lawyer review |
| Nov 10 | Submit W-8BEN, bank details, Paid Apps Agreement in App Store Connect | 1 h | 0 |
| Nov 10 | Enroll in App Store Small Business Program | 10 min | 0 |
| Nov 15 to 30 | Complete age-rating questionnaire, App Privacy nutrition label, HealthKit purpose strings, confirm no health data to iCloud | 1 day | 0 |
| Nov 15 | Internal TestFlight (up to 100) | instant | 0 |
| Dec 1 | First external TestFlight build to Beta App Review | 1 to 2 days | 0 |
| Dec 1 to 15 | EU trader status: decide address/P.O. Box + phone, or exclude EU storefronts | 1 day | virtual address ~AED 1,000 to 5,000/yr [UNVERIFIED] |
| Dec | File UAE trademark (classes 9 + 44/42) | filing 1 day, reg 3 to 6 mo | ~AED 13,000+ [UNVERIFIED] |
| Dec to Jan | File USPTO application via US attorney (or later, via Madrid from UAE base) | 8 to 14 mo | USD 700 + attorney |
| Jan 2027 | If GDPR scope kept: appoint EU + UK Art. 27 representatives | 1 wk | ~EUR/GBP 1,200 to 3,600/yr [UNVERIFIED] |
| Jan 2027 | Subscription products, paywall copy per 3.1.2(c), restore purchases, screenshots led by health | 1 to 2 wks | 0 |
| Jan 2027 | If company formed: org Apple account or App Transfer; corporate bank account; CT registration with FTA | 2 to 8 wks | bank fees vary |
| Late Jan 2027 | Submit v1.0 for App Review (allow time for a 4.3 or 1.4.1 rejection + resubmission) | 1 to 7 days per round | 0 |
| Feb 2027 | Paid launch | | |
| Ongoing | Track turnover vs AED 1M (individual CT) and AED 375k (VAT); renew license annually; W-8BEN every 3 yrs | | |

**Lawyer touchpoints, minimum:** (1) employment contract/IP and side-business legality; (2) whether a license is needed before receiving revenue as an individual, and entity choice; (3) privacy policy + ICT Health Law exposure; (4) trademark clearance; (5) tax treatment (VAT on Apple proceeds, US withholding, small business relief after 2026).
