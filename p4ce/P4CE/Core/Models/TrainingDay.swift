import Foundation
import SwiftData

@Model
final class TrainingDay {
    /// `Calendar` weekday component (`1` = Sunday … `7` = Saturday).
    var dayOfWeek: Int

    /// Encoded ``LiftAssignment`` payload (SwiftData-friendly storage).
    var assignmentsPayload: Data

    var week: TrainingWeek?

    init(dayOfWeek: Int, assignments: [LiftAssignment], week: TrainingWeek? = nil) {
        self.dayOfWeek = dayOfWeek
        assignmentsPayload = (try? JSONEncoder().encode(assignments)) ?? Data()
        self.week = week
    }

    func liftAssignments() throws -> [LiftAssignment] {
        try JSONDecoder().decode([LiftAssignment].self, from: assignmentsPayload)
    }
}
