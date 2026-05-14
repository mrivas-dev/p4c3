import Foundation
import Observation
import SwiftData

@Observable
final class SettingsViewModel {
    func oneRepMaxKg(for lift: CoreLift, profile: AthleteProfile) -> Double? {
        profile.liftMaxes.first(where: { $0.lift == lift }).map(\.oneRepMaxKg)
    }

    func resetAllOneRepMaxes(profile: AthleteProfile, context: ModelContext) throws {
        let copy = profile.liftMaxes
        for lm in copy {
            context.delete(lm)
        }
        profile.touchUpdated()
        try context.save()
    }
}
