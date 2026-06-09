import SwiftUI
import SwiftData

@main
struct AuraApp: App {
    @AppStorage(SettingsKey.appearance) private var appearance: Appearance = .system
    @AppStorage(SettingsKey.didOnboard) private var didOnboard: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if didOnboard {
                    RootView()
                } else {
                    OnboardingView(onFinish: { didOnboard = true })
                }
            }
            .preferredColorScheme(appearance.colorScheme)
            .tint(Theme.accent)
        }
        .modelContainer(for: BreathingSession.self)
    }
}
