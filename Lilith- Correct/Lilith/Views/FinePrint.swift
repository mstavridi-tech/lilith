import SwiftUI

/// Every disclaimer in the app, consolidated onto one page in YOU (Maria's master list, July 4).
/// The honesty lives together instead of being scattered in footers, and it stays in voice:
/// a best friend telling you the truth, never a legal department clearing its throat.
struct DisclaimersView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("THE FINE PRINT")
                    .displayCaps(28, em: 0.14)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.leading, Theme.tracking(28, em: 0.14))
                    .padding(.top, 44)
                Text("Real talk, all in one place.")
                    .font(Theme.body(15).italic()).foregroundStyle(Theme.gold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                HairlineDivider(width: 120)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 22)

                section("NOT A DOCTOR",
                        "Everything in the Cycle tab is wellness content. I read patterns in what you log, I don't diagnose, treat, or measure anything happening in your body. And say it with me: LILITH is not birth control. Never use my calendar to prevent or plan a pregnancy. That job belongs to real contraception and a real clinician.")

                section("THE HORMONE TALK",
                        "The curves and the hormone weather describe what's TYPICAL for each phase, straight from the textbook. They are never your measured levels. No phone can measure hormones, and any app claiming otherwise is lying to you. If your months keep feeling wildly off the script, that's a doctor conversation, and booking it is self-respect, not drama.")

                section("THE STARS",
                        "Your chart is computed with real astronomy, and what I say about it is perspective, not prophecy. Astrology here is weather, never verdicts: it can frame a mood, it can't run your life. Big decisions get made by you, ideally caffeinated.")

                section("THE VIBE",
                        "THE VIBE ring blends exactly two things: where you are in your cycle and what the moon is doing tonight. No heart rate, no sleep score, no secret biometrics. When a tracker is connected later, I'll tell you exactly what changed and what feeds it.")

                section("YOUR DATA",
                        "Your birth details, your cycle, and everything in the Health Vault live on this phone and nowhere else. When I fetch your reading I send planet positions, never your name, email, or location. Your secrets stay secret, because that's what a best friend is.")

                section("THE BRIDGE",
                        "If anything here ever makes you worry about your body, don't sit with it. Book it with your provider. I'll keep the receipts and the pep talk ready; the medicine is their department.")

                Wordmark()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 44)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .glassSheet(glyph: "", accent: Theme.gold)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.control(11)).tracking(1.1)
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
    }

    private func section(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(Theme.control(10)).tracking(1.1)
                .foregroundStyle(Theme.ember)
            Text(body)
                .font(Theme.body(15)).foregroundStyle(Theme.bone.opacity(0.85))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 28)
    }
}
