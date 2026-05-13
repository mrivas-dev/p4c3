import SwiftUI

/// Root tab shell — four tabs per P4CE-4 / `DESIGN.md` § Navigation (MVP).
struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }

            NavigationStack {
                WorkoutRootView()
                    .navigationTitle("Workout")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color.P4CE.bg, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
            }
            .tabItem {
                Label("Workout", systemImage: "bolt.fill")
            }

            NavigationStack {
                StrengthRootView()
                    .navigationTitle("Strength")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color.P4CE.bg, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
            }
            .tabItem {
                Label("Strength", systemImage: "figure.strengthtraining.traditional")
            }

            NavigationStack {
                AnalyticsRootView()
                    .navigationTitle("Analytics")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color.P4CE.bg, for: .navigationBar)
                    .toolbarColorScheme(.dark, for: .navigationBar)
            }
            .tabItem {
                Label("Analytics", systemImage: "chart.line.uptrend.xyaxis")
            }
        }
        .tint(Color.P4CE.lime)
    }
}

#Preview("MainTabView") {
    MainTabView()
        .preferredColorScheme(.dark)
}
