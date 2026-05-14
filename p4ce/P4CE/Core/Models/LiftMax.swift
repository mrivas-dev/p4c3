import Foundation
import SwiftData

@Model
final class LiftMax {
    var liftRaw: String
    var oneRepMaxKg: Double
    var updatedAt: Date
    var profile: AthleteProfile?

    var lift: CoreLift {
        get { CoreLift(rawValue: liftRaw) ?? .backSquat }
        set { liftRaw = newValue.rawValue }
    }

    init(
        lift: CoreLift,
        oneRepMaxKg: Double,
        updatedAt: Date = Date(),
        profile: AthleteProfile? = nil
    ) {
        liftRaw = lift.rawValue
        self.oneRepMaxKg = oneRepMaxKg
        self.updatedAt = updatedAt
        self.profile = profile
    }
}
