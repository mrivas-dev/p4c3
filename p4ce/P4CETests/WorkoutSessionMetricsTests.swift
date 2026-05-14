import XCTest
@testable import P4CE

final class WorkoutSessionMetricsTests: XCTestCase {
    func testTotalVolume_sumsWeightTimesRepsAcrossExercises() {
        let session = WorkoutSession()
        let squat = WorkoutExercise(name: "Squat", order: 0, session: session)
        session.exercises.append(squat)
        addSet(to: squat, weight: 100, reps: 5)
        addSet(to: squat, weight: 100, reps: 3)

        let pull = WorkoutExercise(name: "Pull-up", order: 1, session: session)
        session.exercises.append(pull)
        addSet(to: pull, weight: 0, reps: 12)

        XCTAssertEqual(WorkoutSessionMetrics.totalVolume(for: session), 800, accuracy: 0.001)
    }

    func testTotalSets_countsAllLoggedSets() {
        let session = WorkoutSession()
        let a = WorkoutExercise(name: "A", order: 0, session: session)
        let b = WorkoutExercise(name: "B", order: 1, session: session)
        session.exercises.append(contentsOf: [a, b])
        addSet(to: a, weight: 50, reps: 10)
        addSet(to: a, weight: 50, reps: 10)
        addSet(to: b, weight: 60, reps: 5)

        XCTAssertEqual(WorkoutSessionMetrics.totalSets(for: session), 3)
    }

    private func addSet(to exercise: WorkoutExercise, weight: Double, reps: Int) {
        let entry = SetEntry(weight: weight, reps: reps, exercise: exercise)
        exercise.sets.append(entry)
    }
}
