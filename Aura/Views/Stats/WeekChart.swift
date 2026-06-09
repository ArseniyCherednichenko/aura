import SwiftUI
import Charts

/// Bar chart of breathing minutes over the last seven days.
struct WeekChart: View {
    let days: [DayStat]

    var body: some View {
        Chart(days) { day in
            BarMark(
                x: .value("Day", day.date, unit: .day),
                y: .value("Minutes", day.minutes)
            )
            .foregroundStyle(Theme.orbGradient)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.weekday(.narrow))
                    .foregroundStyle(.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 180)
    }
}
