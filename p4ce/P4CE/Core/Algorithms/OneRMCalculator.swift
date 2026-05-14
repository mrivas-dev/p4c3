import Foundation

/// Epley-based 1RM estimation — pure functions only (`P4CE-19`).
enum OneRMCalculator {
    /// `estimated1RM = weight × (1 + reps / 30)` for reps 2…10; **reps 1** returns `weight` (the recorded single).
    static func epley(weight: Double, reps: Int) -> Double {
        guard (1 ... 10).contains(reps) else { return weight }
        if reps == 1 { return weight }
        return weight * (1 + Double(reps) / 30)
    }

    /// Only replace stored estimate if the new value is higher by more than 0.5 kg.
    static func shouldUpdate(current: Double, new: Double) -> Bool {
        new - current > 0.5
    }
}
