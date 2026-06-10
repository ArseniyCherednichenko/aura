import SwiftUI

/// A living mesh-gradient aurora. The control points drift on a sine field so the
/// whole colour wash slowly breathes, and the palette shifts with the active
/// breath phase. Falls back to a still mesh under Reduce Motion.
struct AuroraMesh: View {
    var phase: BreathPhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Color.black

            if reduceMotion {
                mesh(points: Self.basePoints)
            } else {
                TimelineView(.animation) { context in
                    let t = context.date.timeIntervalSinceReferenceDate
                    mesh(points: wavyPoints(t))
                }
            }

            // Vignette so foreground text stays legible over the bright mesh.
            RadialGradient(colors: [.clear, .black.opacity(0.55)], center: .center, startRadius: 110, endRadius: 540)
                .blendMode(.multiply)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.4), value: phase)
    }

    private func mesh(points: [SIMD2<Float>]) -> some View {
        MeshGradient(width: 3, height: 3, points: points, colors: colors)
    }

    private var colors: [Color] {
        let accent = Theme.phaseTint(phase)
        let low = Theme.orbBottom
        let deep = Theme.bgTop
        return [
            deep, accent.opacity(0.85), deep,
            low.opacity(0.75), accent, low.opacity(0.8),
            deep, low.opacity(0.7), deep,
        ]
    }

    static let basePoints: [SIMD2<Float>] = [
        SIMD2(0, 0), SIMD2(0.5, 0), SIMD2(1, 0),
        SIMD2(0, 0.5), SIMD2(0.5, 0.5), SIMD2(1, 0.5),
        SIMD2(0, 1), SIMD2(0.5, 1), SIMD2(1, 1),
    ]

    private func wavyPoints(_ t: Double) -> [SIMD2<Float>] {
        func wob(_ base: Float, _ amp: Float, _ speed: Double, _ offset: Double) -> Float {
            base + amp * Float(sin(t * speed + offset))
        }
        return [
            SIMD2(0, 0), SIMD2(wob(0.5, 0.08, 0.7, 0), 0), SIMD2(1, 0),
            SIMD2(0, wob(0.5, 0.08, 0.6, 1)),
            SIMD2(wob(0.5, 0.10, 0.5, 2), wob(0.5, 0.10, 0.4, 0)),
            SIMD2(1, wob(0.5, 0.08, 0.55, 3)),
            SIMD2(0, 1), SIMD2(wob(0.5, 0.08, 0.65, 1.5), 1), SIMD2(1, 1),
        ]
    }
}
