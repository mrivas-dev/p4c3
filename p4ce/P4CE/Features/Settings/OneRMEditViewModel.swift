import Foundation
import Observation
import SwiftData

@Observable
final class OneRMEditViewModel {
    let lift: CoreLift

    /// Kilograms persisted; zero means cleared / unset for display.
    var oneRepMaxKg: Double

    /// Binds the decimal text field (`DecimalPad`).
    var fieldText: String

    init(lift: CoreLift, initialKg: Double?, unitPreference: UnitSystem) {
        self.lift = lift
        let initial = max(0, initialKg ?? 0)
        self.oneRepMaxKg = initial
        self.fieldText =
            initial > 0
                ? UnitConversion.trimmedDisplayDecimalString(forKg: initial, unit: unitPreference)
                : ""
    }

    func bump(step: BumpStep, unitPreference: UnitSystem) {
        let deltaKg = bumpDeltaKg(for: unitPreference)
        switch step {
        case .decrease:
            oneRepMaxKg = max(0, oneRepMaxKg - deltaKg)
        case .increase:
            if oneRepMaxKg <= 0 {
                oneRepMaxKg = deltaKg
            } else {
                oneRepMaxKg += deltaKg
            }
        }
        syncField(for: unitPreference)
    }

    func applyFieldText(unitPreference: UnitSystem) {
        let trimmed = fieldText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            oneRepMaxKg = 0
            fieldText = ""
            return
        }
        guard let kg = UnitConversion.kg(fromDisplayInput: trimmed, unit: unitPreference), kg > 0 else {
            if oneRepMaxKg > 0 {
                fieldText = UnitConversion.trimmedDisplayDecimalString(
                    forKg: oneRepMaxKg,
                    unit: unitPreference
                )
            }
            return
        }
        oneRepMaxKg = kg
        fieldText = UnitConversion.trimmedDisplayDecimalString(forKg: kg, unit: unitPreference)
    }

    func syncField(for unitPreference: UnitSystem) {
        guard oneRepMaxKg > 0 else {
            fieldText = ""
            return
        }
        fieldText = UnitConversion.trimmedDisplayDecimalString(
            forKg: oneRepMaxKg,
            unit: unitPreference
        )
    }

    func save(profile: AthleteProfile, unitPreference: UnitSystem, context: ModelContext) throws {
        applyFieldText(unitPreference: unitPreference)

        guard oneRepMaxKg > 0 else {
            if let existing = profile.liftMaxes.first(where: { $0.lift == lift }) {
                context.delete(existing)
            }
            profile.touchUpdated()
            try context.save()
            return
        }

        if let existing = profile.liftMaxes.first(where: { $0.lift == lift }) {
            existing.oneRepMaxKg = oneRepMaxKg
            existing.updatedAt = Date()
        } else {
            let lm = LiftMax(lift: lift, oneRepMaxKg: oneRepMaxKg, profile: profile)
            context.insert(lm)
        }
        profile.touchUpdated()
        try context.save()
    }

    func bumpDeltaKg(for unitPreference: UnitSystem) -> Double {
        UnitConversion.kilograms(
            forDisplay: UnitConversion.incrementDisplay(for: unitPreference),
            unit: unitPreference
        )
    }

    enum BumpStep {
        case decrease
        case increase
    }
}
