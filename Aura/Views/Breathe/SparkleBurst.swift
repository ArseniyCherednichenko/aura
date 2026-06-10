import SwiftUI

/// A gentle one-shot burst of dots radiating outward and fading. Used on the
/// session-complete screen. Renders nothing animated under Reduce Motion.
struct SparkleBurst: View {
    var radius: CGFloat = 90
    var count: Int = 10
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var go = false

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                let angle = Double(i) / Double(count) * 2 * .pi
                Circle()
                    .fill(Theme.orbGradient)
                    .frame(width: 6, height: 6)
                    .offset(
                        x: go ? cos(angle) * radius : 0,
                        y: go ? sin(angle) * radius : 0
                    )
                    .opacity(go ? 0 : 0.9)
            }
        }
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeOut(duration: 1.1)) { go = true }
        }
    }
}
