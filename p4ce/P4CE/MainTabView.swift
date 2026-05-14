import SwiftData
import SwiftUI

enum MainTab: Hashable {
    case dashboard
    case workout
    case strength
    case analytics
}

/// Root tab shell — four tabs per P4CE-4 / `DESIGN.md` § Navigation (MVP).
struct MainTabView: View {
    @State private var selectedTab: MainTab = .dashboard

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(onGoToWorkout: { selectedTab = .workout })
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(MainTab.dashboard)

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
            .tag(MainTab.workout)

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
            .tag(MainTab.strength)

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
            .tag(MainTab.analytics)
        }
        .tint(Color.P4CE.lime)
        .environment(\.switchToDashboardTab) {
            Task { @MainActor in
                selectedTab = .dashboard
            }
        }
    }
}

#Preview("MainTabView") {
    MainTabView()
        .environmentObject(WorkoutViewModel())
        .modelContainer(try! P4CESchema.previewContainer())
        .preferredColorScheme(.dark)
}
