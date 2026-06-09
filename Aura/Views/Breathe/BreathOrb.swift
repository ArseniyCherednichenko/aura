import SwiftUI

/// The breathing orb: a session-progress ring around a soft gradient sphere that
/// scales with the breath. `scale` is animated by the parent so the growth/shrink
/// matches each phase's duration.
struct BreathOrb: View {
    var scale: CGFloat
    var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 5)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Theme.orbGradient, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Circle()
                .fill(Theme.orbGradient)
                .opacity(0.92)
                .scaleEffect(scale)
                .shadow(color: Theme.orbTop.opacity(0.45), radius: 35)
                .padding(30)
        }
    }
}
