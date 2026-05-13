import SwiftUI

/// Home / Dashboard — layout aligned with `_design/wireframes/P4CE-4-dashboard-wireframe.html`.
struct DashboardView: View {
    private let viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel = DashboardViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.space6.value) {
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
                                        value: viewModel.lastSessionValue
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
                    .padding(.horizontal, AppSpacing.space4.value)
                    .padding(.top, AppSpacing.space2.value)
                    .padding(.bottom, AppSpacing.space4.value)
                }

                PrimaryButton(title: "START WORKOUT", action: startWorkoutTapped)
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
                    NavigationLink {
                        SettingsRootView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color.P4CE.textDim)
                            .accessibilityLabel("Settings")
                    }
                }
            }
        }
    }

    private func startWorkoutTapped() {
        // Hook for Workout tab / session flow (future).
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

#Preview("DashboardView") {
    DashboardView()
        .preferredColorScheme(.dark)
}
