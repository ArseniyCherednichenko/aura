import SwiftUI

/// Central colour + gradient language. Calm, deep, with a teal-to-violet orb.
enum Theme {
    static let accent = Color(red: 0.55, green: 0.80, blue: 0.96)

    static let orbTop = Color(red: 0.40, green: 0.86, blue: 0.86)
    static let orbBottom = Color(red: 0.56, green: 0.51, blue: 0.96)

    static let bgTop = Color(red: 0.06, green: 0.07, blue: 0.13)
    static let bgBottom = Color(red: 0.02, green: 0.03, blue: 0.06)

    static var orbGradient: LinearGradient {
        LinearGradient(colors: [orbTop, orbBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [bgTop, bgBottom], startPoint: .top, endPoint: .bottom)
    }

    /// A subtly different ambient tint per phase, used behind the orb.
    static func phaseTint(_ phase: BreathPhase) -> Color {
        switch phase {
        case .inhale: return orbTop
        case .holdIn: return Color(red: 0.45, green: 0.72, blue: 0.95)
        case .exhale: return orbBottom
        case .holdOut: return Color(red: 0.50, green: 0.58, blue: 0.92)
        }
    }
}
