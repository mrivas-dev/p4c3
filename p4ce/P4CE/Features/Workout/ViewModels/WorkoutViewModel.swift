import Foundation
import SwiftData
import SwiftUI

/// Coordinates live workout session state and SwiftData writes for the Workout feature.
@MainActor
final class WorkoutViewModel: ObservableObject {
    private var modelContext: ModelContext?

    @Published private(set) var activeSession: WorkoutSession?

    func attach(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Creates a persisted session plus exercises ordered as given. Selection must be non-empty (enforced by UI).
    @discardableResult
    func startSession(exercises exerciseNames: [String]) -> WorkoutSession? {
        guard let modelContext else {
            assertionFailure("WorkoutViewModel.attach(modelContext:) before startSession")
            return nil
        }
        precondition(!exerciseNames.isEmpty, "Start workout requires ≥1 exercise")

        let session = WorkoutSession()
        modelContext.insert(session)

        for (index, name) in exerciseNames.enumerated() {
            let coreLift = CoreLift(rawValue: name)
            let exercise = WorkoutExercise(name: name, order: index, coreLift: coreLift)
            exercise.session = session
            session.exercises.append(exercise)
            modelContext.insert(exercise)
        }

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save workout session: \(error)")
        }

        activeSession = session
        return session
    }

    func addSet(to exercise: WorkoutExercise, weight: Double, reps: Int, rpe: Double?) {
        guard let modelContext else {
            assertionFailure("WorkoutViewModel.attach(modelContext:) before addSet")
            return
        }

        let entry = SetEntry(weight: weight, reps: reps, rpe: rpe)
        entry.exercise = exercise
        exercise.sets.append(entry)
        modelContext.insert(entry)

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save set: \(error)")
        }

        objectWillChange.send()
    }

    /// Clears the in-memory active session pointer (persisted record is unchanged).
    func clearActiveSession() {
        activeSession = nil
    }
}
