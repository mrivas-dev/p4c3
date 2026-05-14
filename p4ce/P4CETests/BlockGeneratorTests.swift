import SwiftData
import XCTest
@testable import P4CE

final class BlockGeneratorTests: XCTestCase {
    private func uniformOneRMs(weight: Double = 120) -> [String: Double] {
        Dictionary(uniqueKeysWithValues: CoreLift.allCases.map { ($0.rawValue, weight) })
    }

    func testIsDeloadWeek_flagsWeekFourAndEight() {
        XCTAssertTrue(BlockGenerator.isDeloadWeek(4))
        XCTAssertTrue(BlockGenerator.isDeloadWeek(8))
        XCTAssertFalse(BlockGenerator.isDeloadWeek(3))
        XCTAssertFalse(BlockGenerator.isDeloadWeek(9))
    }

    func testPrescribedWeight_roundsToNearestTwoPointFiveKg() {
        XCTAssertEqual(BlockGenerator.prescribedWeight(oneRM: 100, pct: 73), 72.5, accuracy: 0.001)
        XCTAssertEqual(BlockGenerator.prescribedWeight(oneRM: 0, pct: 80), 0, accuracy: 0.001)
    }

    func testGenerateMesocycle_producesTwelveWeeksWithThreeTrainingDaysEach() {
        let meso = BlockGenerator.generateMesocycle(
            oneRMs: uniformOneRMs(),
            frequency: 3,
            startDate: Date(timeIntervalSince1970: 0)
        )

        XCTAssertEqual(meso.weeks.count, 12)
        XCTAssertEqual(meso.totalWeeks, 12)
        XCTAssertEqual(meso.weeks.map(\.weekNumber), Array(1 ... 12))

        for week in meso.weeks {
            XCTAssertEqual(week.days.count, 3)
        }
    }

    func testGenerateMesocycle_schedulesMondayWednesdayFriday() throws {
        let meso = BlockGenerator.generateMesocycle(
            oneRMs: uniformOneRMs(),
            frequency: 3,
            startDate: .now
        )

        let weekdays = try XCTUnwrap(meso.weeks.first).days.map(\.dayOfWeek).sorted()
        XCTAssertEqual(weekdays, [2, 4, 6])
    }

    func testGenerateMesocycle_assignsCrossFitBiasPairingsPerDay() throws {
        let meso = BlockGenerator.generateMesocycle(
            oneRMs: uniformOneRMs(),
            frequency: 3,
            startDate: .now
        )

        let week = try XCTUnwrap(meso.weeks.first)
        let monday = try XCTUnwrap(week.days.first { $0.dayOfWeek == 2 })
        let wednesday = try XCTUnwrap(week.days.first { $0.dayOfWeek == 4 })
        let friday = try XCTUnwrap(week.days.first { $0.dayOfWeek == 6 })

        XCTAssertEqual(try monday.liftAssignments().map(\.liftName).sorted(), ["Back Squat", "Snatch"])
        XCTAssertEqual(try wednesday.liftAssignments().map(\.liftName).sorted(), ["Clean & Jerk", "Deadlift"])
        XCTAssertEqual(try friday.liftAssignments().map(\.liftName).sorted(), ["Bench Press", "Front Squat"])
    }

    func testDeloadWeeks_useReducedSetsAndIntensity() throws {
        let meso = BlockGenerator.generateMesocycle(
            oneRMs: uniformOneRMs(weight: 100),
            frequency: 3,
            startDate: .now
        )

        let week4 = try XCTUnwrap(meso.weeks.first { $0.weekNumber == 4 })
        XCTAssertTrue(week4.isDeload)
        XCTAssertEqual(week4.phase, .accumulation)

        let assignments = try XCTUnwrap(week4.days.first).liftAssignments()
        XCTAssertTrue(assignments.allSatisfy { $0.sets == 3 && $0.reps == 5 && $0.intensityPct == 60 })

        let priorWeek = try XCTUnwrap(meso.weeks.first { $0.weekNumber == 3 })
        let priorAssignments = try XCTUnwrap(priorWeek.days.first).liftAssignments()
        let priorVolume = priorAssignments.map { $0.sets * $0.reps }.reduce(0, +)
        let deloadVolume = assignments.map { $0.sets * $0.reps }.reduce(0, +)
        XCTAssertLessThan(deloadVolume, priorVolume)
    }

    func testIntensificationEndsAtEightyFivePercentOnWeekNine() throws {
        let meso = BlockGenerator.generateMesocycle(
            oneRMs: uniformOneRMs(),
            frequency: 3,
            startDate: .now
        )

        let week9 = try XCTUnwrap(meso.weeks.first { $0.weekNumber == 9 })
        XCTAssertFalse(week9.isDeload)
        let assignments = try XCTUnwrap(week9.days.first).liftAssignments()
        XCTAssertTrue(assignments.allSatisfy { $0.sets == 5 && $0.reps == 5 && $0.intensityPct == 85 })
    }

    func testPeakingPhaseProgressesRepsDownAndIntensityUp() throws {
        let meso = BlockGenerator.generateMesocycle(
            oneRMs: uniformOneRMs(weight: 200),
            frequency: 3,
            startDate: .now
        )

        let w10 = try XCTUnwrap(meso.weeks.first { $0.weekNumber == 10 })
        let w11 = try XCTUnwrap(meso.weeks.first { $0.weekNumber == 11 })
        let w12 = try XCTUnwrap(meso.weeks.first { $0.weekNumber == 12 })

        let a10 = try XCTUnwrap(w10.days.first).liftAssignments().first
        let a11 = try XCTUnwrap(w11.days.first).liftAssignments().first
        let a12 = try XCTUnwrap(w12.days.first).liftAssignments().first

        XCTAssertEqual(a10?.sets, 5)
        XCTAssertEqual(a10?.reps, 5)
        XCTAssertEqual(a10?.intensityPct, 87)

        XCTAssertEqual(a11?.reps, 4)
        XCTAssertEqual(a11?.intensityPct, 90)

        XCTAssertEqual(a12?.reps, 3)
        XCTAssertEqual(a12?.intensityPct, 95)
    }

    func testMesocyclePersistsThroughSwiftDataRoundTrip() throws {
        let container = try P4CESchema.testingContainer()
        let context = ModelContext(container)

        let meso = BlockGenerator.generateMesocycle(
            oneRMs: uniformOneRMs(),
            frequency: 3,
            startDate: .now
        )

        context.insert(meso)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Mesocycle>())
        XCTAssertEqual(fetched.count, 1)

        let loaded = try XCTUnwrap(fetched.first)
        XCTAssertEqual(loaded.weeks.count, 12)
        XCTAssertEqual(loaded.weeks.filter(\.isDeload).map(\.weekNumber).sorted(), [4, 8])
    }
}
