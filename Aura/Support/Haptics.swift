import UIKit

/// Thin wrapper over UIKit feedback generators. Call sites pass `enabled` so the
/// user's haptics setting is respected in one place.
enum Haptics {
    static func phase(enabled: Bool) {
        guard enabled else { return }
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
    }

    static func success(enabled: Bool) {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func tap(enabled: Bool = true) {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
