import SwiftUI

/// The breathing orb. Layers, from back to front: a soft bloom, faint concentric
/// guide rings, the session-progress ring, and a radial-gradient sphere with an
/// off-centre highlight. `scale` is animated by the parent so the growth and
/// shrink match each breath phase.
struct BreathOrb: View {
    var scale: CGFloat
    var progress: Double

    var body: some View {
        ZStack {
            // Soft outer bloom.
            Circle()
                .fill(Theme.orbGradient)
                .blur(radius: 55)
                .opacity(0.45)
                .scaleEffect(scale * 1.06)

            // Faint concentric guide rings.
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                    .scaleEffect(0.52 + CGFloat(i) * 0.24)
            }

            // Progress track + ring.
            Circle().stroke(Color.white.opacity(0.08), lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Theme.orbGradient, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: Theme.orbTop.opacity(0.6), radius: 8)

            // The sphere.
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Theme.orbTop, Theme.orbBottom],
                        center: .topLeading,
                        startRadius: 4,
                        endRadius: 240
                    )
                )
                .overlay(
                    Circle()
                        .fill(.white.opacity(0.28))
                        .blur(radius: 16)
                        .scaleEffect(0.45)
                        .offset(x: -28, y: -32)
                )
                .clipShape(Circle())
                .scaleEffect(scale)
                .shadow(color: Theme.orbBottom.opacity(0.5), radius: 30)
                .padding(30)
        }
    }
}
