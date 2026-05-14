import XCTest
@testable import P4CE

final class OneRMCalculatorTests: XCTestCase {
    func testEpley_fiveReps_matchesTicketExample() {
        let estimate = OneRMCalculator.epley(weight: 100, reps: 5)
        let expected = 100 * (1 + 5.0 / 30)
        XCTAssertEqual(estimate, expected, accuracy: 0.05)
    }

    func testEpley_oneRep_returnsWeight() {
        XCTAssertEqual(OneRMCalculator.epley(weight: 100, reps: 1), 100, accuracy: 0.001)
    }

    func testEpley_tenReps_usesFormula() {
        let estimate = OneRMCalculator.epley(weight: 80, reps: 10)
        XCTAssertEqual(estimate, 80 * (1 + 10.0 / 30), accuracy: 0.001)
    }

    func testEpley_zeroReps_returnsWeight() {
        XCTAssertEqual(OneRMCalculator.epley(weight: 100, reps: 0), 100, accuracy: 0.001)
    }

    func testEpley_elevenReps_returnsWeight() {
        XCTAssertEqual(OneRMCalculator.epley(weight: 100, reps: 11), 100, accuracy: 0.001)
    }

    func testShouldUpdate_respectsHalfKiloThreshold() {
        XCTAssertFalse(OneRMCalculator.shouldUpdate(current: 116, new: 116.4))
        XCTAssertTrue(OneRMCalculator.shouldUpdate(current: 116, new: 116.6))
    }
}
