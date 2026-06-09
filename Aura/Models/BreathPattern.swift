import Foundation

/// One phase of a breath cycle.
enum BreathPhase: String, CaseIterable, Codable, Sendable {
    case inhale
    case holdIn
    case exhale
    case holdOut

    /// Short instruction shown at the centre of the orb.
    var verb: String {
        switch self {
        case .inhale: return "Breathe in"
        case .holdIn: return "Hold"
        case .exhale: return "Breathe out"
        case .holdOut: return "Hold"
        }
    }

    /// Target scale of the breathing orb while this phase is active.
    /// Inhale grows the orb, exhale shrinks it, holds keep the prior size.
    var targetScale: Double {
        switch self {
        case .inhale, .holdIn: return 1.0
        case .exhale, .holdOut: return 0.55
        }
    }
}

/// A phase with a concrete duration in seconds.
struct BreathStep: Equatable, Sendable {
    let phase: BreathPhase
    let seconds: Double
}

/// A named breathing technique: one cycle expressed as ordered steps.
struct BreathPattern: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let subtitle: String
    /// Steps for a single cycle. Zero-second steps are allowed in data and
    /// filtered out by the engine.
    let steps: [BreathStep]

    /// Duration of one full cycle in seconds (ignoring zero-length steps).
    var cycleDuration: Double {
        steps.filter { $0.seconds > 0 }.reduce(0) { $0 + $1.seconds }
    }

    static let library: [BreathPattern] = [
        BreathPattern(
            id: "box",
            name: "Box",
            subtitle: "Equal four-count. Steady and grounding.",
            steps: [
                BreathStep(phase: .inhale, seconds: 4),
                BreathStep(phase: .holdIn, seconds: 4),
                BreathStep(phase: .exhale, seconds: 4),
                BreathStep(phase: .holdOut, seconds: 4),
            ]
        ),
        BreathPattern(
            id: "478",
            name: "4-7-8",
            subtitle: "Long exhale. Helps you wind down.",
            steps: [
                BreathStep(phase: .inhale, seconds: 4),
                BreathStep(phase: .holdIn, seconds: 7),
                BreathStep(phase: .exhale, seconds: 8),
            ]
        ),
        BreathPattern(
            id: "calm",
            name: "Calm",
            subtitle: "Gentle, slightly longer out-breath.",
            steps: [
                BreathStep(phase: .inhale, seconds: 4),
                BreathStep(phase: .exhale, seconds: 6),
            ]
        ),
        BreathPattern(
            id: "energize",
            name: "Energize",
            subtitle: "Quick in, soft out. A morning lift.",
            steps: [
                BreathStep(phase: .inhale, seconds: 6),
                BreathStep(phase: .holdIn, seconds: 2),
                BreathStep(phase: .exhale, seconds: 2),
            ]
        ),
    ]

    static func pattern(id: String) -> BreathPattern {
        library.first { $0.id == id } ?? library[0]
    }
}
