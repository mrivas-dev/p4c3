import Foundation
import SwiftData

enum LiftOneRMSource: String, Codable, CaseIterable {
    case tested
    case estimated
}

/// Per-lift tested and estimated one-rep maxima for the strength engine (`P4CE-19`).
@Model
final class LiftOneRM {
    var id: UUID

    @Attribute(.unique)
    var liftName: String

    var testedRM: Double?

    var estimatedRM: Double?

    var updatedAt: Date

    var sourceRaw: String

    var source: LiftOneRMSource {
        get { LiftOneRMSource(rawValue: sourceRaw) ?? .estimated }
        set { sourceRaw = newValue.rawValue }
    }

    /// Working max uses the higher of tested vs estimated (kg).
    var workingRM: Double {
        max(testedRM ?? 0, estimatedRM ?? 0)
    }

    init(
        id: UUID = UUID(),
        liftName: String,
        testedRM: Double? = nil,
        estimatedRM: Double? = nil,
        updatedAt: Date = Date(),
        source: LiftOneRMSource = .estimated
    ) {
        self.id = id
        self.liftName = liftName
        self.testedRM = testedRM
        self.estimatedRM = estimatedRM
        self.updatedAt = updatedAt
        sourceRaw = source.rawValue
    }
}

extension LiftOneRM {
    static func fetchOrInsert(liftName: String, context: ModelContext) throws -> LiftOneRM {
        let name = liftName
        var descriptor = FetchDescriptor<LiftOneRM>(
            predicate: #Predicate { $0.liftName == name }
        )
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let row = LiftOneRM(liftName: liftName)
        context.insert(row)
        return row
    }

    /// Updates the running estimated 1RM from a logged set (reps 1…10 only).
    static func applyEstimatedFromSet(liftName: String, weight: Double, reps: Int, context: ModelContext) throws {
        guard (1 ... 10).contains(reps) else { return }
        let candidate = OneRMCalculator.epley(weight: weight, reps: reps)
        let row = try fetchOrInsert(liftName: liftName, context: context)
        let current = row.estimatedRM ?? 0
        guard OneRMCalculator.shouldUpdate(current: current, new: candidate) else { return }
        row.estimatedRM = candidate
        row.source = .estimated
        row.updatedAt = Date()
    }

    /// Mirrors a manually entered tested 1RM from settings/onboarding (kg). Passing `nil` clears tested.
    static func syncTested(liftName: String, testedKg: Double?, context: ModelContext) throws {
        if let kg = testedKg, kg > 0 {
            let row = try fetchOrInsert(liftName: liftName, context: context)
            row.testedRM = kg
            row.source = .tested
            row.updatedAt = Date()
            return
        }

        let name = liftName
        var descriptor = FetchDescriptor<LiftOneRM>(
            predicate: #Predicate { $0.liftName == name }
        )
        descriptor.fetchLimit = 1
        guard let row = try context.fetch(descriptor).first else { return }
        row.testedRM = nil
        row.updatedAt = Date()
        if row.estimatedRM == nil {
            context.delete(row)
        }
    }
}
