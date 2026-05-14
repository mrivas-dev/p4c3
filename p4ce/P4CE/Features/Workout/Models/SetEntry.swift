import Foundation
import SwiftData

@Model
final class SetEntry {
    @Attribute(.unique)
    var id: UUID

    var weight: Double

    var reps: Int

    var rpe: Double?

    var timestamp: Date

    var exercise: WorkoutExercise?

    init(
        id: UUID = UUID(),
        weight: Double,
        reps: Int,
        rpe: Double? = nil,
        timestamp: Date = Date(),
        exercise: WorkoutExercise? = nil
    ) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.rpe = rpe
        self.timestamp = timestamp
        self.exercise = exercise
    }
}
