import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            BreatheView()
                .tabItem { Label("Breathe", systemImage: "wind") }
            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar.fill") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Theme.accent)
    }
}
