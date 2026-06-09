import SwiftUI

enum SettingsKey {
    static let didOnboard = "didOnboard"
    static let appearance = "appearance"
    static let sessionMinutes = "sessionMinutes"
    static let defaultPatternID = "defaultPatternID"
    static let haptics = "haptics"
    static let keepAwake = "keepAwake"
}

enum Appearance: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
