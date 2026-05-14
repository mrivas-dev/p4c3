import SwiftData
import SwiftUI

/// Home / Dashboard — layout aligned with `_design/wireframes/P4CE-4-dashboard-wireframe.html`.
struct DashboardView: View {
    private let viewModel: DashboardViewModel

    /// Switches MainTabView to the Workout tab (used by Today's card).
    private let onGoToWorkout: () -> Void

    @Query(
        filter: #Predicate<WorkoutSession> { $0.statusRaw == "finished" },
        sort: \WorkoutSession.date,
        order: .reverse
    )
    private var finishedSessionsNewestFirst: [WorkoutSession]

    @Query(
        filter: #Predicate<WorkoutSession> { $0.statusRaw == "inProgress" },
        sort: \WorkoutSession.date,
        order: .reverse
    )
    private var inProgressSessionsNewestFirst: [WorkoutSession]

    init(
        viewModel: DashboardViewModel = DashboardViewModel(),
        onGoToWorkout: @escaping () -> Void = {}
    ) {
        self.viewModel = viewModel
        self.onGoToWorkout = onGoToWorkout
    }

    @EnvironmentObject
    private var workoutViewModel: WorkoutViewModel

    @State
    private var showStartWorkoutSheet = false

    @State
    private var bannerDiscardSession: WorkoutSession?

    private var inProgressSession: WorkoutSession? {
        inProgressSessionsNewestFirst.first
    }

    private var lastSessionMetricLine: String {
        guard let session = finishedSessionsNewestFirst.first else {
            return "—"
        }
        let weekday = session.date.formatted(.dateTime.weekday(.abbreviated))
        let volumeKg = WorkoutSessionMetrics.totalVolume(for: session)
        let tonnes = volumeKg / 1000
        let volLabel = String(format: "%.1f", tonnes) + "t"
        return "\(weekday) · Vol \(volLabel)"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let session = inProgressSession {
                    ResumeBanner(
                        onResume: {
                            workoutViewModel.resumeSession(session)
                            onGoToWorkout()
                        },
                        onDiscardTapped: {
                            bannerDiscardSession = session
                        }
                    )
                    .padding(.horizontal, AppSpacing.space4.value)
                    .padding(.top, AppSpacing.space2.value)
                    .padding(.bottom, AppSpacing.space1.value)
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.space6.value) {
                        Button(action: onGoToWorkout) {
                            MetricCard {
                                VStack(alignment: .leading, spacing: AppSpacing.space3.value) {
                                    SectionHeader(title: "Today")
                                    Text(viewModel.workoutHeadline)
                                        .font(Font.appSans(size: 22, weight: .bold))
                                        .tracking(Font.Tracking.sectionDate)
                                        .foregroundStyle(Color.P4CE.text)
                                    Text(viewModel.workoutDetail)
                                        .font(Font.Style.sessionName)
                                        .foregroundStyle(Color.P4CE.textDim)

                                    LazyVGrid(
                                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                                        spacing: AppSpacing.space2.value
                                    ) {
                                        DashboardMetricTile(
                                            label: viewModel.lastSessionLabel,
                                            value: lastSessionMetricLine
                                        )
                                        DashboardMetricTile(
                                            label: viewModel.weeklyVolumeLabel,
                                            value: viewModel.weeklyVolumeValue
                                        )
                                    }
                                    .padding(.top, AppSpacing.space2.value)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Today's workout")
                        .accessibilityHint("Opens the Workout tab")
                    }
                    .padding(.horizontal, AppSpacing.space4.value)
                    .padding(.top, AppSpacing.space2.value)
                    .padding(.bottom, AppSpacing.space4.value)
                }

                PrimaryButton(title: "START WORKOUT") {
                    showStartWorkoutSheet = true
                }
                .padding(.horizontal, AppSpacing.space4.value)
                .padding(.bottom, AppSpacing.space4.value)
            }
            .background(Color.P4CE.bg.ignoresSafeArea())
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.P4CE.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: AppSpacing.space3.value) {
                        NavigationLink {
                            WorkoutHistoryView()
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(Color.P4CE.textDim)
                                .accessibilityLabel("Workout history")
                        }

                        NavigationLink {
                            SettingsView()
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(Color.P4CE.textDim)
                                .accessibilityLabel("Settings")
                        }
                    }
                }
            }
            .sheet(isPresented: $showStartWorkoutSheet) {
                StartWorkoutSheet {
                    showStartWorkoutSheet = false
                    onGoToWorkout()
                }
                .environmentObject(workoutViewModel)
                .presentationDragIndicator(.visible)
                .presentationDetents([.medium, .large])
            }
            .alert(
                "Discard session?",
                isPresented: Binding(
                    get: { bannerDiscardSession != nil },
                    set: { if !$0 { bannerDiscardSession = nil } }
                )
            ) {
                Button("Cancel", role: .cancel) {
                    bannerDiscardSession = nil
                }
                Button("Discard", role: .destructive) {
                    if let session = bannerDiscardSession {
                        workoutViewModel.discardSession(session)
                    }
                    bannerDiscardSession = nil
                }
            } message: {
                Text("This marks the workout abandoned. Logged sets for this session will not appear in history.")
            }
        }
    }
}

// MARK: - Metric tiles

private struct DashboardMetricTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.space2.value) {
            Text(label.uppercased())
                .font(Font.appMono(size: 9, weight: .semibold))
                .tracking(Font.Tracking.metadataCapsHigh)
                .foregroundStyle(Color.P4CE.muted)
            Text(value)
                .font(Font.appDisplay(size: 18, weight: .semibold))
                .tracking(Font.Tracking.statsLarge)
                .foregroundStyle(Color.P4CE.text)
                .minimumScaleFactor(0.85)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.space3.value)
        .background(Color.P4CE.surfHi.opacity(0.65))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md.value, style: .continuous)
                .strokeBorder(Color.P4CE.lineSoft, lineWidth: AppLayout.hairlineBorderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md.value, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}

private struct DashboardViewPreviewHarness: View {
    @Environment(\.modelContext)
    private var modelContext

    @StateObject
    private var workoutViewModel = WorkoutViewModel()

    var body: some View {
        NavigationStack {
            DashboardView()
                .environmentObject(workoutViewModel)
        }
        .task {
            workoutViewModel.attach(modelContext: modelContext)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview("DashboardView") {
    DashboardViewPreviewHarness()
        .modelContainer(try! P4CESchema.previewContainer())
}
