import SwiftUI

// MARK: - The shareable reading (July 6, Maria: the Today card is surrounded by her personal
// data, so she'd never screenshot it. This is the clean version: JUST the reading, dressed up,
// wordmark at the bottom, built to be screenshotted or shared straight to social.)
//
// Privacy by composition: the card carries the date, the sky, the reading, the mantra, and her
// big three (a flex, not a secret). No cycle day, no vibe, no logs, ever.

struct ReadingShareSheet: View {
    let response: HoroscopeService.HoroscopeResponse
    let bigThree: String
    @Environment(\.dismiss) private var dismiss
    @State private var rendered: Image?

    var body: some View {
        ZStack {
            card
        }
        .glassSheet(glyph: "", accent: Theme.gold)
        .overlay(alignment: .topTrailing) {
            Button { dismiss() } label: {
                Text("CLOSE")
                    .font(Theme.control(11)).tracking(1.1)
                    .foregroundStyle(Theme.gold.opacity(0.75))
                    .padding(20)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            // One quiet share glyph: renders a CLEAN image (no buttons on it) for the share
            // sheet, so what lands on social is pixel-perfect even if she never screenshots.
            if let rendered {
                ShareLink(item: rendered,
                          preview: SharePreview("Today's reading", image: rendered)) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 17, weight: .light))
                        .foregroundStyle(Theme.gold)
                        .padding(14)
                        .background(Circle().fill(.ultraThinMaterial)
                            .overlay(Circle().strokeBorder(Theme.gold.opacity(0.35), lineWidth: 0.5)))
                        .padding(20)
                }
            }
        }
        .task {
            let renderer = ImageRenderer(content: exportCard.frame(width: 420))
            renderer.scale = 3
            if let ui = renderer.uiImage { rendered = Image(uiImage: ui) }
        }
    }

    /// What she sees (and screenshots): the reading alone on the moonlight plate.
    private var card: some View {
        cardContent
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(plate)
    }

    /// What the share button exports: same composition at a fixed social-friendly width.
    private var exportCard: some View {
        cardContent
            .background(plate)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(Self.dateLine.string(from: Date()).uppercased())
                .font(Theme.control(10)).tracking(1.6)
                .foregroundStyle(Theme.gold.opacity(0.85))
                .padding(.top, 70)

            Text(response.headline)
                .displayCaps(27, em: 0.1)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 18)

            Text(response.reading)
                .font(Theme.body(17))
                .foregroundStyle(Theme.bone.opacity(0.92))
                .lineSpacing(8)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 20)

            HairlineDivider(width: 120)
                .padding(.top, 26)

            Text(response.cardMantra)
                .font(Theme.control(12)).tracking(2.2)
                .foregroundStyle(Theme.gold)
                .padding(.top, 18)

            Text(bigThree)
                .font(Theme.control(9)).tracking(1.4)
                .foregroundStyle(Theme.bone.opacity(0.5))
                .padding(.top, 10)

            Spacer(minLength: 40)

            VStack(alignment: .center, spacing: 6) {
                Wordmark()
                Text("your pocket best friend")
                    .font(Theme.body(12).italic())
                    .foregroundStyle(Theme.bone.opacity(0.55))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 54)
        }
        .padding(.horizontal, 34)
        .shadow(color: .black.opacity(0.4), radius: 8, y: 1)
    }

    private var plate: some View {
        ZStack {
            Theme.void
            if let img = UIImage(named: AuraBackdrop.moonlight.rawValue) {
                Image(uiImage: img).resizable().scaledToFill()
            }
            LinearGradient(stops: [
                .init(color: Theme.void.opacity(0.30), location: 0.0),
                .init(color: Theme.void.opacity(0.72), location: 0.45),
                .init(color: Theme.void.opacity(0.92), location: 1.0),
            ], startPoint: .top, endPoint: .bottom)
        }
        .ignoresSafeArea()
    }

    private static let dateLine: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "EEEE, d MMMM yyyy"; return f
    }()
}
