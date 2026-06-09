import Foundation

/// Per-day rollup for the stats screen.
struct DayStat: Identifiable, Equatable {
    var id: Date { date }
    let date: Date // start of day
    let minutes: Double
    let sessions: Int
}

/// Pure aggregation helpers over `SessionRecord`s. No UI, no SwiftData — all
/// deterministic and unit-tested.
enum Stats {
    static func totalMinutes(_ records: [SessionRecord]) -> Double {
        records.reduce(0) { $0 + $1.seconds } / 60
    }

    static func totalSessions(_ records: [SessionRecord]) -> Int { records.count }

    static func sessionDays(_ records: [SessionRecord], calendar: Calendar = .current) -> Set<Date> {
        Set(records.map { calendar.startOfDay(for: $0.endedAt) })
    }

    static func currentStreak(_ records: [SessionRecord], today: Date = Date(), calendar: Calendar = .current) -> Int {
        Streak.current(sessionDays: sessionDays(records, calendar: calendar), today: today, calendar: calendar)
    }

    /// `n` day-buckets ending today (oldest first), each with minutes + count.
    static func lastNDays(_ records: [SessionRecord], n: Int, today: Date = Date(), calendar: Calendar = .current) -> [DayStat] {
        let start = calendar.startOfDay(for: today)
        var byDay: [Date: (seconds: Double, count: Int)] = [:]
        for r in records {
            let day = calendar.startOfDay(for: r.endedAt)
            let cur = byDay[day] ?? (0, 0)
            byDay[day] = (cur.seconds + r.seconds, cur.count + 1)
        }
        return (0..<n).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: start) else { return nil }
            let bucket = byDay[day] ?? (0, 0)
            return DayStat(date: day, minutes: bucket.seconds / 60, sessions: bucket.count)
        }
    }
}

/// Consecutive-day streak ending today (or yesterday if nothing logged today).
enum Streak {
    static func current(sessionDays: Set<Date>, today: Date, calendar: Calendar = .current) -> Int {
        let startToday = calendar.startOfDay(for: today)
        var cursor: Date
        if sessionDays.contains(startToday) {
            cursor = startToday
        } else if let yesterday = calendar.date(byAdding: .day, value: -1, to: startToday),
                  sessionDays.contains(yesterday) {
            cursor = yesterday
        } else {
            return 0
        }

        var count = 0
        while sessionDays.contains(cursor) {
            count += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return count
    }
}
