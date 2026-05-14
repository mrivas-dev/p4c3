import SwiftUI

/// Fast set logger — digit pad only, optional RPE, no keyboard (P4CE-14).
struct LogSetSheet: View {
    @Environment(\.dismiss)
    private var dismiss

    @EnvironmentObject
    private var workoutViewModel: WorkoutViewModel

    let exercise: WorkoutExercise

    /// Countdown length after a successful log.
    let restSeconds: Int

    var onLogged: () -> Void

    @State
    private var weightKg = 60.0

    @State
    private var reps = 5

    @State
    private var selectedRPE: Double?

    @State
    private var weightTyping = ""

    @State
    private var repsTyping = ""

    @State
    private var numpadFocus: WeightRepsField = .weight

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.space4.value) {
                        Text(exercise.name)
                            .font(Font.appSans(size: 20, weight: .bold))
                            .foregroundStyle(Color.P4CE.text)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        WeightRepsPicker(
                            weightKg: $weightKg,
                            reps: $reps,
                            weightTyping: $weightTyping,
                            repsTyping: $repsTyping,
                            focused: $numpadFocus
                        )

                        SectionHeader(title: "RPE (optional)")
                            .padding(.top, AppSpacing.space2.value)

                        rpeRow
                    }
                    .padding(.horizontal, AppSpacing.space4.value)
                    .padding(.top, AppSpacing.space3.value)
                }

                PrimaryButton(title: "LOG SET", action: logSet)
                    .padding(.horizontal, AppSpacing.space4.value)
                    .padding(.bottom, AppSpacing.space4.value)
                    .padding(.top, AppSpacing.space2.value)
                    .background(Color.P4CE.bg.opacity(0.96))
            }
            .navigationTitle("Log set")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.P4CE.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.P4CE.textDim)
                }
            }
            .background(Color.P4CE.bg)
        }
        .onAppear {
            seedDefaults(from: exercise)
        }
    }

    private var rpeRow: some View {
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 52), spacing: AppSpacing.space2.value)
            ],
            spacing: AppSpacing.space2.value
        ) {
            Button {
                selectedRPE = nil
            } label: {
                Text("Skip")
                    .font(Font.appSans(size: 14, weight: .medium))
                    .foregroundStyle(selectedRPE == nil ? Color.P4CE.limeInk : Color.P4CE.text)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(selectedRPE == nil ? Color.P4CE.lime : Color.P4CE.surf)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm.value, style: .continuous))
            }

            ForEach(1 ... 10, id: \.self) { value in
                let picked = selectedRPE == Double(value)

                Button {
                    selectedRPE = Double(value)
                } label: {
                    Text("\(value)")
                        .font(Font.appSans(size: 16, weight: .semibold))
                        .foregroundStyle(picked ? Color.P4CE.limeInk : Color.P4CE.text)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(picked ? Color.P4CE.lime : Color.P4CE.surfHi)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm.value, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppRadius.sm.value, style: .continuous)
                                .strokeBorder(Color.P4CE.lineSoft, lineWidth: AppLayout.hairlineBorderWidth)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("RPE \(value)")
                .accessibilityValue(picked ? "Selected" : "Not selected")
            }
        }
    }

    private func seedDefaults(from exercise: WorkoutExercise) {
        if let latest = exercise.sets.max(by: { $0.timestamp < $1.timestamp }) {
            weightKg = latest.weight
            reps = latest.reps
            selectedRPE = latest.rpe
        } else {
            weightKg = 60
            reps = 5
            selectedRPE = nil
        }
        weightTyping = ""
        repsTyping = ""
        numpadFocus = .weight
    }

    private func logSet() {
        WeightRepsPicker.mergeTypingIntoValues(
            weightTyping: &weightTyping,
            repsTyping: &repsTyping,
            weightKg: &weightKg,
            reps: &reps
        )

        let sanitized = WeightRepsPicker.sanitizeForSave(weightKg: weightKg, reps: reps)
        workoutViewModel.addSet(to: exercise, weight: sanitized.0, reps: sanitized.1, rpe: selectedRPE)

        dismiss()
        onLogged()
    }
}
