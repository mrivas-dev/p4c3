import Foundation
import SwiftUI

/// Field focus for the custom numpad (P4CE-14).
enum WeightRepsField: String, Hashable {
    case weight
    case reps
}

/// Digit-only picker for plate math — avoids the system keyboard (P4CE-14).
struct WeightRepsPicker: View {
    @Binding var weightKg: Double
    @Binding var reps: Int
    @Binding var weightTyping: String
    @Binding var repsTyping: String
    @Binding var focused: WeightRepsField

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.space4.value) {
            HStack(spacing: AppSpacing.space3.value) {
                fieldChip(field: .weight, title: "Weight", subtitle: "(kg)") {
                    weightDisplayLabel
                }
                fieldChip(field: .reps, title: "Reps") {
                    repsDisplayLabel
                }
            }

            keypad
        }
        .frame(maxWidth: .infinity)
    }

    private var weightDisplayLabel: String {
        if focused == .weight, !weightTyping.isEmpty {
            return weightTyping
        }
        return Self.displayWeight(weightKg)
    }

    private var repsDisplayLabel: String {
        if focused == .reps, !repsTyping.isEmpty {
            return repsTyping
        }
        return "\(reps)"
    }

    private func fieldChip(
        field: WeightRepsField,
        title: String,
        subtitle: String? = nil,
        value: @escaping () -> String
    ) -> some View {
        let picked = focused == field
        return Button {
            focused = field
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.space1.value) {
                HStack(spacing: AppSpacing.space1.value) {
                    Text(title)
                        .font(Font.Style.metadataCaps)
                        .tracking(Font.Tracking.metadataCapsHigh)
                        .foregroundStyle(Color.P4CE.muted)
                    if let subtitle {
                        Text(subtitle)
                            .font(Font.Style.metadataCaps)
                            .tracking(Font.Tracking.metadataCapsHigh)
                            .foregroundStyle(Color.P4CE.dim)
                    }
                }
                Text(value())
                    .font(Font.appSans(size: 28, weight: .bold))
                    .foregroundStyle(Color.P4CE.text)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.space3.value)
            .background(Color.P4CE.surfHi.opacity(picked ? 0.95 : 0.5))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md.value, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md.value, style: .continuous)
                    .strokeBorder(picked ? Color.P4CE.lime : Color.P4CE.lineSoft, lineWidth: picked ? 2 : AppLayout.hairlineBorderWidth)
            )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint("Switch numpad to edit \(title.lowercased())")
    }

    private var keypad: some View {
        VStack(spacing: AppSpacing.space2.value) {
            keypadRow(keys: ["7", "8", "9"])
            keypadRow(keys: ["4", "5", "6"])
            keypadRow(keys: ["1", "2", "3"])

            HStack(spacing: AppSpacing.space2.value) {
                actionKey(symbol: "⌫", foreground: Color.P4CE.amber, action: deleteLast)
                digitKey("0")
                if focused == .weight {
                    actionKey(symbol: ".", foreground: Color.P4CE.textDim, action: insertDotIfAllowed)
                } else {
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: AppLayout.minimumTouchTarget)
                }
            }
        }
    }

    private func keypadRow(keys: [String]) -> some View {
        HStack(spacing: AppSpacing.space2.value) {
            ForEach(keys, id: \.self) { digitKey($0) }
        }
    }

    private func digitKey(_ digit: String) -> some View {
        actionKey(symbol: digit, foreground: Color.P4CE.text) {
            appendDigit(digit)
        }
    }

    private func actionKey(symbol: String, foreground: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(symbol)
                .font(Font.appSans(size: 24, weight: .semibold))
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .frame(height: AppLayout.minimumTouchTarget)
                .background(Color.P4CE.surf)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm.value, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilitySymbolLabel(symbol))
    }

    /// Call before persisting — snaps kg to ½ kg plates and clamps reps.
    static func sanitizeForSave(weightKg: Double, reps: Int) -> (Double, Int) {
        let w = clampWeight(weightKg)
        let r = clampReps(reps)
        return (snapPlateKg(w), max(1, r))
    }

    /// Flushes any in-progress digit strings into the numeric bindings.
    static func mergeTypingIntoValues(
        weightTyping: inout String,
        repsTyping: inout String,
        weightKg: inout Double,
        reps: inout Int
    ) {
        if !weightTyping.isEmpty {
            if let rounded = materializeTypingIntoWeight(weightTyping) {
                weightKg = rounded
            }
            weightTyping = ""
        }
        if !repsTyping.isEmpty, let parsed = Int(repsTyping), parsed > 0 {
            reps = clampReps(parsed)
            repsTyping = ""
        }
    }

    static func materializeTypingIntoWeight(_ typing: String) -> Double? {
        var raw = typing.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }
        if raw.hasSuffix(".") {
            raw.removeLast()
        }
        guard let value = Double(raw) else { return nil }
        return snapPlateKg(clampWeight(value))
    }

    private func appendDigit(_ ch: String) {
        guard ch.count == 1,
              ch.unicodeScalars.allSatisfy({ CharacterSet.decimalDigits.contains($0) }) else { return }
        switch focused {
        case .weight:
            if weightTyping.count >= 6 {
                return
            }
            if weightTyping == "0" {
                weightTyping = ch
            } else {
                weightTyping.append(ch)
            }
            flushWeightTypingIfParsable(includeTrailingDot: false)
        case .reps:
            guard repsTyping.count < 3 else { return }
            if repsTyping == "0" {
                repsTyping = ch
            } else {
                repsTyping.append(ch)
            }
            flushRepsTyping()
        }
    }

    private func deleteLast() {
        switch focused {
        case .weight:
            guard !weightTyping.isEmpty else { return }
            weightTyping.removeLast()
            flushWeightTypingIfParsable(includeTrailingDot: false)
        case .reps:
            guard !repsTyping.isEmpty else { return }
            repsTyping.removeLast()
            flushRepsTyping()
        }
    }

    private func insertDotIfAllowed() {
        guard focused == .weight else { return }
        if weightTyping.contains(".") { return }
        if weightTyping.isEmpty {
            weightTyping = "0."
        } else {
            weightTyping.append(".")
        }
    }

    private func flushWeightTypingIfParsable(includeTrailingDot: Bool) {
        guard !weightTyping.isEmpty else { return }

        let rawCandidate: String
        if weightTyping.last == ".", includeTrailingDot {
            rawCandidate = String(weightTyping.dropLast())
        } else if weightTyping.last == "." {
            return
        } else {
            rawCandidate = weightTyping
        }

        guard let value = Double(rawCandidate) else { return }

        weightKg = Self.snapPlateKg(Self.clampWeight(value))
    }

    private func flushRepsTyping() {
        guard let parsed = Int(repsTyping), parsed > 0 else { return }
        reps = Self.clampReps(parsed)
    }

    private static func snapPlateKg(_ value: Double) -> Double {
        (value / 0.5).rounded() * 0.5
    }

    private static func clampWeight(_ value: Double) -> Double {
        min(600.0, max(0, value))
    }

    fileprivate static func clampReps(_ value: Int) -> Int {
        min(999, max(1, value))
    }

    private static func displayWeight(_ kg: Double) -> String {
        let snapped = snapPlateKg(kg)
        let frac = abs(snapped.truncatingRemainder(dividingBy: 1))
        let digits = frac < .ulpOfOne ? 0 : 1
        return snapped.formatted(.number.precision(.fractionLength(digits)))
    }

    private func accessibilitySymbolLabel(_ symbol: String) -> String {
        switch symbol {
        case "⌫":
            String(localized: "Delete")
        case ".":
            String(localized: "Decimal separator")
        default:
            symbol
        }
    }
}

private struct WeightRepsPickerPreviewHarness: View {
    @State private var w = 100.5
    @State private var r = 3
    @State private var wt = ""
    @State private var rt = ""
    @State private var focus: WeightRepsField = .weight

    var body: some View {
        ScrollView {
            WeightRepsPicker(weightKg: $w, reps: $r, weightTyping: $wt, repsTyping: $rt, focused: $focus)
                .padding(AppSpacing.space4.value)
        }
        .background(Color.P4CE.bg)
    }
}

#Preview("WeightRepsPicker") {
    WeightRepsPickerPreviewHarness()
        .preferredColorScheme(.dark)
}
