import XCTest
@testable import Aura

final class StatsTests: XCTestCase {
    private let cal = Calendar(identifier: .gregorian)

    private func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 12) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: d, hour: h))!
    }

    func testTotals() {
        let records = [
            SessionRecord(endedAt: date(2026, 6, 10), seconds: 180),
            SessionRecord(endedAt: date(2026, 6, 10), seconds: 120),
        ]
        XCTAssertEqual(Stats.totalMinutes(records), 5, accuracy: 0.0001)
        XCTAssertEqual(Stats.totalSessions(records), 2)
    }

    func testLastNDaysBucketsAndOrders() {
        let records = [
            SessionRecord(endedAt: date(2026, 6, 10), seconds: 120), // today: 2 min
            SessionRecord(endedAt: date(2026, 6, 9), seconds: 60),   // yesterday: 2 sessions
            SessionRecord(endedAt: date(2026, 6, 9), seconds: 60),
        ]
        let days = Stats.lastNDays(records, n: 7, today: date(2026, 6, 10), calendar: cal)
        XCTAssertEqual(days.count, 7)
        // Oldest first, today last.
        XCTAssertEqual(days.last?.minutes ?? -1, 2, accuracy: 0.0001)
        XCTAssertEqual(days.last?.sessions, 1)
        XCTAssertEqual(days[days.count - 2].minutes, 2, accuracy: 0.0001)
        XCTAssertEqual(days[days.count - 2].sessions, 2)
        XCTAssertEqual(days.first?.minutes ?? -1, 0, accuracy: 0.0001)
        XCTAssertEqual(days.first?.sessions, 0)
    }

    func testStreakThroughStats() {
        let records = [
            SessionRecord(endedAt: date(2026, 6, 10), seconds: 120),
            SessionRecord(endedAt: date(2026, 6, 9), seconds: 120),
        ]
        XCTAssertEqual(Stats.currentStreak(records, today: date(2026, 6, 10), calendar: cal), 2)
    }

    func testMinutesToday() {
        let records = [
            SessionRecord(endedAt: date(2026, 6, 10, 9), seconds: 120),
            SessionRecord(endedAt: date(2026, 6, 10, 20), seconds: 60),
            SessionRecord(endedAt: date(2026, 6, 9), seconds: 300), // not today
        ]
        XCTAssertEqual(Stats.minutesToday(records, today: date(2026, 6, 10), calendar: cal), 3, accuracy: 0.0001)
    }

    func testLongestStreak() {
        let records = [
            SessionRecord(endedAt: date(2026, 6, 1), seconds: 60), // run of 3
            SessionRecord(endedAt: date(2026, 6, 2), seconds: 60),
            SessionRecord(endedAt: date(2026, 6, 3), seconds: 60),
            SessionRecord(endedAt: date(2026, 6, 10), seconds: 60), // run of 2
            SessionRecord(endedAt: date(2026, 6, 11), seconds: 60),
        ]
        XCTAssertEqual(Stats.longestStreak(records, calendar: cal), 3)
    }

    func testLongestStreakEmpty() {
        XCTAssertEqual(Stats.longestStreak([], calendar: cal), 0)
    }
}
