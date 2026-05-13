import SwiftUI

struct WorkoutRootView: View {
    var body: some View {
        FeatureTabPlaceholder(
            title: "Workout",
            systemImage: "bolt.fill",
            message: "Active sessions and logging will live here."
        )
    }
}

#Preview("WorkoutRootView") {
    NavigationStack {
        WorkoutRootView()
    }
    .preferredColorScheme(.dark)
}
