import XCTest
@testable import Aura

final class StreakTests: XCTestCase {
    private let cal = Calendar(identifier: .gregorian)

    private func day(_ y: Int, _ m: Int, _ d: Int) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: d))!
    }

    func testNoSessions() {
        XCTAssertEqual(Streak.current(sessionDays: [], today: day(2026, 6, 10), calendar: cal), 0)
    }

    func testTodayOnly() {
        XCTAssertEqual(Streak.current(sessionDays: [day(2026, 6, 10)], today: day(2026, 6, 10), calendar: cal), 1)
    }

    func testConsecutiveEndingToday() {
        let days: Set<Date> = [day(2026, 6, 8), day(2026, 6, 9), day(2026, 6, 10)]
        XCTAssertEqual(Streak.current(sessionDays: days, today: day(2026, 6, 10), calendar: cal), 3)
    }

    func testCountsFromYesterdayWhenNoneToday() {
        let days: Set<Date> = [day(2026, 6, 8), day(2026, 6, 9)]
        XCTAssertEqual(Streak.current(sessionDays: days, today: day(2026, 6, 10), calendar: cal), 2)
    }

    func testBreaksOnGap() {
        let days: Set<Date> = [day(2026, 6, 6), day(2026, 6, 9), day(2026, 6, 10)]
        XCTAssertEqual(Streak.current(sessionDays: days, today: day(2026, 6, 10), calendar: cal), 2)
    }

    func testStaleStreakIsZero() {
        let days: Set<Date> = [day(2026, 6, 1), day(2026, 6, 2)]
        XCTAssertEqual(Streak.current(sessionDays: days, today: day(2026, 6, 10), calendar: cal), 0)
    }
}
