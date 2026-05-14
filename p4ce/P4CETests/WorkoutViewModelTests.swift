import SwiftData
import XCTest
@testable import P4CE

@MainActor
final class WorkoutViewModelTests: XCTestCase {
    func testStartSession_setsActiveSessionAndPersistsExercises() throws {
        let ctx = ModelContext(try P4CESchema.testingContainer())
        let sut = WorkoutViewModel()
        sut.attach(modelContext: ctx)

        let session = sut.startSession(exercises: [
            CoreLift.snatch.rawValue,
            "Thruster"
        ])

        XCTAssertNotNil(session)
        XCTAssertEqual(sut.activeSession?.id, session?.id)
        XCTAssertEqual(try ctx.fetch(FetchDescriptor<WorkoutSession>()).count, 1)

        let exercises = try XCTUnwrap(session?.exercises.sorted { $0.order < $1.order })
        XCTAssertEqual(exercises.count, 2)
        XCTAssertEqual(exercises[0].name, CoreLift.snatch.rawValue)
        XCTAssertEqual(exercises[0].coreLift, .snatch)
        XCTAssertEqual(exercises[1].name, "Thruster")
        XCTAssertNil(exercises[1].coreLift)
    }

    func testAddSet_linksToExerciseAndRefreshesObservation() throws {
        let ctx = ModelContext(try P4CESchema.testingContainer())
        let sut = WorkoutViewModel()
        sut.attach(modelContext: ctx)

        let session = try XCTUnwrap(sut.startSession(exercises: [CoreLift.deadlift.rawValue]))
        guard let exercise = session.exercises.first else {
            return XCTFail("Expected exercise")
        }

        sut.addSet(to: exercise, weight: 180, reps: 5, rpe: 7.5)

        XCTAssertEqual(exercise.sets.count, 1)
        XCTAssertEqual(exercise.sets.first?.weight, 180)
        XCTAssertEqual(exercise.sets.first?.reps, 5)
        XCTAssertEqual(exercise.sets.first?.rpe, 7.5)
        XCTAssertEqual(try ctx.fetch(FetchDescriptor<SetEntry>()).count, 1)
    }
}
