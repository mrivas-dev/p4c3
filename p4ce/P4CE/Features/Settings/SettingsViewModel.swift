import Foundation
import Observation
import SwiftData

@Observable
final class SettingsViewModel {
    /// Higher of manual tested vs estimated 1RM when `LiftOneRM` exists; otherwise profile `LiftMax`.
    func workingOneRepMaxKg(for lift: CoreLift, profile: AthleteProfile, context: ModelContext) -> Double? {
        let key = lift.rawValue
        var descriptor = FetchDescriptor<LiftOneRM>(
            predicate: #Predicate { $0.liftName == key }
        )
        descriptor.fetchLimit = 1
        if let row = try? context.fetch(descriptor).first {
            let w = row.workingRM
            if w > 0 { return w }
        }
        return profile.liftMaxes.first(where: { $0.lift == lift }).map(\.oneRepMaxKg)
    }

    func resetAllOneRepMaxes(profile: AthleteProfile, context: ModelContext) throws {
        let copy = profile.liftMaxes
        for lm in copy {
            context.delete(lm)
        }
        let liftOneRows = try context.fetch(FetchDescriptor<LiftOneRM>())
        for row in liftOneRows {
            context.delete(row)
        }
        profile.touchUpdated()
        try context.save()
    }
}
