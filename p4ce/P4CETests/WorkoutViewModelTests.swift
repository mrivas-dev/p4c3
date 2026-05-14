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

    func testDiscardSession_setsAbandonedAndClearsActive() throws {
        let ctx = ModelContext(try P4CESchema.testingContainer())
        let sut = WorkoutViewModel()
        sut.attach(modelContext: ctx)

        let session = try XCTUnwrap(sut.startSession(exercises: [CoreLift.benchPress.rawValue]))
        XCTAssertEqual(session.status, .inProgress)

        sut.discardSession(session)

        XCTAssertEqual(session.status, .abandoned)
        XCTAssertNil(sut.activeSession)

        let inProgress = try ctx.fetch(
            FetchDescriptor<WorkoutSession>(predicate: #Predicate { $0.statusRaw == "inProgress" })
        )
        XCTAssertTrue(inProgress.isEmpty)
    }

    func testStartSession_whenInProgressExists_returnsNilWithoutCreatingSecondSession() throws {
        let ctx = ModelContext(try P4CESchema.testingContainer())
        let sut = WorkoutViewModel()
        sut.attach(modelContext: ctx)

        _ = sut.startSession(exercises: [CoreLift.snatch.rawValue])
        let dup = sut.startSession(exercises: [CoreLift.deadlift.rawValue])

        XCTAssertNil(dup)
        XCTAssertEqual(try ctx.fetch(FetchDescriptor<WorkoutSession>()).count, 1)
    }

    func testInProgressSession_survivesNewModelContext() throws {
        let container = try P4CESchema.testingContainer()
        let writer = ModelContext(container)
        let session = WorkoutSession(status: .inProgress)
        writer.insert(session)
        try writer.save()

        let reader = ModelContext(container)
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate<WorkoutSession> { $0.statusRaw == "inProgress" },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let fetched = try reader.fetch(descriptor)

        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.id, session.id)

        let sut = WorkoutViewModel()
        sut.attach(modelContext: reader)
        XCTAssertEqual(sut.fetchInProgressSession()?.id, session.id)

        let resumed = try XCTUnwrap(fetched.first)
        sut.resumeSession(resumed)
        XCTAssertEqual(sut.activeSession?.id, session.id)
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

        let liftKey = CoreLift.deadlift.rawValue
        var oneRMDescriptor = FetchDescriptor<LiftOneRM>(predicate: #Predicate { $0.liftName == liftKey })
        oneRMDescriptor.fetchLimit = 1
        let oneRMRow = try XCTUnwrap(try ctx.fetch(oneRMDescriptor).first)
        let expected = OneRMCalculator.epley(weight: 180, reps: 5)
        let estimated = try XCTUnwrap(oneRMRow.estimatedRM)
        XCTAssertEqual(estimated, expected, accuracy: 0.01)
    }

    func testAddSet_repsAboveTen_doesNotUpdateEstimatedOneRM() throws {
        let ctx = ModelContext(try P4CESchema.testingContainer())
        let sut = WorkoutViewModel()
        sut.attach(modelContext: ctx)

        let session = try XCTUnwrap(sut.startSession(exercises: [CoreLift.benchPress.rawValue]))
        let exercise = try XCTUnwrap(session.exercises.first)

        sut.addSet(to: exercise, weight: 100, reps: 11, rpe: nil)

        XCTAssertEqual(try ctx.fetch(FetchDescriptor<LiftOneRM>()).count, 0)
    }

    func testFinishSession_persistsDurationStatusAndClearsActive() throws {
        let ctx = ModelContext(try P4CESchema.testingContainer())
        let sut = WorkoutViewModel()
        sut.attach(modelContext: ctx)

        let session = try XCTUnwrap(sut.startSession(exercises: [CoreLift.benchPress.rawValue]))
        sut.finishSession(session, elapsed: 1234)

        XCTAssertEqual(session.duration, 1234, accuracy: 0.001)
        XCTAssertEqual(session.status, .finished)
        XCTAssertNil(sut.activeSession)
    }
}
