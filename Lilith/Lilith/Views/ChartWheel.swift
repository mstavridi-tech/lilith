import SwiftUI

/// Her actual birth chart, drawn as a wheel from real data: the sign ring, whole-sign house
/// cusps, planet glyphs at their true degrees, and the aspect lines webbing the center.
///
/// This is the one place docs/03's restraint rule sends fine-line geometry: here the gold
/// hairlines ARE the data, not decoration. Ascendant sits at the left (9 o'clock) and the
/// zodiac runs counterclockwise, the standard chart orientation. With no birth time we anchor
/// 0° Aries at the left and omit the house ring (there are no houses without a time).
struct ChartWheel: View {
    let chart: NatalChart

    /// Longitude pinned to the left of the wheel: the ascendant, or 0° Aries if time unknown.
    private var anchor: Double { chart.ascendant ?? 0 }
    private var hasHouses: Bool { chart.houseCusps != nil }

    var body: some View {
        Canvas { ctx, size in
            let side = min(size.width, size.height)
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let maxR = side / 2 - 1

            let signOuter = maxR
            let signInner = maxR * 0.80
            let houseNumR = maxR * 0.72
            let planetRing = maxR * 0.60
            let aspectR = maxR * 0.50

            // Longitude → screen point. a is radians counterclockwise from the anchor (left).
            func point(_ lon: Double, _ r: CGFloat) -> CGPoint {
                let a = (lon - anchor) * .pi / 180
                let theta = Double.pi + a // screen-math angle (0 = right), CCW positive
                return CGPoint(x: c.x + r * CGFloat(cos(theta)),
                               y: c.y - r * CGFloat(sin(theta)))
            }

            func stroke(_ path: Path, _ color: Color, _ w: CGFloat) {
                ctx.stroke(path, with: .color(color), lineWidth: w)
            }
            func ring(_ r: CGFloat, _ color: Color, _ w: CGFloat) {
                stroke(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)), color, w)
            }
            func glyph(_ s: String, at p: CGPoint, font: Font, color: Color) {
                ctx.draw(Text(s).font(font).foregroundColor(color), at: p, anchor: .center)
            }

            // Rings: outer rim, sign-band inner rim, the aspect well.
            ring(signOuter, Theme.gold.opacity(0.55), 0.75)
            ring(signInner, Theme.gold.opacity(0.45), 0.5)
            ring(aspectR, Theme.gold.opacity(0.22), 0.5)

            // Sign ring: a spoke at every 30° boundary, a glyph centered in each segment.
            for s in 0..<12 {
                let boundary = Double(s) * 30
                var spoke = Path()
                spoke.move(to: point(boundary, signInner))
                spoke.addLine(to: point(boundary, signOuter))
                stroke(spoke, Theme.gold.opacity(0.30), 0.5)

                let sign = ZodiacSign(rawValue: s)!
                glyph(sign.glyph, at: point(boundary + 15, (signOuter + signInner) / 2),
                      font: Theme.body(15), color: Theme.gold.opacity(0.9))
            }

            // Whole-sign house numbers, 1 at the rising sign, just inside the sign band.
            if let cusps = chart.houseCusps {
                for (i, cusp) in cusps.enumerated() {
                    glyph("\(i + 1)", at: point(cusp + 15, houseNumR),
                          font: Theme.mono(9), color: Theme.bone.opacity(0.35))
                }
            }

            // The angles: ascendant (and MC) get a bolder ember radial, the chart's spine.
            if hasHouses {
                var ascLine = Path()
                ascLine.move(to: point(anchor, aspectR))
                ascLine.addLine(to: point(anchor, signOuter))
                stroke(ascLine, Theme.ember.opacity(0.7), 1)
                glyph("ASC", at: point(anchor, signInner * 0.90),
                      font: Theme.mono(8), color: Theme.ember.opacity(0.9))
            }

            // Aspect web: a hairline between the two bodies for every major aspect.
            let lonOf = Dictionary(uniqueKeysWithValues: chart.placements.map { ($0.body, $0.longitude) })
            for aspect in chart.aspects {
                guard let la = lonOf[aspect.a], let lb = lonOf[aspect.b] else { continue }
                var line = Path()
                line.move(to: point(la, aspectR))
                line.addLine(to: point(lb, aspectR))
                let (color, w) = aspectStyle(aspect.type)
                stroke(line, color, w)
            }

            // Planet glyphs at their true degree, with a tick pointing to the exact longitude.
            for p in chart.placements {
                var tick = Path()
                tick.move(to: point(p.longitude, signInner))
                tick.addLine(to: point(p.longitude, signInner * 0.94))
                stroke(tick, Theme.gold.opacity(0.5), 0.5)

                let isLilith = p.body == .blackMoonLilith
                glyph(p.body.glyph, at: point(p.longitude, planetRing),
                      font: Theme.display(16), color: isLilith ? Theme.ember : Theme.bone.opacity(0.92))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
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
