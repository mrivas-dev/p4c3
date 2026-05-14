import Foundation
import Observation
import SwiftData

@Observable
final class OnboardingViewModel {
    private let profile: AthleteProfile
    private let modelContext: ModelContext

    var stepIndex: Int = 0

    /// Optional display name trimmed.
    var nameDraft: String = ""
    var bodyWeightInput: String = ""
    var unitDraft: UnitSystem = .kg
    var trainingFrequency: Int = 4
    var experienceDraft: ExperienceLevel = .intermediate
    /// Per-lift string inputs in the athlete's display unit from step 1 (`unitDraft`).
    var liftInputs: [CoreLift: String] = [:]

    init(profile: AthleteProfile, modelContext: ModelContext) {
        self.profile = profile
        self.modelContext = modelContext

        nameDraft = profile.name
        if let kg = profile.bodyWeightKg {
            bodyWeightInput = UnitConversion.trimmedDisplayDecimalString(
                forKg: kg,
                unit: profile.unitPreference
            )
        }
        unitDraft = profile.unitPreference
        trainingFrequency = clampFrequency(profile.trainingFrequency)
        experienceDraft = profile.experienceLevel

        var map: [CoreLift: String] = [:]
        for lift in CoreLift.allCases {
            map[lift] = ""
        }
        for max in profile.liftMaxes where max.oneRepMaxKg > 0 {
            map[max.lift] = UnitConversion.trimmedDisplayDecimalString(
                forKg: max.oneRepMaxKg,
                unit: unitDraft
            )
        }
        liftInputs = map
    }

    var stepDisplayIndex: Int { stepIndex + 1 }
    private let stepCount = 3

    func canAdvancePastCurrentStep(_ step: Int) -> Bool {
        switch step {
        case 0: true
        case 1: (3 ... 6).contains(trainingFrequency)
        default: false
        }
    }

    func advance() {
        guard stepIndex + 1 < stepCount else { return }
        stepIndex += 1
        syncLiftInputUnitsFromDraft()
    }

    func syncLiftInputUnitsFromDraft() {
        for lift in CoreLift.allCases {
            guard let raw = liftInputs[lift], !raw.isEmpty,
                  let kg = UnitConversion.kg(fromDisplayInput: raw, unit: unitDraft) else {
                liftInputs[lift] = ""
                continue
            }
            liftInputs[lift] = UnitConversion.trimmedDisplayDecimalString(
                forKg: kg,
                unit: unitDraft
            )
        }
    }

    /// Complete onboarding skipping 1RM entry (ticket secondary CTA).
    func skipLiftMaxEntries() throws {
        try applyAthleteBasics(includeLiftEntries: false)
        profile.onboardingCompleted = true
        profile.touchUpdated()
        try modelContext.save()
    }

    func completeWithEnteredLiftMaxes() throws {
        try applyAthleteBasics(includeLiftEntries: true)
        profile.onboardingCompleted = true
        profile.touchUpdated()
        try modelContext.save()
    }

    func applyAthleteBasics(includeLiftEntries: Bool) throws {
        let trimmed = nameDraft.trimmingCharacters(in: .whitespacesAndNewlines)

        profile.name = trimmed

        profile.bodyWeightKg = UnitConversion.kg(fromDisplayInput: bodyWeightInput, unit: unitDraft)
            .flatMap { $0 > 0 ? $0 : nil }

        profile.unitPreferenceRaw = unitDraft.rawValue
        profile.trainingFrequency = clampFrequency(trainingFrequency)
        profile.experienceLevelRaw = experienceDraft.rawValue

        if includeLiftEntries {
            liftMaxKgByLiftApplyingDraft().forEach { lift, kg in upsertLiftMax(lift: lift, kg: kg, on: profile) }
        }

        profile.touchUpdated()
        try modelContext.save()
    }

    /// Applies non-destructively (used by tests): updates profile basics + optionally lift maxes without toggling onboarding.
    func stagingSnapshot(includeLiftEntries: Bool) throws {
        try applyAthleteBasics(includeLiftEntries: includeLiftEntries)
    }

    private func liftMaxKgByLiftApplyingDraft() -> [CoreLift: Double] {
        var out: [CoreLift: Double] = [:]
        for lift in CoreLift.allCases {
            guard let text = liftInputs[lift]?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty,
                  let kg = UnitConversion.kg(fromDisplayInput: text, unit: unitDraft), kg > 0 else {
                continue
            }
            out[lift] = kg
        }
        return out
    }

    private func upsertLiftMax(lift: CoreLift, kg: Double, on profile: AthleteProfile) {
        if let existing = profile.liftMaxes.first(where: { $0.lift == lift }) {
            existing.oneRepMaxKg = kg
            existing.updatedAt = Date()
        } else {
            let lm = LiftMax(lift: lift, oneRepMaxKg: kg, profile: profile)
            modelContext.insert(lm)
        }
        try? LiftOneRM.syncTested(liftName: lift.rawValue, testedKg: kg, context: modelContext)
    }

    private func clampFrequency(_ v: Int) -> Int {
        min(6, max(3, v))
    }
}
