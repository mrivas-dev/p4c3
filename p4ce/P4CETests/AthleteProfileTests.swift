import SwiftData
import XCTest
@testable import P4CE

@MainActor
final class UnitConversionTests: XCTestCase {
    func testDisplayAndBackKg() {
        XCTAssertEqual(UnitConversion.displayValue(forKg: 100, unit: .kg), 100, accuracy: 0.000_1)
        XCTAssertEqual(
            UnitConversion.kilograms(forDisplay: 220.462_26218, unit: .lb),
            100,
            accuracy: 0.000_01
        )
    }

    func testIncrementMagnitudes() {
        XCTAssertEqual(UnitConversion.incrementDisplay(for: .kg), 2.5)
        XCTAssertEqual(UnitConversion.incrementDisplay(for: .lb), 5)

        XCTAssertEqual(UnitConversion.kilograms(forDisplay: 2.5, unit: .kg), 2.5)
        XCTAssertEqual(
            UnitConversion.kilograms(forDisplay: 5.0, unit: .lb),
            5.0 / 2.204_622_621_8,
            accuracy: 1e-6
        )
    }

    func testKgParsesOptionalInput() throws {
        XCTAssertNil(UnitConversion.kg(fromDisplayInput: "", unit: .kg))
        XCTAssertNil(UnitConversion.kg(fromDisplayInput: "   ", unit: .lb))
        let kgFromComma = UnitConversion.kg(fromDisplayInput: "88,75", unit: .kg)!
        XCTAssertEqual(kgFromComma, 88.75)

        XCTAssertEqual(UnitConversion.trimmedDisplayDecimalString(forKg: 100.1, unit: .kg), "100.1")
        XCTAssertFalse(UnitConversion.nearlyEqualKg(100.1, 100.109))
        XCTAssert(UnitConversion.nearlyEqualKg(100.1, 100.099))
    }
}

@MainActor
final class OnboardingViewModelTests: XCTestCase {
    func testTrainingStepGateAllowsThreeToSix() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let ctx = ModelContext(
            try ModelContainer(for: AthleteProfile.self, LiftMax.self, configurations: cfg)
        )
        let profile = AthleteProfile()
        ctx.insert(profile)
        try ctx.save()

        let vm = OnboardingViewModel(profile: profile, modelContext: ctx)

        XCTAssertTrue(vm.canAdvancePastCurrentStep(0))

        XCTAssertTrue(vm.canAdvancePastCurrentStep(1))

        vm.trainingFrequency = 2
        XCTAssertFalse(vm.canAdvancePastCurrentStep(1))

        XCTAssertFalse(vm.canAdvancePastCurrentStep(2))
    }

    func testSkipLeavesLiftMaxUnset() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let ctx = ModelContext(
            try ModelContainer(for: AthleteProfile.self, LiftMax.self, configurations: cfg)
        )
        let profile = AthleteProfile()
        ctx.insert(profile)
        try ctx.save()

        let vm = OnboardingViewModel(profile: profile, modelContext: ctx)
        try vm.skipLiftMaxEntries()

        XCTAssertTrue(profile.onboardingCompleted)
        XCTAssertTrue(profile.liftMaxes.isEmpty)
    }

    func testLetsGoUpsertsSquat() throws {
        let cfg = ModelConfiguration(isStoredInMemoryOnly: true)
        let ctx = ModelContext(
            try ModelContainer(for: AthleteProfile.self, LiftMax.self, configurations: cfg)
        )
        let profile = AthleteProfile()
        ctx.insert(profile)
        try ctx.save()

        let vm = OnboardingViewModel(profile: profile, modelContext: ctx)
        vm.trainingFrequency = 5
        vm.liftInputs[.backSquat] = "100"
        try vm.completeWithEnteredLiftMaxes()

        XCTAssertTrue(profile.onboardingCompleted)
        XCTAssertEqual(profile.liftMaxes.count(where: { $0.lift == .backSquat }), 1)
        let squatKg = profile.liftMaxes.first(where: { $0.lift == .backSquat })?.oneRepMaxKg
        XCTAssertNotNil(squatKg)
        XCTAssertEqual(squatKg ?? 0, 100, accuracy: 0.001)
    }
}

@MainActor
final class OneRMEditViewModelTests: XCTestCase {
    func testBumpFromZeroKg() {
        let vm = OneRMEditViewModel(lift: .deadlift, initialKg: nil, unitPreference: .kg)
        vm.bump(step: .increase, unitPreference: .kg)

        XCTAssertEqual(vm.bumpDeltaKg(for: .kg), 2.5, accuracy: 0.001)
        XCTAssertEqual(vm.oneRepMaxKg, 2.5, accuracy: 0.001)

        vm.bump(step: .decrease, unitPreference: .kg)
        XCTAssertEqual(vm.oneRepMaxKg, 0, accuracy: 0.001)
    }

    func testBumpIncrementalLb() {
        let vm = OneRMEditViewModel(lift: .benchPress, initialKg: 100.0 / 2.204_622_621_8, unitPreference: .lb)
        XCTAssertEqual(UnitConversion.incrementDisplay(for: .lb), 5)

        let delta = vm.bumpDeltaKg(for: .lb)

        XCTAssertEqual(delta, UnitConversion.kilograms(forDisplay: 5.0, unit: .lb), accuracy: 1e-9)

        let beforeKg = vm.oneRepMaxKg
        vm.bump(step: .increase, unitPreference: .lb)
        XCTAssertGreaterThan(vm.oneRepMaxKg, beforeKg)
    }
}
