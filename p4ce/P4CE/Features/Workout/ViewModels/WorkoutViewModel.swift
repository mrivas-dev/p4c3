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

    /// Returns the most recent persisted session marked in-progress (at most one is expected during normal use).
    func fetchInProgressSession() -> WorkoutSession? {
        guard let modelContext else { return nil }
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate<WorkoutSession> { $0.statusRaw == "inProgress" },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }

    /// Re-attaches persisted state for an interrupted workout (sets ``activeSession``).
    func resumeSession(_ session: WorkoutSession) {
        guard session.status == .inProgress else { return }
        activeSession = session
        objectWillChange.send()
    }

    /// Marks a workout as abandoned so a new session can start; clears ``activeSession`` when it matches.
    func discardSession(_ session: WorkoutSession) {
        guard let modelContext else {
            assertionFailure("WorkoutViewModel.attach(modelContext:) before discardSession")
            return
        }
        guard session.status == .inProgress else { return }

        session.status = .abandoned

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to abandon workout session: \(error)")
        }

        if activeSession?.id == session.id {
            activeSession = nil
        }
        objectWillChange.send()
    }

    /// Creates a persisted session plus exercises ordered as given. Selection must be non-empty (enforced by UI).
    @discardableResult
    func startSession(exercises exerciseNames: [String]) -> WorkoutSession? {
        guard let modelContext else {
            assertionFailure("WorkoutViewModel.attach(modelContext:) before startSession")
            return nil
        }
        precondition(!exerciseNames.isEmpty, "Start workout requires ≥1 exercise")

        guard fetchInProgressSession() == nil else { return nil }

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

    /// Writes elapsed time, marks the session finished, and clears ``activeSession``.
    func finishSession(_ session: WorkoutSession, elapsed: TimeInterval) {
        guard let modelContext else {
            assertionFailure("WorkoutViewModel.attach(modelContext:) before finishSession")
            return
        }
        guard session.status == .inProgress else { return }

        session.duration = elapsed
        session.status = .finished

        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to finish workout session: \(error)")
        }

        if activeSession?.id == session.id {
            activeSession = nil
        }
        objectWillChange.send()
    }

    /// Clears the in-memory active session pointer (persisted record is unchanged).
    func clearActiveSession() {
        activeSession = nil
    }
}
