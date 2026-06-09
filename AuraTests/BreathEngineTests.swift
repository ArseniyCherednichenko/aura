import XCTest
@testable import Aura

final class BreathEngineTests: XCTestCase {
    private func box() -> BreathPattern { BreathPattern.pattern(id: "box") }

    func testStartsOnInhale() {
        let engine = BreathEngine(pattern: box(), sessionLength: 60)
        XCTAssertEqual(engine.phase, .inhale)
        XCTAssertEqual(engine.progress, 0)
        XCTAssertFalse(engine.isComplete)
    }

    func testAdvancesThroughPhasesAndWraps() {
        let engine = BreathEngine(pattern: box(), sessionLength: 60)
        engine.tick(4)
        XCTAssertEqual(engine.phase, .holdIn)
        XCTAssertEqual(engine.transitions, 1)
        engine.tick(4)
        XCTAssertEqual(engine.phase, .exhale)
        engine.tick(4)
        XCTAssertEqual(engine.phase, .holdOut)
        engine.tick(4)
        XCTAssertEqual(engine.phase, .inhale) // wrapped to next cycle
        XCTAssertEqual(engine.transitions, 4)
    }

    func testPartialTickKeepsPhase() {
        let engine = BreathEngine(pattern: box(), sessionLength: 60)
        engine.tick(2)
        XCTAssertEqual(engine.phase, .inhale)
        XCTAssertEqual(engine.phaseRemaining, 2, accuracy: 0.0001)
        XCTAssertEqual(engine.phaseProgress, 0.5, accuracy: 0.0001)
    }

    func testCompletesAtSessionLength() {
        let engine = BreathEngine(pattern: box(), sessionLength: 10)
        engine.tick(10)
        XCTAssertTrue(engine.isComplete)
        XCTAssertEqual(engine.progress, 1, accuracy: 0.0001)
        XCTAssertEqual(engine.remaining, 0, accuracy: 0.0001)
    }

    func testTickIgnoredAfterComplete() {
        let engine = BreathEngine(pattern: box(), sessionLength: 5)
        engine.tick(5)
        let phaseAfter = engine.phase
        let transitionsAfter = engine.transitions
        engine.tick(5)
        XCTAssertTrue(engine.isComplete)
        XCTAssertEqual(engine.phase, phaseAfter)
        XCTAssertEqual(engine.transitions, transitionsAfter)
    }

    func testBigDeltaSpansMultiplePhases() {
        let engine = BreathEngine(pattern: box(), sessionLength: 60)
        engine.tick(9) // 4 inhale + 4 hold + 1 into exhale
        XCTAssertEqual(engine.phase, .exhale)
        XCTAssertEqual(engine.transitions, 2)
        XCTAssertEqual(engine.phaseElapsed, 1, accuracy: 0.0001)
    }

    func testZeroSecondStepsAreFiltered() {
        let pattern = BreathPattern(id: "t", name: "t", subtitle: "", steps: [
            BreathStep(phase: .inhale, seconds: 3),
            BreathStep(phase: .holdIn, seconds: 0),
            BreathStep(phase: .exhale, seconds: 3),
        ])
        let engine = BreathEngine(pattern: pattern, sessionLength: 60)
        engine.tick(3)
        XCTAssertEqual(engine.phase, .exhale) // skipped the zero-second hold
        XCTAssertEqual(engine.transitions, 1)
    }

    func testReset() {
        let engine = BreathEngine(pattern: box(), sessionLength: 30)
        engine.tick(12)
        engine.reset()
        XCTAssertEqual(engine.phase, .inhale)
        XCTAssertEqual(engine.totalElapsed, 0)
        XCTAssertEqual(engine.transitions, 0)
        XCTAssertFalse(engine.isComplete)
    }
}
