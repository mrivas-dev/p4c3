import SwiftData
import SwiftUI

/// Per-lift 1RM editor — `.sheet` from Settings (`P4CE-9`).
struct OneRMEditSheetView: View {
    let profile: AthleteProfile
    let lift: CoreLift

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var viewModel: OneRMEditViewModel

    init(profile: AthleteProfile, lift: CoreLift) {
        self.profile = profile
        self.lift = lift
        let kg = profile.liftMaxes.first(where: { $0.lift == lift })?.oneRepMaxKg
        _viewModel = State(
            wrappedValue: OneRMEditViewModel(
                lift: lift,
                initialKg: kg,
                unitPreference: profile.unitPreference
            )
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.space6.value) {
                    Text(lift.rawValue)
                        .font(Font.appDisplay(size: 24, weight: .bold))
                        .tracking(Font.Tracking.statsLarge)
                        .foregroundStyle(Color.P4CE.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, AppSpacing.space4.value)

                    Text("CURRENT 1RM")
                        .font(Font.appMono(size: 10, weight: .semibold))
                        .tracking(Font.Tracking.metadataCapsLow)
                        .foregroundStyle(Color.P4CE.dim)

                    Text(largeNumericDisplayText)
                        .font(Font.appDisplay(size: 36, weight: .bold).monospacedDigit())
                        .foregroundStyle(Color.P4CE.text)
                        .tracking(Font.Tracking.statsLarge)

                    SteppingRow { step in
                        viewModel.bump(step: step, unitPreference: profile.unitPreference)
                    }

                    TextField("", text: $viewModel.fieldText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(Font.Style.sectionDate.monospacedDigit())
                        .foregroundStyle(Color.P4CE.text)
                        .padding(AppSpacing.space3.value)
                        .background(Color.P4CE.surfHi.opacity(0.42))
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md.value))

                    PrimaryButton(title: "SAVE") {
                        saveTapped()
                    }
                    .padding(.top, AppSpacing.space4.value)

                    Button("Dismiss without saving") {
                        dismiss()
                    }
                    .font(Font.Style.sessionName)
                    .foregroundStyle(Color.P4CE.dim.opacity(0.75))
                    .padding(.top, AppSpacing.space2.value)
                }
                .padding(.horizontal, AppSpacing.space4.value)
                .padding(.bottom, AppSpacing.space8.value)
            }
            .background(Color.P4CE.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(Color.P4CE.textDim)
                    }
                    .accessibilityLabel("Cancel")
                    .frame(minWidth: AppLayout.minimumTouchTarget, minHeight: AppLayout.minimumTouchTarget)
                    .buttonStyle(.plain)
                }
            }
            .toolbarBackground(Color.P4CE.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.syncField(for: profile.unitPreference)
        }
        .onChange(of: profile.unitPreferenceRaw) { _, _ in
            viewModel.syncField(for: profile.unitPreference)
        }
    }

    /// Large headline reads from staged kg mapped into display preference.
    private var largeNumericDisplayText: String {
        guard viewModel.oneRepMaxKg > 0 else {
            return "—"
        }
        let display = UnitConversion.displayValue(forKg: viewModel.oneRepMaxKg, unit: profile.unitPreference)
        let num = UnitConversion.trimmedDisplayDecimalString(forDisplay: display)
        return "\(num) \(profile.unitPreference.rawValue.uppercased())"
    }

    private func saveTapped() {
        do {
            try viewModel.save(profile: profile, unitPreference: profile.unitPreference, context: modelContext)
            dismiss()
        } catch {}
    }
}

private struct SteppingRow: View {
    let bump: (OneRMEditViewModel.BumpStep) -> Void

    var body: some View {
        HStack(spacing: AppSpacing.space6.value) {
            stepChip(icon: "minus.circle.fill") { bump(.decrease) }
            Spacer()
            stepChip(icon: "plus.circle.fill") { bump(.increase) }
        }
        .padding(.vertical, AppSpacing.space2.value)
    }

    private func stepChip(icon: String, handler: @escaping () -> Void) -> some View {
        Button(action: handler) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .medium))
                .foregroundStyle(icon.contains("minus") ? Color.P4CE.dim : Color.P4CE.text)
                .frame(width: AppLayout.stepperButtonSide, height: AppLayout.stepperButtonSide)
                .background(Color.P4CE.surfHi.opacity(0.72))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(icon.contains("minus") ? "Decrease 1RM" : "Increase 1RM")
    }
}
