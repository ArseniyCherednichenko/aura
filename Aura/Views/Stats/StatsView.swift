import SwiftUI
import SwiftData

struct StatsView: View {
    @Query(sort: \BreathingSession.endedAt, order: .reverse) private var sessions: [BreathingSession]

    private var records: [SessionRecord] { sessions.map(\.record) }

    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    emptyState
                } else {
                    content
                }
            }
            .navigationTitle("Stats")
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    StatCard(value: "\(Stats.currentStreak(records))",
                             label: "Day streak",
                             systemImage: "flame.fill")
                    StatCard(value: Format.minutes(Stats.totalMinutes(records)),
                             label: "Total time",
                             systemImage: "clock.fill")
                    StatCard(value: "\(Stats.totalSessions(records))",
                             label: "Sessions",
                             systemImage: "wind")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("This week")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    WeekChart(days: Stats.lastNDays(records, n: 7))
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach(sessions.prefix(8)) { session in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.patternName)
                                    .font(.subheadline.weight(.medium))
                                Text(session.endedAt.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(Format.minutes(session.seconds / 60))
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(.secondary)
                        }
                        if session.id != sessions.prefix(8).last?.id {
                            Divider().opacity(0.4)
                        }
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 46, weight: .light))
                .foregroundStyle(Theme.accent)
            Text("No sessions yet")
                .font(.title3.weight(.semibold))
            Text("Your breathing history and streak will show up here once you finish your first session.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
