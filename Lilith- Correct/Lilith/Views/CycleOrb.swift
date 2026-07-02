import SwiftUI

/// The cycle as a living aura, not a corporate ring (Maria's brief, June 2026). A dark orb glowing
/// with phase-tinted light, soft concentric hairlines, a dotted outer track carrying colored phase
/// arcs, and a single glowing marker at exactly the day she's on. The aura leans toward the colour
/// of her current phase, so the whole orb feels like it's in her phase, not just labeled with it.
struct CycleOrb: View {
    let state: CycleState?
    var expectingDays: Int? = nil
    var size: CGFloat = 320

    private var length: Int { state?.cycleLength ?? 28 }
    private var dayFraction: Double {
        guard let state else { return 0 }
        return min(1, max(0, Double(state.cycleDay - 1) / Double(max(1, length))))
    }
    private var ranges: [CycleMath.PhaseSpan] {
        CycleMath.phaseRanges(length: length,
                              periodLength: state?.periodLength ?? CycleMath.defaultPeriodLength)
    }

    private var orbD: CGFloat { size * 0.86 }
    private var ringD: CGFloat { size * 0.985 }
    private var arcR: CGFloat { orbD / 2 * 0.97 }

    var body: some View {
        ZStack {
            base
            aura.clipShape(Circle()).frame(width: orbD, height: orbD)
            hairlines
            phaseArcs            // the rainbow ring: always on, it's the phase legend
            dottedTrack
            if state != nil { marker }
            center
        }
        .frame(width: size, height: size)
        .overlay(GrainOverlay().clipShape(Circle()).frame(width: orbD, height: orbD))
    }

    // The dark sphere.
    private var base: some View {
        Circle()
            .fill(RadialGradient(
                colors: [Color(white: 0.10), Theme.void, Color.black],
                center: UnitPoint(x: 0.42, y: 0.36), startRadius: 2, endRadius: orbD * 0.7))
            .frame(width: orbD, height: orbD)
            .overlay(Circle().strokeBorder(Theme.bone.opacity(0.06), lineWidth: 0.5)
                .frame(width: orbD, height: orbD))
    }

    // Phase-tinted light blooming inside the orb, each phase glowing at its position on the wheel,
    // the current phase brightest. This is the "aura".
    private var aura: some View {
        ZStack {
            if state != nil {
                // tracking: each phase glows at its place on the wheel, current one brightest
                ForEach(ranges) { item in
                    let mid = midFraction(item.range)
                    let isNow = item.phase == state?.phase
                    Circle()
                        .fill(item.phase.aura)
                        .frame(width: orbD * (isNow ? 0.78 : 0.6),
                               height: orbD * (isNow ? 0.78 : 0.6))
                        .offset(offset(fraction: mid, radius: orbD * 0.2))
                        .opacity(isNow ? 0.55 : 0.26)
                        .blur(radius: orbD * 0.14)
                }
            } else {
                // not tracking yet: a calm, centered glow so the orb reads balanced, not busy
                Circle().fill(Theme.ember).frame(width: orbD * 0.62, height: orbD * 0.62)
                    .opacity(0.14).blur(radius: orbD * 0.15)
                Circle().fill(Theme.gold).frame(width: orbD * 0.42, height: orbD * 0.42)
                    .opacity(0.10).blur(radius: orbD * 0.12)
            }
            // a warm core so the center never reads as a dead hole
            Circle().fill((state?.phase.aura ?? Theme.ember))
                .frame(width: orbD * 0.5, height: orbD * 0.5)
                .opacity(state == nil ? 0.12 : 0.18).blur(radius: orbD * 0.13)
        }
    }

    // A couple of faint concentric rings for depth, like the inspo.
    private var hairlines: some View {
        ZStack {
            Circle().stroke(Theme.bone.opacity(0.10), lineWidth: 0.5).frame(width: orbD * 0.74, height: orbD * 0.74)
            Circle().stroke(Theme.bone.opacity(0.07), lineWidth: 0.5).frame(width: orbD * 0.5, height: orbD * 0.5)
        }
    }

    // Colored arcs around the wheel, one per phase, current phase bright.
    private var phaseArcs: some View {
        ZStack {
            ForEach(ranges) { item in
                let f1 = Double(item.range.lowerBound - 1) / Double(length)
                let f2 = Double(item.range.upperBound) / Double(length)
                let isNow = item.phase == state?.phase
                Circle()
                    .trim(from: min(1, f1), to: min(1, f2))
                    .stroke(item.phase.aura.opacity(isNow ? 0.95 : 0.4),
                            style: StrokeStyle(lineWidth: isNow ? 3.5 : 2, lineCap: .round))
                    .frame(width: arcR * 2, height: arcR * 2)
                    .rotationEffect(.degrees(-90))
            }
        }
    }

    // The dotted outer track the marker rides.
    private var dottedTrack: some View {
        Circle()
            .stroke(Theme.gold.opacity(0.35),
                    style: StrokeStyle(lineWidth: 0.75, dash: [1, 5]))
            .frame(width: ringD, height: ringD)
    }

    // The glowing "you are here" dot at her exact day.
    private var marker: some View {
        ZStack {
            Circle().fill((state?.phase.aura ?? Theme.gold)).frame(width: 18, height: 18)
                .opacity(0.5).blur(radius: 6)
            Circle().fill(Theme.bone).frame(width: 7, height: 7)
            Circle().strokeBorder((state?.phase.aura ?? Theme.gold), lineWidth: 1).frame(width: 13, height: 13)
        }
        .offset(y: -ringD / 2)
        .rotationEffect(.degrees(dayFraction * 360))
    }

    // The center read-out: tracking a current cycle, counting down to an expected one, or not yet.
    private var center: some View {
        VStack(spacing: 6) {
            if let state {
                Text("DAY")
                    .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.4))
                    .foregroundStyle(Theme.bone.opacity(0.55))
                Text("\(state.cycleDay)")
                    .font(Theme.display(64).weight(.medium))
                    .foregroundStyle(Theme.bone)
                Text(state.phase.name)
                    .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.3))
                    .foregroundStyle(state.phase.aura)
                Text(state.phase.tagline)
                    .font(Theme.body(13)).foregroundStyle(Theme.bone.opacity(0.6))
                    .italic()
            } else if let days = expectingDays {
                Text("PERIOD IN")
                    .font(Theme.mono(10)).tracking(Theme.tracking(10, em: 0.4))
                    .foregroundStyle(Theme.bone.opacity(0.55))
                Text("\(days)")
                    .font(Theme.display(64).weight(.medium))
                    .foregroundStyle(Theme.bone)
                Text(days == 1 ? "DAY" : "DAYS")
                    .font(Theme.mono(12)).tracking(Theme.tracking(12, em: 0.3))
                    .foregroundStyle(Theme.blood)
                Text("expected, from what you logged")
                    .font(Theme.body(12)).foregroundStyle(Theme.bone.opacity(0.55))
                    .italic()
            } else {
                Text("NOT TRACKING")
                    .font(Theme.mono(11)).tracking(Theme.tracking(11, em: 0.3))
                    .foregroundStyle(Theme.bone.opacity(0.55))
                Text("yet")
                    .font(Theme.display(40).weight(.medium))
                    .foregroundStyle(Theme.bone.opacity(0.8))
                    .italic()
                Text("log a period to begin")
                    .font(Theme.body(13)).foregroundStyle(Theme.gold.opacity(0.7))
            }
        }
    }

    // MARK: helpers

    private func midFraction(_ range: ClosedRange<Int>) -> Double {
        let mid = Double(range.lowerBound + range.upperBound) / 2 - 0.5
        return min(1, max(0, mid / Double(length)))
    }

    /// A point at `fraction` around the wheel (0 = top, clockwise), `radius` out from center.
    private func offset(fraction: Double, radius: CGFloat) -> CGSize {
        let angle = (fraction * 360 - 90) * .pi / 180
        return CGSize(width: cos(angle) * radius, height: sin(angle) * radius)
    }
}
