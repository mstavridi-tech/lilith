import SwiftUI

/// Her actual birth chart, drawn as a wheel from real data: the sign ring, whole-sign house
/// cusps, planet glyphs at their true degrees, and the aspect lines webbing the center.
///
/// This is the one place docs/03's restraint rule sends fine-line geometry: here the gold
/// hairlines ARE the data, not decoration. Ascendant sits at the left (9 o'clock) and the
/// zodiac runs counterclockwise, the standard chart orientation. With no birth time we anchor
/// 0° Aries at the left and omit the house ring (there are no houses without a time).
///
/// On first open per session the wheel assembles like an instrument (docs/08): the gold ring draws
/// itself in, then the spokes, then the glyphs and the aspect web fade on. After that it's static.
struct ChartWheel: View {
    let chart: NatalChart

    @State private var appearDate = Date()
    @State private var done = false
    private let drawDuration: Double = 1.15

    /// Longitude pinned to the left of the wheel: the ascendant, or 0° Aries if time unknown.
    private var anchor: Double { chart.ascendant ?? 0 }
    private var hasHouses: Bool { chart.houseCusps != nil }

    var body: some View {
        TimelineView(.animation(paused: done)) { timeline in
            Canvas { ctx, size in
                draw(ctx, size, progress: progress(at: timeline.date))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .task {
            appearDate = Date()
            try? await Task.sleep(nanoseconds: UInt64((drawDuration + 0.15) * 1_000_000_000))
            done = true // freeze the wheel fully drawn; stop the timeline
        }
    }

    private func progress(at date: Date) -> CGFloat {
        if done { return 1 }
        return clamp(CGFloat(date.timeIntervalSince(appearDate) / drawDuration))
    }

    private func clamp(_ v: CGFloat, _ lo: CGFloat = 0, _ hi: CGFloat = 1) -> CGFloat {
        min(hi, max(lo, v))
    }

    private func draw(_ ctx: GraphicsContext, _ size: CGSize, progress p: CGFloat) {
        let side = min(size.width, size.height)
        let c = CGPoint(x: size.width / 2, y: size.height / 2)
        let maxR = side / 2 - 1

        let signOuter = maxR
        let signInner = maxR * 0.80
        let houseNumR = maxR * 0.72
        let planetRing = maxR * 0.60
        let aspectR = maxR * 0.50

        // Staggered draw-in fractions: ring, then spokes, then glyphs / aspects.
        let ring1 = clamp(p / 0.40)
        let ring2 = clamp((p - 0.06) / 0.40)
        let ring3 = clamp((p - 0.12) / 0.40)
        let spokeP = clamp((p - 0.34) / 0.30)
        let contentP = clamp((p - 0.58) / 0.42)

        // Longitude → screen point. a is radians counterclockwise from the anchor (left).
        func point(_ lon: Double, _ r: CGFloat) -> CGPoint {
            let a = (lon - anchor) * .pi / 180
            let theta = Double.pi + a // screen-math angle (0 = right), CCW positive
            return CGPoint(x: c.x + r * CGFloat(cos(theta)),
                           y: c.y - r * CGFloat(sin(theta)))
        }
        func stroke(_ g: GraphicsContext, _ path: Path, _ color: Color, _ w: CGFloat) {
            g.stroke(path, with: .color(color), lineWidth: w)
        }
        func glyph(_ g: GraphicsContext, _ s: String, at pt: CGPoint, font: Font, color: Color) {
            g.draw(Text(s).font(font).foregroundColor(color), at: pt, anchor: .center)
        }
        // A ring that draws itself in: an arc from the top, swept to `frac` of full circle.
        func ringArc(_ r: CGFloat, _ color: Color, _ w: CGFloat, _ frac: CGFloat) {
            guard frac > 0.001 else { return }
            var path = Path()
            path.addArc(center: c, radius: r, startAngle: .degrees(-90),
                        endAngle: .degrees(-90 + 360 * Double(frac)), clockwise: false)
            stroke(ctx, path, color, w)
        }

        // 1) Rings draw in.
        ringArc(signOuter, Theme.gold.opacity(0.55), 0.75, ring1)
        ringArc(signInner, Theme.gold.opacity(0.45), 0.5, ring2)
        ringArc(aspectR, Theme.gold.opacity(0.22), 0.5, ring3)

        // 2) Spokes fade in.
        if spokeP > 0.001 {
            var g = ctx; g.opacity = Double(spokeP)
            for s in 0..<12 {
                let boundary = Double(s) * 30
                var spoke = Path()
                spoke.move(to: point(boundary, signInner))
                spoke.addLine(to: point(boundary, signOuter))
                stroke(g, spoke, Theme.gold.opacity(0.30), 0.5)
            }
        }

        // 3) Glyphs, house numbers, the angles, the aspect web, and the planets fade on last.
        guard contentP > 0.001 else { return }
        var g = ctx; g.opacity = Double(contentP)

        for s in 0..<12 {
            let boundary = Double(s) * 30
            let sign = ZodiacSign(rawValue: s)!
            glyph(g, sign.glyph, at: point(boundary + 15, (signOuter + signInner) / 2),
                  font: Theme.body(15), color: Theme.gold.opacity(0.9))
        }

        if let cusps = chart.houseCusps {
            for (i, cusp) in cusps.enumerated() {
                glyph(g, "\(i + 1)", at: point(cusp + 15, houseNumR),
                      font: Theme.mono(9), color: Theme.bone.opacity(0.35))
            }
        }

        if hasHouses {
            var ascLine = Path()
            ascLine.move(to: point(anchor, aspectR))
            ascLine.addLine(to: point(anchor, signOuter))
            stroke(g, ascLine, Theme.ember.opacity(0.7), 1)
            glyph(g, "ASC", at: point(anchor, signInner * 0.90),
                  font: Theme.mono(8), color: Theme.ember.opacity(0.9))
        }

        let lonOf = Dictionary(uniqueKeysWithValues: chart.placements.map { ($0.body, $0.longitude) })
        for aspect in chart.aspects {
            guard let la = lonOf[aspect.a], let lb = lonOf[aspect.b] else { continue }
            var line = Path()
            line.move(to: point(la, aspectR))
            line.addLine(to: point(lb, aspectR))
            let (color, w) = aspectStyle(aspect.type)
            stroke(g, line, color, w)
        }

        for placement in chart.placements {
            var tick = Path()
            tick.move(to: point(placement.longitude, signInner))
            tick.addLine(to: point(placement.longitude, signInner * 0.94))
            stroke(g, tick, Theme.gold.opacity(0.5), 0.5)

            let isLilith = placement.body == .blackMoonLilith
            glyph(g, placement.body.glyph, at: point(placement.longitude, planetRing),
                  font: Theme.display(16), color: isLilith ? Theme.ember : Theme.bone.opacity(0.92))
        }
    }

    /// Hard aspects glow ember, flowing aspects sit in gold, conjunctions whisper.
    private func aspectStyle(_ type: AspectType) -> (Color, CGFloat) {
        switch type {
        case .square, .opposition: (Theme.ember.opacity(0.45), 0.6)
        case .trine, .sextile: (Theme.gold.opacity(0.45), 0.6)
        case .conjunction: (Theme.gold.opacity(0.28), 0.5)
        }
    }
}
