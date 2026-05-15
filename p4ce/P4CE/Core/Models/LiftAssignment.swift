import Foundation

/// Prescription for a single lift on a scheduled training day (`P4CE-20`).
struct LiftAssignment: Codable, Equatable, Hashable, Sendable {
    var liftName: String

    var sets: Int

    var reps: Int

    /// Working intensity as a fraction of 1RM (e.g. 72.5 means 72.5%).
    var intensityPct: Double

    /// Bar weight in kilograms, rounded to the nearest 2.5 kg plate increment.
    var prescribedWeight: Double
}
