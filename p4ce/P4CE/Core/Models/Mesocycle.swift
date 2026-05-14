import Foundation
import SwiftData

@Model
final class Mesocycle {
    @Attribute(.unique)
    var id: UUID

    var startDate: Date

    /// Length of the mesocycle (fixed at 12 for the shipped block scheme).
    var totalWeeks: Int

    /// Canonical lift names included in this plan (matches ``CoreLift`` display strings).
    var lifts: [String]

    /// Athlete-facing week index (1…`totalWeeks`).
    var currentWeek: Int

    var currentBlockRaw: String

    @Relationship(deleteRule: .cascade, inverse: \TrainingWeek.mesocycle)
    var weeks: [TrainingWeek]

    var currentBlock: TrainingPhase {
        get { TrainingPhase(rawValue: currentBlockRaw) ?? .accumulation }
        set { currentBlockRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        startDate: Date,
        totalWeeks: Int = 12,
        lifts: [String],
        currentWeek: Int = 1,
        currentBlock: TrainingPhase = .accumulation,
        weeks: [TrainingWeek] = []
    ) {
        self.id = id
        self.startDate = startDate
        self.totalWeeks = totalWeeks
        self.lifts = lifts
        self.currentWeek = currentWeek
        currentBlockRaw = currentBlock.rawValue
        self.weeks = weeks
    }
}
