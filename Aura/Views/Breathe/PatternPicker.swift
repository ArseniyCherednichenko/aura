import SwiftUI

/// Horizontal carousel of breathing techniques.
struct PatternPicker: View {
    @Binding var selection: String
    @AppStorage(SettingsKey.haptics) private var haptics: Bool = true

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            GlassEffectContainer(spacing: 12) {
                HStack(spacing: 12) {
                    ForEach(BreathPattern.library) { pattern in
                        let selected = pattern.id == selection
                        Button {
                            selection = pattern.id
                            Haptics.tap(enabled: haptics)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pattern.name)
                                    .font(.headline)
                                Text(pattern.subtitle)
                                    .font(.caption2)
                                    .foregroundStyle(.white.opacity(0.6))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2)
                            }
                            .frame(width: 158, height: 78, alignment: .topLeading)
                            .padding(12)
                            .glassEffect(
                                selected
                                    ? .regular.tint(Theme.accent.opacity(0.35)).interactive()
                                    : .regular.interactive(),
                                in: .rect(cornerRadius: 18)
                            )
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                        .accessibilityLabel("\(pattern.name) pattern")
                        .accessibilityAddTraits(selected ? .isSelected : [])
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}
