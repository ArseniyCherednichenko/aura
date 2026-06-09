import SwiftUI

struct SettingsView: View {
    @AppStorage(SettingsKey.sessionMinutes) private var sessionMinutes: Int = 3
    @AppStorage(SettingsKey.defaultPatternID) private var patternID: String = "box"
    @AppStorage(SettingsKey.haptics) private var haptics: Bool = true
    @AppStorage(SettingsKey.keepAwake) private var keepAwake: Bool = true
    @AppStorage(SettingsKey.appearance) private var appearance: Appearance = .system

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

                Section {
                    LabeledContent("Version", value: "1.0")
                    LabeledContent("Made by", value: "Arseniy Cherednichenko")
                } footer: {
                    Text("Aura — a calm space to breathe.")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
