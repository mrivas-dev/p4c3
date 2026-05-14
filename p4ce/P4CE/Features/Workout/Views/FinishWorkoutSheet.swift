import SwiftData
import SwiftUI

/// Confirmation + summary before persisting a finished session (P4CE-15).
struct FinishWorkoutSheet: View {
    @Environment(\.dismiss)
    private var dismiss

    @Environment(\.switchToDashboardTab)
    private var switchToDashboardTab

    @EnvironmentObject
    private var workoutViewModel: WorkoutViewModel

    @Bindable
    var session: WorkoutSession

    /// Wall-clock session length at save time — closure so Save uses up-to-date elapsed while the sheet is open.
    let currentElapsed: () -> TimeInterval

    private var orderedExercises: [WorkoutExercise] {
        session.exercises.sorted { $0.order < $1.order }
    }

    private var totalSets: Int {
        WorkoutSessionMetrics.totalSets(for: session)
    }

    private var totalVolume: Double {
        WorkoutSessionMetrics.totalVolume(for: session)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.space4.value) {
                        summaryGrid

                        Text("Exercises")
                            .font(Font.Style.metadataCaps)
                            .tracking(Font.Tracking.metadataCapsHigh)
                            .foregroundStyle(Color.P4CE.muted)

                        VStack(spacing: AppSpacing.space2.value) {
                            ForEach(orderedExercises) { exercise in
                                exerciseRow(exercise)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppSpacing.space4.value)
                    .padding(.top, AppSpacing.space2.value)
                    .padding(.bottom, AppSpacing.space4.value)
                }

                VStack(spacing: AppSpacing.space3.value) {
                    PrimaryButton(title: "SAVE WORKOUT", action: saveAndGoHome)

                    Button(action: { dismiss() }) {
                        Text("Keep Going")
                            .font(Font.appSans(size: 15, weight: .semibold))
                            .foregroundStyle(Color.P4CE.lime)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: AppLayout.minimumTouchTarget)
                            .background(Color.P4CE.surfHi)
                            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg.value, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppRadius.lg.value, style: .continuous)
                                    .strokeBorder(Color.P4CE.line, lineWidth: AppLayout.hairlineBorderWidth)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Continue this workout without saving")
                }
                .padding(.horizontal, AppSpacing.space4.value)
                .padding(.bottom, AppSpacing.space4.value)
                .padding(.top, AppSpacing.space2.value)
                .background(Color.P4CE.bg.opacity(0.98))
            }
            .background(Color.P4CE.bg)
            .navigationTitle("Finish workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.P4CE.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private var summaryGrid: some View {
        VStack(spacing: AppSpacing.space3.value) {
            summaryTile(title: "Duration", value: formatElapsed(currentElapsed()))
            summaryTile(title: "Total sets", value: "\(totalSets)")
            summaryTile(title: "Volume", value: formatVolumeKg(totalVolume))
        }
        .padding(AppSpacing.space4.value)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.P4CE.surfHi.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg.value, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg.value, style: .continuous)
                .strokeBorder(Color.P4CE.lineSoft, lineWidth: AppLayout.hairlineBorderWidth)
        )
    }

    private func summaryTile(title: String, value: String) -> some View {
        HStack {
            Text(title.uppercased())
                .font(Font.appMono(size: 9, weight: .semibold))
                .tracking(Font.Tracking.metadataCapsHigh)
                .foregroundStyle(Color.P4CE.muted)
            Spacer(minLength: 0)
            Text(value)
                .font(Font.appSans(size: 17, weight: .semibold))
                .foregroundStyle(Color.P4CE.text)
                .monospacedDigit()
        }
    }

    private func exerciseRow(_ exercise: WorkoutExercise) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(exercise.name)
                .font(Font.appSans(size: 16, weight: .medium))
                .foregroundStyle(Color.P4CE.text)
            Spacer(minLength: 0)
            Text("\(exercise.sets.count) sets")
                .font(Font.appSans(size: 14, weight: .medium))
                .foregroundStyle(Color.P4CE.textDim)
                .monospacedDigit()
        }
        .padding(AppSpacing.space3.value)
        .background(Color.P4CE.surfHi.opacity(0.35))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md.value, style: .continuous))
    }

    private func saveAndGoHome() {
        workoutViewModel.finishSession(session, elapsed: currentElapsed())
        dismiss()
        switchToDashboardTab()
    }

    private func formatElapsed(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded(.down)))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func formatVolumeKg(_ kg: Double) -> String {
        let rounded = (kg * 10).rounded() / 10
        return "\(rounded.formatted(.number.precision(.fractionLength(0...1)))) kg"
    }
}
