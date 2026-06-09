import SwiftUI
import SwiftData

struct BreatheView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage(SettingsKey.sessionMinutes) private var sessionMinutes: Int = 3
    @AppStorage(SettingsKey.defaultPatternID) private var patternID: String = "box"
    @AppStorage(SettingsKey.haptics) private var haptics: Bool = true
    @AppStorage(SettingsKey.keepAwake) private var keepAwake: Bool = true

    private enum Mode { case idle, running, paused, complete }

    @State private var mode: Mode = .idle
    @State private var engine: BreathEngine?
    @State private var scale: CGFloat = 0.55
    @State private var lastTick: Date?
    @State private var completedSeconds: Double = 0
    @State private var idlePulse = false

    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    private var pattern: BreathPattern { BreathPattern.pattern(id: patternID) }

    var body: some View {
        ZStack {
            AmbientBackground(tint: Theme.phaseTint(engine?.phase ?? .inhale))

            switch mode {
            case .idle: idleView
            case .running, .paused: activeView
            case .complete: completeView
            }
        }
        .onReceive(timer) { now in
            guard mode == .running, let engine else { lastTick = nil; return }
            guard let last = lastTick else { lastTick = now; return }
            lastTick = now
            engine.tick(now.timeIntervalSince(last))
            if engine.isComplete { finish() }
        }
        .onChange(of: engine?.transitions) {
            guard mode == .running, let engine else { return }
            withAnimation(reduceMotion ? nil : .easeInOut(duration: engine.currentStep.seconds)) {
                scale = engine.phase.targetScale
            }
            Haptics.phase(enabled: haptics)
        }
        .onChange(of: mode) { _, newMode in
            UIApplication.shared.isIdleTimerDisabled = (newMode == .running) && keepAwake
        }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    // MARK: Idle

    private var idleView: some View {
        VStack(spacing: 28) {
            VStack(spacing: 6) {
                Text("Aura")
                    .font(.largeTitle.weight(.bold))
                Text("Take a few minutes to breathe.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 24)

            Spacer()

            BreathOrb(scale: idlePulse ? 0.74 : 0.64, progress: 0)
                .frame(width: 230, height: 230)
                .overlay {
                    Image(systemName: "wind")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .accessibilityHidden(true)
                .onAppear {
                    guard !reduceMotion else { return }
                    withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                        idlePulse = true
                    }
                }

            Spacer()

            VStack(spacing: 18) {
                PatternPicker(selection: $patternID)

                durationPicker

                Button(action: begin) {
                    Text("Begin")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.orbGradient, in: Capsule())
                        .foregroundStyle(.black)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 12)
        }
        .padding(.horizontal)
        .foregroundStyle(.white)
    }

    private var durationPicker: some View {
        VStack(spacing: 8) {
            Text("Session length")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 10) {
                ForEach([1, 3, 5, 10], id: \.self) { minutes in
                    let selected = sessionMinutes == minutes
                    Button {
                        sessionMinutes = minutes
                        Haptics.tap(enabled: haptics)
                    } label: {
                        Text("\(minutes) min")
                            .font(.subheadline.weight(selected ? .semibold : .regular))
                            .padding(.vertical, 9)
                            .frame(maxWidth: .infinity)
                            .background(selected ? Color.white.opacity(0.16) : Color.white.opacity(0.05), in: Capsule())
                            .overlay(Capsule().stroke(selected ? Theme.accent : .clear, lineWidth: 1))
                    }
                    .foregroundStyle(.white)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: Active

    private var activeView: some View {
        VStack {
            Text(pattern.name)
                .font(.headline)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.top, 28)

            Spacer()

            BreathOrb(scale: scale, progress: engine?.progress ?? 0)
                .frame(width: 300, height: 300)
                .overlay { orbLabel }

            Spacer()

            Text("\(Format.clock(engine?.remaining ?? 0)) left")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 16) {
                Button(action: togglePause) {
                    Label(mode == .paused ? "Resume" : "Pause",
                          systemImage: mode == .paused ? "play.fill" : "pause.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.white.opacity(0.12), in: Capsule())
                }
                Button(action: endEarly) {
                    Label("End", systemImage: "stop.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.white.opacity(0.12), in: Capsule())
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 16)
        }
        .padding(.horizontal)
    }

    private var orbLabel: some View {
        VStack(spacing: 6) {
            Text(engine?.phase.verb ?? "")
                .font(.title2.weight(.medium))
            Text("\(Int(ceil(engine?.phaseRemaining ?? 0)))")
                .font(.system(size: 44, weight: .light).monospacedDigit())
        }
        .foregroundStyle(.white)
        .contentTransition(.numericText())
        .animation(.snappy, value: engine?.phase)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(engine?.phase.verb ?? "")
        .accessibilityValue("\(Int(ceil(engine?.phaseRemaining ?? 0))) seconds")
    }

    // MARK: Complete

    private var completeView: some View {
        VStack(spacing: 22) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(Theme.orbGradient)
            Text("Nicely done")
                .font(.title.weight(.bold))
            Text("You breathed for \(Format.minutes(completedSeconds / 60)).")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button(action: reset) {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Theme.orbGradient, in: Capsule())
                    .foregroundStyle(.black)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .padding(.horizontal)
        .foregroundStyle(.white)
        .transition(.opacity)
    }

    // MARK: Actions

    private func begin() {
        let newEngine = BreathEngine(pattern: pattern, sessionLength: Double(sessionMinutes) * 60)
        engine = newEngine
        scale = 0.55
        lastTick = nil
        mode = .running
        Haptics.tap(enabled: haptics)
        withAnimation(reduceMotion ? nil : .easeInOut(duration: newEngine.currentStep.seconds)) {
            scale = newEngine.phase.targetScale
        }
    }

    private func togglePause() {
        switch mode {
        case .running: mode = .paused
        case .paused:
            lastTick = nil
            mode = .running
        default: break
        }
        Haptics.tap(enabled: haptics)
    }

    private func endEarly() {
        guard let engine else { reset(); return }
        if engine.totalElapsed >= 60 {
            completedSeconds = engine.totalElapsed
            save(seconds: engine.totalElapsed)
            withAnimation { mode = .complete }
        } else {
            reset()
        }
    }

    private func finish() {
        guard let engine else { return }
        completedSeconds = engine.sessionLength
        save(seconds: engine.sessionLength)
        Haptics.success(enabled: haptics)
        withAnimation { mode = .complete }
    }

    private func save(seconds: Double) {
        let session = BreathingSession(
            endedAt: Date(),
            seconds: seconds,
            patternID: pattern.id,
            patternName: pattern.name
        )
        context.insert(session)
        try? context.save()
    }

    private func reset() {
        engine = nil
        scale = 0.55
        lastTick = nil
        withAnimation { mode = .idle }
    }
}
