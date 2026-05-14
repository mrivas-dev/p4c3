import SwiftData
import XCTest
@testable import P4CE

@MainActor
final class WorkoutLoggingModelTests: XCTestCase {
    func testCreateSessionExerciseSet_roundTripRelationships() throws {
        let ctx = ModelContext(try P4CESchema.testingContainer())

        let session = WorkoutSession()
        ctx.insert(session)

        let exercise = WorkoutExercise(
            name: CoreLift.backSquat.rawValue,
            order: 0,
            coreLift: .backSquat
        )
        exercise.session = session
        session.exercises.append(exercise)
        ctx.insert(exercise)

        let entry = SetEntry(weight: 100, reps: 5, rpe: 8)
        entry.exercise = exercise
        exercise.sets.append(entry)
        ctx.insert(entry)

        try ctx.save()

        let sessions = try ctx.fetch(FetchDescriptor<WorkoutSession>())
        XCTAssertEqual(sessions.count, 1)
        XCTAssertEqual(sessions.first?.status, .inProgress)
        XCTAssertEqual(sessions.first?.exercises.count, 1)
        XCTAssertEqual(sessions.first?.exercises.first?.sets.count, 1)
        XCTAssertEqual(sessions.first?.exercises.first?.coreLift, .backSquat)
        XCTAssertEqual(sessions.first?.exercises.first?.sets.first?.weight, 100)
        XCTAssertEqual(sessions.first?.exercises.first?.sets.first?.reps, 5)
        XCTAssertEqual(sessions.first?.exercises.first?.sets.first?.rpe, 8)
    }

    func testDeletingSession_cascadesToExercisesAndSets() throws {
        let ctx = ModelContext(try P4CESchema.testingContainer())

        let session = WorkoutSession()
        ctx.insert(session)

        let exercise = WorkoutExercise(name: "Row", order: 0, coreLift: nil)
        exercise.session = session
        session.exercises.append(exercise)
        ctx.insert(exercise)

        let entry = SetEntry(weight: 60, reps: 10)
        entry.exercise = exercise
        exercise.sets.append(entry)
        ctx.insert(entry)

        try ctx.save()

        XCTAssertEqual(try ctx.fetch(FetchDescriptor<WorkoutSession>()).count, 1)

        guard let persisted = try ctx.fetch(FetchDescriptor<WorkoutSession>()).first else {
            return XCTFail("Expected session")
        }
        ctx.delete(persisted)
        try ctx.save()

        XCTAssertEqual(try ctx.fetch(FetchDescriptor<WorkoutSession>()).count, 0)
        XCTAssertEqual(try ctx.fetch(FetchDescriptor<WorkoutExercise>()).count, 0)
        XCTAssertEqual(try ctx.fetch(FetchDescriptor<SetEntry>()).count, 0)
    }
}
