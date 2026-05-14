import Foundation

/// Pure session aggregates for summaries and dashboard tiles (testable without SwiftUI).
enum WorkoutSessionMetrics {
    static func totalVolume(for session: WorkoutSession) -> Double {
        session.exercises.reduce(0) { partial, exercise in
            partial + exercise.sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
        }
    }

    static func totalSets(for session: WorkoutSession) -> Int {
        session.exercises.reduce(0) { $0 + $1.sets.count }
    }
}
