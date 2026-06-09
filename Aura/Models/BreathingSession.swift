import Foundation
import SwiftData

/// A completed (or meaningfully long) breathing session, persisted with SwiftData.
@Model
final class BreathingSession {
    var endedAt: Date
    var seconds: Double
    var patternID: String
    var patternName: String

    init(endedAt: Date, seconds: Double, patternID: String, patternName: String) {
        self.endedAt = endedAt
        self.seconds = seconds
        self.patternID = patternID
        self.patternName = patternName
    }

    /// Lightweight value projection used by the (UI-free) stats layer.
    var record: SessionRecord { SessionRecord(endedAt: endedAt, seconds: seconds) }
}

/// Pure value type the stats functions operate on, so they can be unit-tested
/// without a SwiftData container.
struct SessionRecord: Equatable, Sendable {
    let endedAt: Date
    let seconds: Double
}
