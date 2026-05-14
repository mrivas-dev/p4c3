import Foundation
import SwiftData

@Model
final class WorkoutSession {
    @Attribute(.unique)
    var id: UUID

    var date: Date

    /// Wall-clock elapsed time for this session once completed.
    var duration: TimeInterval

    /// Stored backing for ``status`` — internal so finished sessions are queryable from views (`#Predicate`).
    var statusRaw: String

    var status: WorkoutSessionStatus {
        get {
            WorkoutSessionStatus(rawValue: statusRaw) ?? .inProgress
        }
        set {
            statusRaw = newValue.rawValue
        }
    }

    @Relationship(deleteRule: .cascade, inverse: \WorkoutExercise.session)
    var exercises: [WorkoutExercise]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval = 0,
        status: WorkoutSessionStatus = .inProgress,
        exercises: [WorkoutExercise] = []
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        statusRaw = status.rawValue
        self.exercises = exercises
    }
}
