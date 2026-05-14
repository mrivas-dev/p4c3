import SwiftData
import SwiftUI

/// Finished sessions grouped by calendar week (P4CE-16).
struct WorkoutHistoryView: View {
    private struct WeekSection: Identifiable {
        let id: UUID
        let weekLabel: String
        let sessions: [WorkoutSession]
    }

    @Query(
        filter: #Predicate<WorkoutSession> { $0.statusRaw == "finished" },
        sort: \WorkoutSession.date,
        order: .reverse
    )
    private var finishedSessions: [WorkoutSession]

    @State
    private var expandedSessionIDs: Set<UUID> = []

    private var grouped: [(weekLabel: String, sessions: [WorkoutSession])] {
        WorkoutHistoryViewModel.groupByWeek(sessions: finishedSessions)
    }

    private var weekSections: [WeekSection] {
        grouped.compactMap { tuple in
            guard let id = tuple.sessions.first?.id else { return nil }
            return WeekSection(id: id, weekLabel: tuple.weekLabel, sessions: tuple.sessions)
        }
    }

    var body: some View {
        Group {
            if finishedSessions.isEmpty {
                emptyState
            } else {
                historyList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.P4CE.bg.ignoresSafeArea())
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.P4CE.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var emptyState: some View {
        VStack {
            Spacer(minLength: 0)
            Text("No workouts yet")
                .font(Font.Style.sessionName)
                .foregroundStyle(Color.P4CE.textDim)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.space4.value)
                .accessibilityLabel("No workouts yet")
            Spacer(minLength: 0)
        }
    }

    private var historyList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: AppSpacing.space6.value) {
                ForEach(weekSections) { group in
                    VStack(alignment: .leading, spacing: AppSpacing.space3.value) {
                        Text(group.weekLabel.uppercased())
                            .font(Font.appMono(size: 10, weight: .semibold))
                            .tracking(Font.Tracking.metadataCapsHigh)
                            .foregroundStyle(Color.P4CE.muted)
                            .accessibilityAddTraits(.isHeader)

                        ForEach(group.sessions, id: \.id) { session in
                            sessionRow(session)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.space4.value)
            .padding(.vertical, AppSpacing.space3.value)
        }
    }

    private func sessionRow(_ session: WorkoutSession) -> some View {
        let expanded = expandedSessionIDs.contains(session.id)
        let volume = WorkoutSessionMetrics.totalVolume(for: session)
        let tonnes = volume / 1000
        let volLabel = String(format: "%.1f", tonnes) + "t"
        let exerciseCount = session.exercises.count

        return VStack(alignment: .leading, spacing: AppSpacing.space2.value) {
            Button {
                if expanded {
                    expandedSessionIDs.remove(session.id)
                } else {
                    expandedSessionIDs.insert(session.id)
                }
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: AppSpacing.space3.value) {
                    Image(systemName: expanded ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.P4CE.muted)
                        .frame(width: 12)

                    VStack(alignment: .leading, spacing: AppSpacing.space1.value) {
                        Text(session.date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                            .font(Font.appDisplay(size: 16, weight: .semibold))
                            .foregroundStyle(Color.P4CE.text)

                        Text("\(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s") · \(volLabel) vol")
                            .font(Font.Style.sessionName)
                            .foregroundStyle(Color.P4CE.textDim)
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Workout on \(session.date.formatted(date: .abbreviated, time: .omitted))")
            .accessibilityHint(expanded ? "Double tap to collapse details." : "Double tap to expand details.")

            if expanded {
                exerciseBreakdown(session)
                    .padding(.leading, AppSpacing.space4.value + 12)
            }
        }
        .padding(AppSpacing.space3.value)
        .background(Color.P4CE.surfHi.opacity(0.65))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md.value, style: .continuous)
                .strokeBorder(Color.P4CE.lineSoft, lineWidth: AppLayout.hairlineBorderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md.value, style: .continuous))
    }

    private func exerciseBreakdown(_ session: WorkoutSession) -> some View {
        let exercises = session.exercises.sorted { $0.order < $1.order }
        return VStack(alignment: .leading, spacing: AppSpacing.space3.value) {
            ForEach(exercises, id: \.id) { exercise in
                VStack(alignment: .leading, spacing: AppSpacing.space1.value) {
                    Text(exercise.name)
                        .font(Font.appSans(size: 14, weight: .semibold))
                        .foregroundStyle(Color.P4CE.text)

                    let sets = exercise.sets.sorted { $0.timestamp < $1.timestamp }
                    if sets.isEmpty {
                        Text("No sets logged")
                            .font(Font.appMono(size: 11, weight: .regular))
                            .foregroundStyle(Color.P4CE.muted)
                    } else {
                        ForEach(sets, id: \.id) { set in
                            Text(setLine(set))
                                .font(Font.appMono(size: 12, weight: .regular))
                                .foregroundStyle(Color.P4CE.textDim)
                        }
                    }
                }
            }
        }
        .padding(.top, AppSpacing.space2.value)
    }

    private func setLine(_ set: SetEntry) -> String {
        let w = formatWeight(set.weight)
        return "\(w) × \(set.reps) reps"
    }

    private func formatWeight(_ kg: Double) -> String {
        let rounded = (kg * 10).rounded() / 10
        if abs(rounded - rounded.rounded()) < 0.001 {
            return "\(Int(rounded)) kg"
        }
        return String(format: "%.1f kg", kg)
    }
}

#Preview("WorkoutHistoryView — empty") {
    NavigationStack {
        WorkoutHistoryView()
    }
    .modelContainer(try! P4CESchema.previewContainer())
    .preferredColorScheme(.dark)
}
