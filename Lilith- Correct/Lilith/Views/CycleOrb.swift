import SwiftUI

/// v11 (Maria, "more health, less astrology" — the actual shape had to change, not just dim). Gone:
/// the 3D shaded sphere, the concentric hairlines, the dotted track, the orbiting marker dot. All of
/// that was the astrology-instrument silhouette no matter how quiet the color got underneath it.
/// In its place: an Oura-style ring. Flat black center, a thin full-cycle track always visible at
/// low opacity so the whole cycle is legible at a glance, and one bold gradient arc filling in to
/// today, phase color banded straight into the stroke. The day number sits in the empty center,
/// exactly like a readiness score, because that reads as health data and a glowing planet doesn't.
struct CycleOrb: View {
    let state: CycleState?
    var expectingDays: Int? = nil
    var size: CGFloat = 320

    private var length: Int { state?.cycleLength ?? 28 }
    private var dayFraction: Double {
        guard let state else { return 0 }
        return min(1, max(0, Double(state.cycleDay) / Double(max(1, length))))
    }
    private var ranges: [CycleMath.PhaseSpan] {
        CycleMath.phaseRanges(length: length,
                              periodLength: state?.periodLength ?? CycleMath.defaultPeriodLength)
    }

    private let ringWidth: CGFloat = 16
    private var ringD: CGFloat { size * 0.82 }

    var body: some View {
        ZStack {
            track
            if state != nil { progressArc }
            center
        }
        .frame(width: size, height: size)
    }

    // The full cycle mapped in phase color, always visible but quiet: context before progress.
    private var track: some View {
        Circle()
            .stroke(phaseGradient, style: StrokeStyle(lineWidth: ringWidth, lineCap: .butt))
            .frame(width: ringD, height: ringD)
            .opacity(0.16)
            .rotationEffect(.degrees(-90))
    }

    // The bold fill to today. Rounded cap doubles as the "you are here" marker, no separate dot.
    private var progressArc: some View {
        Circle()
            .trim(from: 0, to: max(0.008, dayFraction))
            .stroke(phaseGradient, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
            .frame(width: ringD, height: ringD)
            .rotationEffect(.degrees(-90))
            .shadow(color: (state?.phase.aura ?? Theme.gold).opacity(0.4), radius: 10)
    }

    // Hard-edged phase bands around the circle, in order, no blur, no blend between them.
    private var phaseGradient: AngularGradient {
        var stops: [Gradient.Stop] = []
        for item in ranges {
            let f1 = min(1, max(0, Double(item.range.lowerBound - 1) / Double(length)))
            let f2 = min(1, max(0, Double(item.range.upperBound) / Double(length)))
            stops.append(.init(color: item.phase.aura, location: f1))
            stops.append(.init(color: item.phase.aura, location: f2))
        }
        if stops.isEmpty { stops = [.init(color: Theme.gold, location: 0), .init(color: Theme.gold, location: 1)] }
        return AngularGradient(gradient: Gradient(stops: stops), center: .center)
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
}
