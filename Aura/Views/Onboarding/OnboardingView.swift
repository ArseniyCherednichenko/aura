import SwiftUI

private struct OnboardPage: Identifiable {
    let id = UUID()
    let symbol: String
    let title: String
    let body: String
}

struct OnboardingView: View {
    var onFinish: () -> Void

    @State private var page = 0

    private let pages: [OnboardPage] = [
        OnboardPage(symbol: "wind",
                    title: "Welcome to Aura",
                    body: "A calm space to slow down and breathe, a few minutes at a time."),
        OnboardPage(symbol: "circle.circle",
                    title: "Follow the orb",
                    body: "Breathe in as it grows, out as it settles. Pick a pattern that fits your mood."),
        OnboardPage(symbol: "flame",
                    title: "Build a streak",
                    body: "Each session is saved. Watch your minutes and your daily streak grow."),
    ]

    var body: some View {
        ZStack {
            AmbientBackground(tint: Theme.orbTop)

            VStack {
                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, item in
                        VStack(spacing: 22) {
                            Spacer()
                            Image(systemName: item.symbol)
                                .font(.system(size: 70, weight: .light))
                                .foregroundStyle(Theme.orbGradient)
                            Text(item.title)
                                .font(.largeTitle.weight(.bold))
                                .multilineTextAlignment(.center)
                            Text(item.body)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 36)
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))

                Button {
                    if page == pages.count - 1 {
                        onFinish()
                    } else {
                        withAnimation { page += 1 }
                    }
                } label: {
                    Text(page == pages.count - 1 ? "Begin" : "Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Theme.orbGradient, in: Capsule())
                        .foregroundStyle(.black)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .foregroundStyle(.white)
        }
    }
}
