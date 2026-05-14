import SwiftData
import SwiftUI

/// Profile + 1RM configuration — Dashboard toolbar push (`P4CE-9`).
struct SettingsView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \AthleteProfile.createdAt, order: .forward)
    private var athleteProfiles: [AthleteProfile]

    private let viewModel = SettingsViewModel()

    @State
    private var resetAlertShowing = false
    @State
    private var liftEditing: LiftEditRoute?

    var body: some View {
        Group {
            if let profile = athleteProfiles.first {
                SettingsContent(
                    profile: profile,
                    viewModel: viewModel,
                    resetAlertShowing: $resetAlertShowing,
                    liftEditing: $liftEditing,
                    modelContext: modelContext
                )
            } else {
                ProgressView()
                    .tint(Color.P4CE.lime)
                    .foregroundStyle(Color.P4CE.text)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.P4CE.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .background(Color.P4CE.bg.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .sheet(item: $liftEditing) { route in
            if let profile = athleteProfiles.first {
                OneRMEditSheetView(profile: profile, lift: route.lift)
                    .presentationDetents([.large])
                    .preferredColorScheme(.dark)
            }
        }
        .alert("Reset all 1RMs?", isPresented: $resetAlertShowing) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                guard let profile = athleteProfiles.first else { return }
                try? viewModel.resetAllOneRepMaxes(profile: profile, context: modelContext)
            }
        } message: {
            Text("This clears every tracked 1RM. Strength percentages rebuild from scratch.")
        }
    }
}

/// Nested so `@Bindable` applies to the concrete `@Model` instance.
private struct SettingsContent: View {
    @Bindable
    private var profile: AthleteProfile

    private let viewModel: SettingsViewModel

    @Binding
    private var resetAlertShowing: Bool
    @Binding
    private var liftEditing: LiftEditRoute?

    private let modelContext: ModelContext

    /// Local draft mirrors `profile.bodyWeightKg` in athlete display units.
    @State
    private var bodyWeightField = ""

    init(
        profile: AthleteProfile,
        viewModel: SettingsViewModel,
        resetAlertShowing: Binding<Bool>,
        liftEditing: Binding<LiftEditRoute?>,
        modelContext: ModelContext
    ) {
        self.profile = profile
        self.viewModel = viewModel
        _resetAlertShowing = resetAlertShowing
        _liftEditing = liftEditing
        self.modelContext = modelContext
    }

    private var unitBinding: Binding<UnitSystem> {
        Binding(
            get: { UnitSystem(rawValue: profile.unitPreferenceRaw) ?? .kg },
            set: { newValue in
                profile.unitPreferenceRaw = newValue.rawValue
                syncBodyDraftFromKg()
                profile.touchUpdated()
                saveContextQuietly()
            }
        )
    }

    private var experienceBinding: Binding<ExperienceLevel> {
        Binding(
            get: { ExperienceLevel(rawValue: profile.experienceLevelRaw) ?? .intermediate },
            set: { newValue in
                profile.experienceLevelRaw = newValue.rawValue
                profile.touchUpdated()
                saveContextQuietly()
            }
        )
    }

    var body: some View {
        List {
            Section {
                athleteSection
            } header: {
                SettingsSectionCaps(title: "Athlete · identity & training context")
            }

            Section {
                oneRepMaxSection
            } header: {
                SettingsSectionCaps(title: "1-Rep Maxes")
            }

            Section {
                disabledRow(primary: "Theme", trailing: "Dark (locked)")
                disabledRow(primary: "Notifications", trailing: "Soon")
            } header: {
                SettingsSectionCaps(title: "Preferences")
            }

            Section {
                Button(role: .destructive, action: { resetAlertShowing = true }) {
                    Text("Reset all 1RMs…")
                        .font(Font.appSans(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, AppSpacing.space1.value)
            }
        }
        .scrollContentBackground(.hidden)
        .foregroundStyle(Color.P4CE.text)
        .onAppear { syncBodyDraftFromKg() }
        .onChange(of: profile.unitPreferenceRaw) { _, _ in
            syncBodyDraftFromKg()
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var athleteSection: some View {
        Group {
            HStack(spacing: AppSpacing.space3.value) {
                Text("Name · optional")
                    .font(Font.Style.sessionName)
                    .foregroundStyle(Color.P4CE.dim)
                Spacer()
                TextField(
                    "First name…",
                    text: Binding(
                        get: { profile.name },
                        set: { profile.name = $0 }
                    )
                )
                .multilineTextAlignment(.trailing)
                .foregroundStyle(Color.P4CE.text)
                .onChange(of: profile.name) { _, _ in
                    profile.touchUpdated()
                    saveContextQuietly()
                }
            }

            Divider().foregroundStyle(Color.P4CE.lineSoft)

            Text("Athlete Basics")
                .font(Font.appMono(size: 10, weight: .semibold))
                .tracking(Font.Tracking.metadataCapsLow)
                .foregroundStyle(Color.P4CE.dim)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            HStack(spacing: AppSpacing.space3.value) {
                TextField("BW", text: $bodyWeightField)
                    .keyboardType(.decimalPad)
                    .font(Font.Style.sectionDate.monospacedDigit())
                    .foregroundStyle(Color.P4CE.text)
                    .onChange(of: bodyWeightField) { _, _ in
                        applyBodyWeightDraft()
                    }
                Text(unitBinding.wrappedValue.rawValue.uppercased())
                    .font(Font.Style.sessionName.monospacedDigit())
                    .foregroundStyle(Color.P4CE.dim)
                    .padding(.horizontal, AppSpacing.space2.value)
                    .padding(.vertical, AppSpacing.space1.value)
                    .background(Color.P4CE.surfHi.opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm.value))
            }

            Picker("Units · display only", selection: unitBinding) {
                ForEach(UnitSystem.allCases, id: \.self) { sys in
                    Text(sys.rawValue.uppercased()).tag(sys)
                }
            }
            .pickerStyle(.segmented)
            .tint(Color.P4CE.textDim)

            Picker("", selection: $profile.trainingFrequency) {
                ForEach(Array(3 ... 6), id: \.self) { n in
                    Text("\(n)×").tag(n)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: profile.trainingFrequency) { _, _ in
                profile.touchUpdated()
                saveContextQuietly()
            }

            Text("Weekly training frequency influences planning density.")
                .font(Font.Style.metadataCaps)
                .tracking(Font.Tracking.metadataCapsLow)
                .foregroundStyle(Color.P4CE.dim)
                .listRowInsets(.init(top: 0, leading: AppSpacing.space2.value,
                                     bottom: 0, trailing: AppSpacing.space2.value))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)

            Picker("Experience", selection: experienceBinding) {
                ForEach(ExperienceLevel.allCases, id: \.self) { level in
                    Text(level.displayTitle).tag(level)
                }
            }
            .pickerStyle(.menu)
            .tint(Color.P4CE.textDim)
            .onChange(of: profile.experienceLevelRaw) { _, _ in
                profile.touchUpdated()
                saveContextQuietly()
            }

            Divider().foregroundStyle(Color.P4CE.lineSoft)
        }
        .listRowBackground(Color.P4CE.surfHi.opacity(0.35))
    }

    private var oneRepMaxSection: some View {
        ForEach(CoreLift.allCases, id: \.self) { lift in
            Button {
                liftEditing = LiftEditRoute(lift: lift)
            } label: {
                HStack {
                    Text(lift.rawValue)
                        .font(Font.Style.sessionName)
                        .foregroundStyle(Color.P4CE.textDim)
                    Spacer()
                    if let kg = viewModel.oneRepMaxKg(for: lift, profile: profile) {
                        Text(UnitConversion.formatLiftDisplay(forKg: kg, unit: profile.unitPreference))
                            .font(Font.appMono(size: 12, weight: .medium).monospacedDigit())
                            .foregroundStyle(Color.P4CE.dim)
                    } else {
                        Text("—")
                            .font(Font.Style.sessionName.monospacedDigit())
                            .foregroundStyle(Color.P4CE.dim)
                    }
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.P4CE.dim.opacity(0.45))
                        .padding(.leading, AppSpacing.space1.value)
                }
                .contentShape(Rectangle())
                .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
        }
        .listRowBackground(Color.P4CE.surfHi.opacity(0.35))
    }

    private func disabledRow(primary: String, trailing: String) -> some View {
        HStack {
            Text(primary)
                .font(Font.Style.sessionName)
            Spacer()
            Text(trailing)
                .font(Font.Style.sessionName)
                .foregroundStyle(Color.P4CE.dim)
        }
        .foregroundStyle(Color.P4CE.dim.opacity(0.54))
        .listRowBackground(Color.P4CE.surfHi.opacity(0.2))
    }

    private func syncBodyDraftFromKg() {
        if let kg = profile.bodyWeightKg {
            bodyWeightField = UnitConversion.trimmedDisplayDecimalString(
                forKg: kg,
                unit: profile.unitPreference
            )
        } else {
            bodyWeightField = ""
        }
    }

    private func applyBodyWeightDraft() {
        let trimmed = bodyWeightField.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            profile.bodyWeightKg = nil
            profile.touchUpdated()
            saveContextQuietly()
            return
        }
        guard let kg = UnitConversion.kg(fromDisplayInput: trimmed, unit: profile.unitPreference), kg > 0 else {
            return
        }
        profile.bodyWeightKg = kg
        profile.touchUpdated()
        saveContextQuietly()
        bodyWeightField = UnitConversion.trimmedDisplayDecimalString(
            forKg: kg,
            unit: profile.unitPreference
        )
    }

    private func saveContextQuietly() {
        try? modelContext.save()
    }
}

private struct SettingsSectionCaps: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(Font.appMono(size: 10, weight: .semibold))
            .tracking(Font.Tracking.metadataCapsLow)
            .foregroundStyle(Color.P4CE.dim)
    }
}

struct LiftEditRoute: Identifiable {
    let lift: CoreLift
    var id: String { lift.rawValue }
}
