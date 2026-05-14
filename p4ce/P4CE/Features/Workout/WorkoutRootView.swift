import SwiftUI

struct WorkoutRootView: View {
    @EnvironmentObject
    private var workoutViewModel: WorkoutViewModel

    var body: some View {
        Group {
            if let session = workoutViewModel.activeSession {
                ActiveSessionView(session: session)
            } else {
                FeatureTabPlaceholder(
                    title: "Workout",
                    systemImage: "bolt.fill",
                    message: "Start from Home — track everything from your phone."
                )
            }
        }
    }
}

#Preview("WorkoutRootView — idle") {
    NavigationStack {
        WorkoutRootView()
    }
    .environmentObject(WorkoutViewModel())
    .preferredColorScheme(.dark)
}

#Preview("WorkoutRootView — active") {
    struct Harness: View {
        @Environment(\.modelContext)
        private var modelContext

        @StateObject
        private var workoutViewModel = WorkoutViewModel()

        var body: some View {
            NavigationStack {
                WorkoutRootView()
                    .environmentObject(workoutViewModel)
            }
            .task {
                workoutViewModel.attach(modelContext: modelContext)
                _ = workoutViewModel.startSession(exercises: [
                    CoreLift.backSquat.rawValue,
                    "Row"
                ])
            }
            .preferredColorScheme(.dark)
        }
    }

    return Harness()
        .modelContainer(try! P4CESchema.previewContainer())
}
