import Foundation
import SwiftData

@Model
final class TrainingWeek {
    /// 1…12 within the mesocycle.
    var weekNumber: Int

    var isDeload: Bool

    var phaseRaw: String

    var mesocycle: Mesocycle?

    @Relationship(deleteRule: .cascade, inverse: \TrainingDay.week)
    var days: [TrainingDay]

    var phase: TrainingPhase {
        get { TrainingPhase(rawValue: phaseRaw) ?? .accumulation }
        set { phaseRaw = newValue.rawValue }
    }

    init(
        weekNumber: Int,
        isDeload: Bool,
        phase: TrainingPhase,
        mesocycle: Mesocycle? = nil,
        days: [TrainingDay] = []
    ) {
        self.weekNumber = weekNumber
        self.isDeload = isDeload
        phaseRaw = phase.rawValue
        self.mesocycle = mesocycle
        self.days = days
    }
}
