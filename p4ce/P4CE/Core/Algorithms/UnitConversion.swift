import Foundation

/// Display-only conversions; persisted weights remain kilograms (`IA-P4CE-8.md`).
enum UnitConversion {
    private static let poundsPerKilogram = 2.204_622_621_8

    static func displayValue(forKg kg: Double, unit: UnitSystem) -> Double {
        switch unit {
        case .kg: kg
        case .lb: kg * poundsPerKilogram
        }
    }

    static func kilograms(forDisplay display: Double, unit: UnitSystem) -> Double {
        switch unit {
        case .kg: display
        case .lb: display / poundsPerKilogram
        }
    }

    static func incrementDisplay(for unit: UnitSystem) -> Double {
        unit == .kg ? 2.5 : 5
    }

    static func formatLiftDisplay(forKg kg: Double, unit: UnitSystem) -> String {
        let v = displayValue(forKg: kg, unit: unit)
        let s = trailingTrimmed(String(format: "%.2f", v))
        return "\(s) \(unit.rawValue.uppercased())"
    }

    static func kg(fromDisplayInput text: String, unit: UnitSystem) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        guard let display = Double(normalized) else { return nil }
        return kilograms(forDisplay: display, unit: unit)
    }

    static func trimmedDisplayDecimalString(forKg kg: Double, unit: UnitSystem) -> String {
        trailingTrimmed(String(format: "%.2f", displayValue(forKg: kg, unit: unit)))
    }

    static func trimmedDisplayDecimalString(forDisplay display: Double) -> String {
        trailingTrimmed(String(format: "%.2f", display))
    }

    static func nearlyEqualKg(_ lhs: Double, _ rhs: Double, epsilon: Double = 0.005) -> Bool {
        abs(lhs - rhs) < epsilon
    }

    private static func trailingTrimmed(_ numeric: String) -> String {
        var s = numeric
        while s.contains(".") && (s.hasSuffix("0") || s.hasSuffix(".")) {
            if s.hasSuffix(".") {
                s.removeLast()
                break
            }
            s.removeLast()
        }
        return s.isEmpty ? "0" : s
    }
}
