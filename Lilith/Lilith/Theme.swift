import SwiftUI
import UIKit
import CoreText

/// The LILITH look: celestial editorial. See docs/03, docs/inspo/, docs/design/.
/// Warm espresso black with heavy grain, REAL moon/nebula photography (never vector planets),
/// gold hairline geometry, letterspaced serif caps. NO purple-pink cliché, NO em dashes in copy.
/// Every color and font in the app comes from here. Never hardcode elsewhere.
enum Theme {

    // MARK: - Colors
    static let void = Color(red: 0.027, green: 0.024, blue: 0.020)  // #070605 near-black cosmos, a breath of warmth
    static let bone = Color(red: 0.910, green: 0.886, blue: 0.839)  // #E8E2D6 warm cream text
    static let gold = Color(red: 0.788, green: 0.659, blue: 0.404)  // #C9A867 hairlines, glyphs, luxury
    static let ember = Color(red: 0.851, green: 0.400, blue: 0.231) // #D9663B muted atmospheric blooms
    static let blood = Color(red: 0.557, green: 0.231, blue: 0.275) // #8E3B46 deep wine, cycle features

    // MARK: - Typography
    //
    // The real typeface is Cormorant Garamond (the single biggest "amateur" tell was the system
    // serif, per docs/08). The three weights are bundled in the target and registered at launch by
    // `registerFonts()`. Until Maria drags the .ttf files in, every call gracefully falls back to
    // New York serif, so the app keeps its current look and nothing breaks.
    //
    // Cormorant runs optically smaller than New York at equal point size, so when the real font is
    // active we scale display type up by `cormorantDisplayScale`. If after building it looks a hair
    // small or large next to the v9 mockup, nudge THIS ONE NUMBER and rebuild.
    //
    // DISPLAY type only (headlines, titles, mantra) uses Cormorant: that is where it shines. The
    // long READING body stays the system serif (New York), which is built for reading on screen and
    // holds contrast on black. Cormorant Regular at body size is too thin to read in long columns.
    static let cormorantDisplayScale: CGFloat = 1.12

    private static let displayFont = "CormorantGaramond-Medium"
    static let italicFont = "CormorantGaramond-MediumItalic"

    /// True once the bundled Cormorant files exist and are registered. Cached after first lookup.
    static let cormorantActive: Bool = UIFont(name: displayFont, size: 12) != nil

    /// Register every bundled font file at runtime. Called once from LilithApp.init, so there's no
    /// Info.plist (UIAppFonts) editing for Maria: just drag the .ttf files into the target. We scan
    /// for any ttf/otf rather than fixed filenames, so it works no matter how the files are named.
    static func registerFonts() {
        for ext in ["ttf", "otf"] {
            for url in Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? [] {
                _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }

    /// Display: serif ALL CAPS, letterspaced wide. Pair with .tracking(tracking(size, em:))
    /// and .textCase(.uppercase) at the call site. Cormorant Medium, New York serif fallback.
    static func display(_ size: CGFloat = 28) -> Font {
        cormorantActive
            ? .custom(displayFont, size: size * cormorantDisplayScale)
            : .system(size: size, weight: .regular, design: .serif)
    }

    /// Tracking that scales with the type: the celestial editorial letterspacing.
    static func displayTracking(_ size: CGFloat) -> CGFloat { size * 0.18 }

    /// Body copy: the system serif (New York), built for reading and high-contrast on black. Kept
    /// deliberately simple and legible while the display type carries the Cormorant character.
    static func body(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .regular, design: .serif)
    }

    /// UI controls only (buttons, toggles): the one place sans-serif lives.
    static func ui(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }

    /// Degrees, dates, ephemeris numbers. Monospaced = authority.
    static func mono(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }

    /// Letterspacing in points for a given size and em value (CSS `letter-spacing` ported).
    /// The mockup's tracking, e.g. headline 0.19em, eyebrow 0.26em, mantra 0.30em, wordmark 0.50em.
    static func tracking(_ size: CGFloat, em: CGFloat) -> CGFloat { size * em }
}

// MARK: - Grain

/// Film grain: a tiny cached noise tile blended over everything with .screen, two passes
/// (fine + coarse) like the mockup's two noise layers. Generated once, reused everywhere.
private let grainTile: Image = {
    let side = 128
    var pixels = [UInt8](repeating: 0, count: side * side * 4)
    for i in stride(from: 0, to: pixels.count, by: 4) {
        let v = UInt8.random(in: 0...255)
        pixels[i] = v; pixels[i + 1] = v; pixels[i + 2] = v; pixels[i + 3] = 255
    }
    let ctx = CGContext(data: &pixels, width: side, height: side, bitsPerComponent: 8,
                        bytesPerRow: side * 4, space: CGColorSpaceCreateDeviceRGB(),
                        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    let cg = ctx!.makeImage()!
    return Image(decorative: cg, scale: 1, orientation: .up)
}()

/// Whisper of grain. Drop on top of any screen; never intercepts touches.
/// ~2% total: just enough to kill digital-flat banding, not a visible texture.
struct GrainOverlay: View {
    var body: some View {
        ZStack {
            grainTile.resizable(resizingMode: .tile).opacity(0.02)
            grainTile.resizable(resizingMode: .tile).scaleEffect(1.7).opacity(0.01)
        }
        .blendMode(.screen)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - The develop cascade

/// The card does not pop in, it develops (docs/08). Each element starts faint and a few points low
/// and settles up with a heavy ease-out, staggered ~120ms by `index`. Driven by a `trigger` token
/// that bumps once per fresh load, so it plays on first open and pull-to-refresh and NEVER on a tab
/// return (on return the element is simply already in place).
struct CascadeIn: ViewModifier {
    let index: Int
    let trigger: Int
    @State private var shown = false
    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 12)
            .onAppear { if trigger > 0 { shown = true } }      // already developed on tab return
            .onChange(of: trigger) { _, _ in replay() }
    }
    private func replay() {
        shown = false // snap to hidden this frame (no ambient animation around the trigger bump)
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.6).delay(Double(index) * 0.12)) { shown = true }
        }
    }
}

/// The moon settles first, before the text cascades. A slow fade with the faintest scale, no slide.
struct MoonSettle: ViewModifier {
    let trigger: Int
    @State private var shown = false
    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .scaleEffect(shown ? 1 : 0.965)
            .onAppear { if trigger > 0 { shown = true } }
            .onChange(of: trigger) { _, _ in replay() }
    }
    private func replay() {
        shown = false
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: 0.7)) { shown = true }
        }
    }
}

extension View {
    func cascadeIn(_ index: Int, trigger: Int) -> some View {
        modifier(CascadeIn(index: index, trigger: trigger))
    }
    func moonSettle(trigger: Int) -> some View { modifier(MoonSettle(trigger: trigger)) }
}

// MARK: - Haptics

/// She touches back. Restraint is the brand: nothing on scroll, nothing repeated.
enum Haptics {
    /// The daily card finishing its arrival. A single soft landing.
    static func soft() { UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.9) }
    /// A scope switch or a placement tap. A light tick.
    static func light() { UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.7) }
    /// A reading sheet rising. A gentle confirmation, never a buzz.
    static func open() { UIImpactFeedbackGenerator(style: .soft).impactOccurred(intensity: 0.8) }
}

// MARK: - Edge vignette

/// A barely-there darkening at the frame's edges. Pulls the eye inward and makes the black read
/// deep instead of flat (docs/08). Lives inside the backdrop so it never muddies the text on top.
struct EdgeVignette: View {
    var body: some View {
        GeometryReader { geo in
            let d = max(geo.size.width, geo.size.height)
            RadialGradient(
                colors: [.clear, .clear, Theme.void.opacity(0.55)],
                center: .center,
                startRadius: d * 0.34, endRadius: d * 0.74)
        }
        .blendMode(.multiply)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Ember bloom

/// A muted burnt-orange bloom breathing behind the photography. Candlelight, never sunset.
/// v8: cut to ~half opacity; it should be felt, not seen first.
struct EmberBloom: View {
    var diameter: CGFloat = 380
    var intensity: Double = 1
    var body: some View {
        RadialGradient(
            colors: [Theme.ember.opacity(0.065 * intensity),
                     Theme.ember.opacity(0.025 * intensity),
                     Theme.ember.opacity(0)],
            center: .center, startRadius: 0, endRadius: diameter / 2)
        .frame(width: diameter, height: diameter)
        .allowsHitTesting(false)
    }
}

// MARK: - Hairline geometry

/// Hairline rule with a centered open diamond. The section/mantra separator from the mockup.
struct HairlineDivider: View {
    var width: CGFloat = 150
    var body: some View {
        HStack(spacing: 12) {
            Rectangle().fill(Theme.gold.opacity(0.45)).frame(height: 0.5)
            Rectangle().stroke(Theme.gold.opacity(0.8), lineWidth: 0.5)
                .frame(width: 4, height: 4).rotationEffect(.degrees(45))
            Rectangle().fill(Theme.gold.opacity(0.45)).frame(height: 0.5)
        }
        .frame(width: width)
    }
}

// MARK: - The moon

/// The real moon, showing tonight's REAL phase. Uses the NASA photo asset "moon-nasa" when
/// present (drag it into Assets in Xcode); until then a clearly-temporary shaded stand-in shows.
/// Per docs/03 the shipped moon MUST be real photography, never a drawn sphere.
///
/// `elongation` is the sun-moon elongation in degrees from ChartEngine (0 = new, 180 = full).
/// A soft terminator shadow is laid over the night side so the card matches the actual sky.
struct MoonView: View {
    var diameter: CGFloat
    var elongation: Double = 180 // default full (no shadow) until the engine reports tonight's value

    /// A cool cinematic edge light, moonlight catching the lit limb against the black.
    private let rim = Color(red: 0.78, green: 0.85, blue: 0.97)

    var body: some View {
        let waxing = elongation < 180
        ZStack {
            // Base: the real photo, or a temporary stand-in disc until it's added.
            Group {
                if let photo = UIImage(named: "moon-nasa") {
                    Image(uiImage: photo).resizable().scaledToFill()
                } else {
                    Circle().fill(RadialGradient(
                        colors: [Color(white: 0.80), Color(white: 0.42)],
                        center: UnitPoint(x: 0.42, y: 0.38), startRadius: 2, endRadius: diameter * 0.85))
                }
            }
            .frame(width: diameter, height: diameter)
            .clipShape(Circle())

            // Tonight's actual phase: a soft terminator shadow over the night side.
            MoonPhaseShadow(elongation: elongation)
                .fill(Theme.void.opacity(0.95))
                .blur(radius: diameter * 0.03)
                .frame(width: diameter, height: diameter)
                .clipShape(Circle())

            // Subtle cool rim light along the lit limb. Peaks on the sunward side (right when
            // waxing, left when waning) and fades toward the poles; nothing on the dark side.
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .clear, location: 0.30),
                            .init(color: rim.opacity(0.55), location: 0.5),
                            .init(color: .clear, location: 0.70),
                            .init(color: .clear, location: 1.0),
                        ]),
                        center: .center,
                        angle: .degrees(waxing ? -180 : 0)),
                    lineWidth: diameter * 0.018)
                .blur(radius: diameter * 0.01)
                .frame(width: diameter, height: diameter)
        }
        .frame(width: diameter, height: diameter)
        .allowsHitTesting(false)
    }
}

/// The night-side region of the moon for a given sun-moon elongation (degrees, 0..360).
/// The terminator is the ellipse x = cos(elongation) · √(r² − y²); waxing (elongation < 180°)
/// is lit on the right, waning on the left. Filled dark and softened to make the phase shadow.
struct MoonPhaseShadow: Shape {
    var elongation: Double

    func path(in rect: CGRect) -> Path {
        let r = min(rect.width, rect.height) / 2
        let cx = rect.midX, cy = rect.midY
        let waxing = elongation < 180
        let cosE = CGFloat(cos(elongation * .pi / 180))
        let steps = 64
        var path = Path()
        // Terminator edge, top to bottom.
        for i in 0...steps {
            let y = -r + 2 * r * CGFloat(i) / CGFloat(steps)
            let limb = sqrt(max(0, r * r - y * y))
            let tx = cosE * limb
            let x = waxing ? tx : -tx
            let point = CGPoint(x: cx + x, y: cy + y)
            i == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        // Dark limb, bottom back to top, closing the night region.
        for i in 0...steps {
            let y = r - 2 * r * CGFloat(i) / CGFloat(steps)
            let limb = sqrt(max(0, r * r - y * y))
            path.addLine(to: CGPoint(x: cx + (waxing ? -limb : limb), y: cy + y))
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Signature

/// The quiet wordmark. A signature at ~50% gold, so every screenshot is an ad without shouting.
struct Wordmark: View {
    var size: CGFloat = 11
    var body: some View {
        Text("LILITH")
            .font(Theme.display(size))
            .tracking(Theme.tracking(size, em: 0.5))
            .foregroundStyle(Theme.gold.opacity(0.5))
    }
}

// MARK: - Stars

/// Deterministic RNG so the star field is generated once and never reshuffles between frames.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed != 0 ? seed : 0x9E3779B97F4A7C15 }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        var x = state
        x ^= x >> 33; x = x &* 0xff51afd7ed558ccd; x ^= x >> 33
        return x
    }
}

/// A deep field of stars across the whole screen: mostly faint dust, a few brighter ones with a
/// soft glow, a touch of gold. Outer space without the purple cliché. The bright hero stars drift
/// in opacity on slow, independent 6 to 12 second cycles, so the sky feels faintly alive, never
/// twinkly (docs/08). Geometry is generated once and cached; only opacity moves per frame.
struct StarField: View {
    var count: Int = 160
    var live: Bool = true

    private struct Star {
        let x, y, r, opacity, phase, cycle: Double
        let isGold, isBright: Bool
    }
    private let stars: [Star]

    init(count: Int = 160, live: Bool = true) {
        self.count = count
        self.live = live
        var rng = SeededGenerator(seed: 0xA11CE5)
        var out: [Star] = []
        out.reserveCapacity(count)
        for _ in 0..<count {
            let x = Double.random(in: 0...1, using: &rng)
            let y = Double.random(in: 0...1, using: &rng)
            let base = Double.random(in: 0.3...1.2, using: &rng)
            let opacity = Double.random(in: 0.12...0.55, using: &rng)
            let isGold = Double.random(in: 0...1, using: &rng) < 0.12
            let isBright = Double.random(in: 0...1, using: &rng) < 0.07
            let phase = Double.random(in: 0...(2 * .pi), using: &rng)
            let cycle = Double.random(in: 6...12, using: &rng)
            out.append(Star(x: x, y: y, r: isBright ? base * 1.9 : base,
                            opacity: opacity, phase: phase, cycle: cycle,
                            isGold: isGold, isBright: isBright))
        }
        stars = out
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: !live)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                for s in stars {
                    let x = s.x * size.width, y = s.y * size.height
                    var op = s.opacity
                    if s.isBright && live { // subliminal breathing, only the hero stars move
                        op = max(0.05, op + sin(t * (2 * .pi / s.cycle) + s.phase) * 0.16)
                    }
                    let color = s.isGold ? Theme.gold : Theme.bone
                    let r = s.r
                    if s.isBright { // soft halo for depth
                        let halo = CGRect(x: x - r * 3.5, y: y - r * 3.5, width: r * 7, height: r * 7)
                        ctx.fill(Path(ellipseIn: halo), with: .color(color.opacity(op * 0.16)))
                    }
                    let dot = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                    ctx.fill(Path(ellipseIn: dot),
                             with: .color(color.opacity(s.isBright ? min(0.85, op + 0.3) : op)))
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Scaffolding

/// Near-black void + a deep star field + a single ember bloom + the edge vignette. The shared
/// stage for every screen. The bloom slowly swells and dims on an 8 second loop (felt, not seen),
/// and an optional `parallax` offset lets the whole sky drift a few points slower than the content
/// that scrolls in front of it, for depth without gimmick.
struct CosmicBackdrop: View {
    var bloomAlignment: Alignment = .top
    var bloomOffset: CGFloat = 40
    var bloomDiameter: CGFloat = 380
    var bloomIntensity: Double = 1
    var parallax: CGFloat = 0
    var alive: Bool = true

    var body: some View {
        ZStack {
            Theme.void
            StarField(live: alive)
                .offset(y: parallax)
            TimelineView(.animation(minimumInterval: 1.0 / 20.0, paused: !alive)) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate
                let pulse = alive ? 1.0 + sin(t * (2 * .pi / 8.0)) * 0.10 : 1.0
                EmberBloom(diameter: bloomDiameter, intensity: bloomIntensity * pulse)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: bloomAlignment)
                    .offset(y: (bloomAlignment == .top ? bloomOffset : 0) + parallax * 1.4)
            }
            EdgeVignette()
        }
        .ignoresSafeArea()
    }
}

extension View {
    /// Lay any screen on the cosmic stage and finish it with grain on top. `parallax` drifts the
    /// sky behind scrolling content; `alive` toggles the breathing bloom and living stars.
    func cosmicScreen(bloomAlignment: Alignment = .center,
                      bloomIntensity: Double = 0.7,
                      parallax: CGFloat = 0,
                      alive: Bool = true) -> some View {
        self
            .background(CosmicBackdrop(bloomAlignment: bloomAlignment,
                                       bloomIntensity: bloomIntensity,
                                       parallax: parallax, alive: alive))
            .overlay(GrainOverlay())
    }
}

extension Text {
    /// A letterspaced serif display headline. The celestial editorial register, in one call.
    func displayCaps(_ size: CGFloat, em: CGFloat = 0.15, color: Color = Theme.bone) -> some View {
        self.font(Theme.display(size).weight(.medium))
            .tracking(Theme.tracking(size, em: em))
            .foregroundStyle(color)
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
