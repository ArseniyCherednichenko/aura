import Foundation

enum Format {
    /// Seconds -> "m:ss".
    static func clock(_ seconds: Double) -> String {
        let total = max(0, Int(seconds.rounded()))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    /// Minutes -> "12 min" / "1 h 5 min".
    static func minutes(_ minutes: Double) -> String {
        let total = Int(minutes.rounded())
        if total < 60 { return "\(total) min" }
        return "\(total / 60) h \(total % 60) min"
    }

    private static let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEEE" // single-letter weekday
        return f
    }()

    static func weekdayInitial(_ date: Date) -> String {
        weekdayFormatter.string(from: date)
    }
}
