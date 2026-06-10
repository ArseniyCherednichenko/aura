import XCTest
@testable import Aura

final class PatternTests: XCTestCase {
    func testLibraryNotEmpty() {
        XCTAssertFalse(BreathPattern.library.isEmpty)
    }

    func testEveryPatternIsUsable() {
        for pattern in BreathPattern.library {
            XCTAssertFalse(pattern.steps.isEmpty, "\(pattern.id) has no steps")
            XCTAssertGreaterThan(pattern.cycleDuration, 0, "\(pattern.id) has no positive-duration steps")
            XCTAssertFalse(pattern.name.isEmpty)
        }
    }

    func testPatternIDsAreUnique() {
        let ids = BreathPattern.library.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count)
    }

    func testLookupFallsBackToFirst() {
        XCTAssertEqual(BreathPattern.pattern(id: "does-not-exist").id, BreathPattern.library[0].id)
        XCTAssertEqual(BreathPattern.pattern(id: "coherent").id, "coherent")
    }

    func testCycleDurationIgnoresZeroSteps() {
        let pattern = BreathPattern(id: "z", name: "Z", subtitle: "", steps: [
            BreathStep(phase: .inhale, seconds: 4),
            BreathStep(phase: .holdIn, seconds: 0),
            BreathStep(phase: .exhale, seconds: 4),
        ])
        XCTAssertEqual(pattern.cycleDuration, 8, accuracy: 0.0001)
    }
}
