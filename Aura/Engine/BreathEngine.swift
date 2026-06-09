import Foundation
import Observation

/// Pure, deterministic breathing state machine. The view advances it with
/// `tick(_:)` on a display timer; all timing logic lives here so it can be
/// unit-tested without any UI.
@Observable
final class BreathEngine {
    let pattern: BreathPattern
    /// Total target length of the session in seconds.
    let sessionLength: Double

    /// Non-zero steps that actually run.
    private let steps: [BreathStep]

    private(set) var stepIndex: Int = 0
    private(set) var phaseElapsed: Double = 0
    private(set) var totalElapsed: Double = 0
    private(set) var isComplete: Bool = false
    /// Increments every time the active phase changes — handy for driving
    /// haptics and animations from `onChange`.
    private(set) var transitions: Int = 0

    init(pattern: BreathPattern, sessionLength: Double) {
        self.pattern = pattern
        self.sessionLength = max(0, sessionLength)
        self.steps = pattern.steps.filter { $0.seconds > 0 }
    }

    var hasSteps: Bool { !steps.isEmpty }
    var currentStep: BreathStep { steps[min(stepIndex, steps.count - 1)] }
    var phase: BreathPhase { hasSteps ? currentStep.phase : .inhale }

    /// Seconds left in the current phase (rounded up for display).
    var phaseRemaining: Double { hasSteps ? max(0, currentStep.seconds - phaseElapsed) : 0 }

    /// 0...1 progress through the current phase.
    var phaseProgress: Double {
        guard hasSteps, currentStep.seconds > 0 else { return 1 }
        return min(1, phaseElapsed / currentStep.seconds)
    }

    /// 0...1 progress through the whole session.
    var progress: Double {
        guard sessionLength > 0 else { return isComplete ? 1 : 0 }
        return min(1, totalElapsed / sessionLength)
    }

    var remaining: Double { max(0, sessionLength - totalElapsed) }

    /// Advance the engine by `delta` seconds.
    func tick(_ delta: Double) {
        guard !isComplete, hasSteps, delta > 0 else { return }
        phaseElapsed += delta
        totalElapsed += delta

        // Advance through as many phases as `delta` spans.
        while phaseElapsed >= currentStep.seconds {
            phaseElapsed -= currentStep.seconds
            stepIndex = (stepIndex + 1) % steps.count
            transitions += 1
        }

        if totalElapsed >= sessionLength {
            totalElapsed = sessionLength
            isComplete = true
        }
    }

    func reset() {
        stepIndex = 0
        phaseElapsed = 0
        totalElapsed = 0
        isComplete = false
        transitions = 0
    }
}
