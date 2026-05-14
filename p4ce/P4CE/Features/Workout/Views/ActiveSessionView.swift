import SwiftData
import SwiftUI

/// Live workout surface — exercises for the persisted session referenced by ``WorkoutViewModel``.
struct ActiveSessionView: View {
    @Bindable var session: WorkoutSession

    private var orderedExercises: [WorkoutExercise] {
        session.exercises.sorted { $0.order < $1.order }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: AppSpacing.space2.value) {
                    Text("Active session")
                        .font(Font.Style.metadataCaps)
                        .tracking(Font.Tracking.metadataCapsHigh)
                        .foregroundStyle(Color.P4CE.muted)
                    Text(session.date.formatted(date: .abbreviated, time: .shortened))
                        .font(Font.Style.sectionDate)
                        .tracking(Font.Tracking.sectionDate)
                        .foregroundStyle(Color.P4CE.text)
                }
                .listRowBackground(Color.P4CE.surfHi.opacity(0.45))
            }

            Section("Movements") {
                ForEach(orderedExercises) { exercise in
                    ExerciseSessionRow(exercise: exercise)
                        .listRowBackground(Color.P4CE.surfHi.opacity(0.45))
                        .listRowSeparatorTint(Color.P4CE.lineSoft)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.P4CE.bg)
    }
}

private struct ExerciseSessionRow: View {
    let exercise: WorkoutExercise

    var body: some View {
        HStack(spacing: AppSpacing.space3.value) {
            VStack(alignment: .leading, spacing: AppSpacing.space1.value) {
                Text(exercise.name)
                    .font(Font.appSans(size: 16, weight: .semibold))
                    .foregroundStyle(Color.P4CE.text)

                Text(subtitleText)
                    .font(Font.Style.sessionName)
                    .foregroundStyle(Color.P4CE.textDim)
            }
            Spacer(minLength: 0)
        }
        .frame(minHeight: 52)
        .accessibilityElement(children: .combine)
    }

    private var subtitleText: String {
        let sets = exercise.sets.count
        if sets == 0 {
            return "No sets yet"
        }
        return "\(sets) set\(sets == 1 ? "" : "s") logged"
    }
}
