import Foundation

enum BlockGenerator {
    /// Gregorian weekday indices for Monday / Wednesday / Friday (`Calendar` semantics).
    static let threeDayWeekdayIndices: [Int] = [2, 4, 6]

    /// Primary lift pairings for the default 3-day split (`P4CE-20`).
    static let threeDayLiftPairings: [[String]] = [
        [CoreLift.snatch.rawValue, CoreLift.backSquat.rawValue],
        [CoreLift.cleanAndJerk.rawValue, CoreLift.deadlift.rawValue],
        [CoreLift.frontSquat.rawValue, CoreLift.benchPress.rawValue],
    ]

    static func isDeloadWeek(_ week: Int) -> Bool {
        week == 4 || week == 8
    }

    static func prescribedWeight(oneRM: Double, pct: Double) -> Double {
        guard oneRM > 0 else { return 0 }
        let rawKg = oneRM * (pct / 100.0)
        return (rawKg / 2.5).rounded() * 2.5
    }

    /// Builds an in-memory mesocycle graph (not inserted into a ``ModelContext``).
    static func generateMesocycle(
        oneRMs: [String: Double],
        frequency: Int,
        startDate: Date
    ) -> Mesocycle {
        precondition(frequency == 3, "Only the Mon/Wed/Fri schedule is implemented.")

        let liftNames = Set(threeDayLiftPairings.flatMap(\.self)).sorted()
        let meso = Mesocycle(
            startDate: startDate,
            lifts: liftNames,
            currentWeek: 1,
            currentBlock: phase(forWeekNumber: 1)
        )

        for weekNumber in 1 ... 12 {
            let phase = phase(forWeekNumber: weekNumber)
            let deload = isDeloadWeek(weekNumber)
            let prescription = weeklyPrescription(weekNumber: weekNumber)

            let trainingWeek = TrainingWeek(
                weekNumber: weekNumber,
                isDeload: deload,
                phase: phase,
                mesocycle: meso
            )

            for (index, weekday) in threeDayWeekdayIndices.enumerated() {
                let pairing = threeDayLiftPairings[index]
                let assignments = pairing.map { liftName in
                    LiftAssignment(
                        liftName: liftName,
                        sets: prescription.sets,
                        reps: prescription.reps,
                        intensityPct: prescription.intensityPct,
                        prescribedWeight: prescribedWeight(
                            oneRM: oneRMs[liftName] ?? 0,
                            pct: prescription.intensityPct
                        )
                    )
                }

                let day = TrainingDay(dayOfWeek: weekday, assignments: assignments, week: trainingWeek)
                trainingWeek.days.append(day)
            }

            meso.weeks.append(trainingWeek)
        }

        return meso
    }

    static func phase(forWeekNumber week: Int) -> TrainingPhase {
        switch week {
        case 1 ... 4:
            return .accumulation
        case 5 ... 9:
            return .intensification
        default:
            return .peaking
        }
    }

    static func weeklyPrescription(weekNumber: Int) -> (sets: Int, reps: Int, intensityPct: Double) {
        if isDeloadWeek(weekNumber) {
            return (3, 5, 60)
        }

        switch weekNumber {
        case 1:
            return (4, 8, 65)
        case 2:
            return (4, 8, 68)
        case 3:
            return (4, 8, 70)
        case 5:
            return (5, 5, 75)
        case 6:
            return (5, 5, 78)
        case 7:
            return (5, 5, 80)
        case 9:
            return (5, 5, 85)
        case 10:
            return (5, 5, 87)
        case 11:
            return (5, 4, 90)
        case 12:
            return (5, 3, 95)
        default:
            preconditionFailure("Mesocycle supports weeks 1…12 only.")
        }
    }
}
