import SwiftUI

/// The LILITH look: cosmic editorial, Co-Star × DONDA. See docs/03 and docs/inspo/.
/// Grainy black, ember gradients, gold hairlines, cream editorial type. NO purple-pink cliché.
/// Every color and font in the app comes from here. Never hardcode elsewhere.
enum Theme {

    // MARK: - Colors
    static let void = Color(red: 0.039, green: 0.039, blue: 0.059)  // #0A0A0F grainy near-black
    static let bone = Color(red: 0.910, green: 0.886, blue: 0.839)  // #E8E2D6 warm cream text
    static let gold = Color(red: 0.788, green: 0.659, blue: 0.404)  // #C9A867 hairlines, glyphs, luxury
    static let ember = Color(red: 0.851, green: 0.400, blue: 0.231) // #D9663B burnt orange, the energy accent
    static let blood = Color(red: 0.557, green: 0.231, blue: 0.275) // #8E3B46 deep wine, cycle features

    // MARK: - Typography
    /// Huge all-caps display headers. One idea per screen.
    static func display(_ size: CGFloat = 40) -> Font {
        .system(size: size, weight: .black, design: .default)
    }

    /// Body copy. Generous, readable, never tiny.
    static func body(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }

    /// Degrees, dates, ephemeris numbers. Monospaced = authority.
    static func mono(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
}

/// Reusable screenshot-bait card style for the daily horoscope.
struct LilithCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 4) // sharp, brutalist, barely rounded
                    .fill(Theme.void)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .strokeBorder(Theme.gold.opacity(0.4), lineWidth: 0.5)
                    )
            )
    }
}

extension View {
    func lilithCard() -> some View { modifier(LilithCard()) }
}
