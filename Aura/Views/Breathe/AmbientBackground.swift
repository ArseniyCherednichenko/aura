import SwiftUI

/// Deep gradient base with two slowly drifting, blurred colour blobs. The tint
/// shifts with the active breath phase. Honours Reduce Motion (blobs hold still).
struct AmbientBackground: View {
    var tint: Color
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drift = false

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            Circle()
                .fill(tint.opacity(0.32))
                .frame(width: 340, height: 340)
                .blur(radius: 90)
                .offset(x: drift ? -70 : -30, y: drift ? -200 : -150)

            Circle()
                .fill(Theme.orbBottom.opacity(0.28))
                .frame(width: 380, height: 380)
                .blur(radius: 100)
                .offset(x: drift ? 90 : 50, y: drift ? 230 : 170)
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.2), value: tint)
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
    }
}
