import SwiftData
import SwiftUI

private enum SessionClock {
    static func tick(
        banked: TimeInterval,
        anchor: Date?
    ) -> TimeInterval {
        let running = anchor.map { max(0, Date().timeIntervalSince($0)) } ?? 0
        return banked + running
    }
}

/// Heart of workout logging — fast set entry plus rest pacing (P4CE-14).
struct ActiveSessionView: View {
    @Bindable var session: WorkoutSession

    @EnvironmentObject
    private var workoutViewModel: WorkoutViewModel

    @Environment(\.scenePhase)
    private var scenePhase

    @State
    private var bankedElapsed: TimeInterval = 0

    @State
    private var foregroundAnchor: Date?

    @State
    private var tickToken = UUID()

    @State
    private var logExercise: WorkoutExercise?

    @State
    private var restDeadline: Date?

    @State
    private var showFinishWorkoutSheet = false

    /// Default coach rest cue after logging a heavy set — aligned with sprint wireframe (~90 s).
    private let restDurationSeconds = 90

    private let tick = Timer.publish(every: 1, tolerance: 0.2, on: .main, in: .common).autoconnect()

    private var orderedExercises: [WorkoutExercise] {
        session.exercises.sorted { $0.order < $1.order }
    }

    private var displayedElapsed: TimeInterval {
        SessionClock.tick(banked: bankedElapsed, anchor: foregroundAnchor)
    }

    private var remainingRestSeconds: Int? {
        guard let restDeadline else { return nil }
        let secs = Int(ceil(restDeadline.timeIntervalSinceNow))
        return secs > 0 ? secs : nil
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: AppSpacing.space6.value) {
                    headerCard

                    ForEach(orderedExercises) { exercise in
                        exerciseCard(exercise)
                    }
                    .padding(.bottom, remainingRestSeconds == nil ? 0 : AppLayout.primaryCTAHeight + AppSpacing.space8.value)
                }
                .padding(.horizontal, AppSpacing.space4.value)
                .padding(.top, AppSpacing.space2.value)
            }

            if let remaining = remainingRestSeconds {
                RestTimerView(remainingSeconds: remaining) {
                    restDeadline = nil
                }
                .padding(.bottom, AppSpacing.space4.value)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .background(Color.P4CE.bg.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.25), value: remainingRestSeconds != nil)
        .sheet(item: $logExercise) { exercise in
            LogSetSheet(
                exercise: exercise,
                restSeconds: restDurationSeconds,
                onLogged: {
                    restDeadline = Date().addingTimeInterval(TimeInterval(restDurationSeconds))
                }
            )
            .environmentObject(workoutViewModel)
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showFinishWorkoutSheet) {
            FinishWorkoutSheet(session: session, currentElapsed: { displayedElapsed })
                .environmentObject(workoutViewModel)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
        }
        .onAppear {
            if foregroundAnchor == nil {
                foregroundAnchor = session.date
            }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background:
                if let anchor = foregroundAnchor {
                    bankedElapsed += Date().timeIntervalSince(anchor)
                }
                foregroundAnchor = nil
            case .active:
                if foregroundAnchor == nil {
                    foregroundAnchor = Date()
                }
            case .inactive:
                break
            @unknown default:
                break
            }
        }
        .onReceive(tick) { _ in
            tickToken = UUID()
            if let restDeadline, restDeadline.timeIntervalSinceNow <= 0 {
                self.restDeadline = nil
            }
        }
    }

    private var headerCard: some View {
        HStack(alignment: .center, spacing: AppSpacing.space3.value) {
            VStack(alignment: .leading, spacing: AppSpacing.space1.value) {
                Text("Session")
                    .font(Font.Style.metadataCaps)
                    .tracking(Font.Tracking.metadataCapsHigh)
                    .foregroundStyle(Color.P4CE.muted)
                Text(formatElapsed(displayedElapsed))
                    .font(Font.appMono(size: 28, weight: .semibold))
                    .foregroundStyle(Color.P4CE.text)
                    .monospacedDigit()
                    .accessibilityLabel("Elapsed session time")
            }

            Spacer(minLength: 0)

            Button {
                showFinishWorkoutSheet = true
            } label: {
                Text("Finish")
                    .font(Font.appSans(size: 15, weight: .semibold))
                    .foregroundStyle(Color.P4CE.lime)
                    .padding(.horizontal, AppSpacing.space4.value)
                    .frame(minHeight: AppLayout.minimumTouchTarget)
                    .background(Color.P4CE.surfHi)
                    .clipShape(Capsule(style: .continuous))
                    .overlay(
                        Capsule(style: .continuous)
                            .strokeBorder(Color.P4CE.line, lineWidth: AppLayout.hairlineBorderWidth)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityHint("Review summary and save or keep training")
        }
        .padding(AppSpacing.space4.value)
        .background(Color.P4CE.surfHi.opacity(0.45))
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg.value, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.lg.value, style: .continuous)
                .strokeBorder(Color.P4CE.lineSoft, lineWidth: AppLayout.hairlineBorderWidth)
        )
    }

    private func exerciseCard(_ exercise: WorkoutExercise) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.space3.value) {
            Text(exercise.name)
                .font(Font.appSans(size: 18, weight: .bold))
                .foregroundStyle(Color.P4CE.text)

            setList(for: exercise)

            PrimaryButton(title: "+ SET") {
                logExercise = exercise
            }
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

    @ViewBuilder
    private func setList(for exercise: WorkoutExercise) -> some View {
        let rows = exercise.sets.sorted { $0.timestamp < $1.timestamp }
        if rows.isEmpty {
            Text("No sets yet")
                .font(Font.Style.sessionName)
                .foregroundStyle(Color.P4CE.textDim)
        } else {
            VStack(alignment: .leading, spacing: AppSpacing.space2.value) {
                ForEach(rows) { entry in
                    HStack {
                        Text(formatSetLine(entry))
                            .font(Font.appSans(size: 16, weight: .medium))
                            .foregroundStyle(Color.P4CE.text)
                        Spacer(minLength: 0)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }

    private func formatSetLine(_ entry: SetEntry) -> String {
        let w = formatWeightDisplay(entry.weight)
        var line = "\(w) × \(entry.reps)"
        if let rpe = entry.rpe {
            line += " · RPE \(formatRPE(rpe))"
        }
        return line
    }

    private func formatWeightDisplay(_ kg: Double) -> String {
        let snapped = (kg / 0.5).rounded() * 0.5
        let frac = abs(snapped.truncatingRemainder(dividingBy: 1))
        let digits = frac < .ulpOfOne ? 0 : 1
        return snapped.formatted(.number.precision(.fractionLength(digits)))
    }

    private func formatRPE(_ value: Double) -> String {
        if value == floor(value) {
            return String(Int(value))
        }
        return value.formatted(.number.precision(.fractionLength(1)))
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
}

private struct ActiveSessionPreviewHarness: View {
    @Environment(\.modelContext)
    private var modelContext

    @StateObject
    private var workoutViewModel = WorkoutViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if let session = workoutViewModel.activeSession {
                    ActiveSessionView(session: session)
                        .environmentObject(workoutViewModel)
                } else {
                    Text("No session")
                }
            }
            .navigationTitle("Workout")
        }
        .task {
            workoutViewModel.attach(modelContext: modelContext)
            _ = workoutViewModel.startSession(exercises: [
                CoreLift.backSquat.rawValue,
                "Ski Erg"
            ])
        }
        .preferredColorScheme(.dark)
    }
}

#Preview("ActiveSessionView") {
    ActiveSessionPreviewHarness()
        .modelContainer(try! P4CESchema.previewContainer())
}
