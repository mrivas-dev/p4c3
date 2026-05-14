import SwiftData

enum P4CESchema {
    static func makeSchema() -> Schema {
        Schema([
            AthleteProfile.self,
            LiftMax.self,
            LiftOneRM.self,
            Mesocycle.self,
            TrainingWeek.self,
            TrainingDay.self,
            WorkoutSession.self,
            WorkoutExercise.self,
            SetEntry.self,
        ])
    }

    /// Shared in-memory container for SwiftUI previews.
    static func previewContainer() throws -> ModelContainer {
        let schema = makeSchema()
        return try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
    }

    /// Default container for unit tests (isolated store).
    static func testingContainer(inMemoryOnly: Bool = true) throws -> ModelContainer {
        let schema = makeSchema()
        return try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemoryOnly)]
        )
    }
}
