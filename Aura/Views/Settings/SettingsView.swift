import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage(SettingsKey.sessionMinutes) private var sessionMinutes: Int = 3
    @AppStorage(SettingsKey.defaultPatternID) private var patternID: String = "box"
    @AppStorage(SettingsKey.haptics) private var haptics: Bool = true
    @AppStorage(SettingsKey.keepAwake) private var keepAwake: Bool = true
    @AppStorage(SettingsKey.appearance) private var appearance: Appearance = .system

    @Environment(\.modelContext) private var context
    @Query private var sessions: [BreathingSession]
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Session") {
                    Stepper("Length: \(sessionMinutes) min", value: $sessionMinutes, in: 1...30)
                    Picker("Default pattern", selection: $patternID) {
                        ForEach(BreathPattern.library) { pattern in
                            Text(pattern.name).tag(pattern.id)
                        }
                    }
                }

                Section("Feedback") {
                    Toggle("Haptics", isOn: $haptics)
                    Toggle("Keep screen awake", isOn: $keepAwake)
                }

                Section("Appearance") {
                    Picker("Theme", selection: $appearance) {
                        ForEach(Appearance.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Data") {
                    Button("Reset all sessions", role: .destructive) {
                        showResetConfirm = true
                    }
                    .disabled(sessions.isEmpty)
                }

                Section {
                    LabeledContent("Version", value: "1.0")
                    LabeledContent("Made by", value: "Arseniy Cherednichenko")
                } footer: {
                    Text("Aura — a calm space to breathe.")
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Delete all breathing history?",
                                isPresented: $showResetConfirm,
                                titleVisibility: .visible) {
                Button("Delete everything", role: .destructive) {
                    for session in sessions { context.delete(session) }
                    try? context.save()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes every saved session, your streak, and your stats. It cannot be undone.")
            }
        }
    }
}
