import Foundation
import SwiftData

@Model
final class AthleteProfile {
    var name: String
    var bodyWeightKg: Double?
    var unitPreferenceRaw: String
    var trainingFrequency: Int
    var experienceLevelRaw: String
    var onboardingCompleted: Bool
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \LiftMax.profile)
    var liftMaxes: [LiftMax]

    var unitPreference: UnitSystem {
        get { UnitSystem(rawValue: unitPreferenceRaw) ?? .kg }
        set { unitPreferenceRaw = newValue.rawValue }
    }

    var experienceLevel: ExperienceLevel {
        get { ExperienceLevel(rawValue: experienceLevelRaw) ?? .intermediate }
        set { experienceLevelRaw = newValue.rawValue }
    }

    init(
        name: String = "",
        bodyWeightKg: Double? = nil,
        unitPreference: UnitSystem = .kg,
        trainingFrequency: Int = 4,
        experienceLevel: ExperienceLevel = .intermediate,
        onboardingCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        liftMaxes: [LiftMax] = []
    ) {
        self.name = name
        self.bodyWeightKg = bodyWeightKg
        unitPreferenceRaw = unitPreference.rawValue
        self.trainingFrequency = trainingFrequency
        experienceLevelRaw = experienceLevel.rawValue
        self.onboardingCompleted = onboardingCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.liftMaxes = liftMaxes
    }

    static func fetchOrInsertSingleton(in context: ModelContext) throws -> AthleteProfile {
        var descriptor = FetchDescriptor<AthleteProfile>(
            sortBy: [SortDescriptor(\.createdAt, order: .forward)]
        )
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let profile = AthleteProfile()
        context.insert(profile)
        try context.save()
        return profile
    }

    func touchUpdated(at date: Date = Date()) {
        updatedAt = date
    }
}
