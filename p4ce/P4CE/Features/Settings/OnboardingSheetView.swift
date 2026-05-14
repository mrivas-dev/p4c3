import SwiftData
import SwiftUI

/// First-launch 3-step profile wizard (P4CE-9).
struct OnboardingSheetView: View {
    let profile: AthleteProfile

    @Environment(\.modelContext)
    private var modelContext

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var viewModel: OnboardingViewModel?

    var body: some View {
        Group {
            if let viewModel {
                onboardingBody(viewModel: viewModel)
            } else {
                ProgressView()
                    .tint(Color.P4CE.lime)
                    .foregroundStyle(Color.P4CE.text)
            }
        }
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled()
        .background(Color.P4CE.bg.ignoresSafeArea())
        .task {
            guard viewModel == nil else { return }
            viewModel = OnboardingViewModel(profile: profile, modelContext: modelContext)
        }
    }

    @ViewBuilder
    private func onboardingBody(viewModel: OnboardingViewModel) -> some View {
        NavigationStack {
            VStack(spacing: 0) {
                stepHeader(viewModel: viewModel)

                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.space6.value) {
                        switch viewModel.stepIndex {
                        case 0: identityStep(viewModel: viewModel)
                        case 1: trainingStep(viewModel: viewModel)
                        default: liftStep(viewModel: viewModel)
                        }
                    }
                    .padding(AppSpacing.space4.value)
                    .padding(.bottom, AppSpacing.space8.value)
                }

                if viewModel.stepIndex == 2 {
                    VStack(spacing: AppSpacing.space3.value) {
                        PrimaryButton(title: "LET'S GO") {
                            tryLetsGo(viewModel)
                        }

                        GhostCTAButton(title: "I'll set these later") {
                            trySkip(viewModel)
                        }
                    }
                    .padding(AppSpacing.space4.value)
                } else {
                    PrimaryButton(title: stepPrimaryTitle(viewModel.stepIndex)) {
                        guard viewModel.canAdvancePastCurrentStep(viewModel.stepIndex) else { return }
                        viewModel.advance()
                    }
                    .padding(AppSpacing.space4.value)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.P4CE.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private func stepPrimaryTitle(_ stepIndex: Int) -> String {
        switch stepIndex {
        case 0: "NEXT"
        default: "NEXT"
        }
    }

    private func stepHeader(viewModel: OnboardingViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.space2.value) {
            Text("STEP \(viewModel.stepDisplayIndex) · \(Self.stepTitles[viewModel.stepIndex])")
                .font(Font.appSans(size: 14, weight: .semibold))
                .tracking(Font.Tracking.sectionDate)
                .foregroundStyle(Color.P4CE.textDim)
            Text(Self.stepEyebrows[viewModel.stepIndex])
                .font(Font.appMono(size: 10, weight: .semibold))
                .tracking(Font.Tracking.metadataCapsLow)
                .foregroundStyle(Color.P4CE.dim)
                .multilineTextAlignment(.leading)

            ProgressView(value: Double(viewModel.stepIndex + 1), total: Double(3))
                .tint(Color.P4CE.lime)
                .padding(.top, AppSpacing.space2.value)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.space4.value)
        .padding(.vertical, AppSpacing.space4.value)
        .background(Color.P4CE.surf.opacity(0.45))
    }

    private static let stepEyebrows = [
        "WHO YOU ARE — OPTIONAL NAME · BW · UNIT",
        "TRAINING STYLE — WEEKLY LOAD · EXPERIENCE",
        "1RM ENTRY — HYBRID ATHLETE PROFILE",
    ]
    private static let stepTitles = [
        "PROFILE",
        "TRAINING STYLE",
        "1RM ENTRY",
    ]

    private func identityStep(viewModel: OnboardingViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.space4.value) {
            Text("Name · optional")
                .font(Font.Style.metadataCaps)
                .tracking(Font.Tracking.metadataCapsLow)
                .foregroundStyle(Color.P4CE.dim)
            TextField("Your first name…", text: Binding(
                get: { viewModel.nameDraft },
                set: { viewModel.nameDraft = $0 }
            ))
            .textInputAutocapitalization(.words)
            .font(Font.Style.sessionName)
            .foregroundStyle(Color.P4CE.text)

            Divider().background(Color.P4CE.lineSoft)

            Text("Body weight")
                .font(Font.Style.metadataCaps)
                .tracking(Font.Tracking.metadataCapsLow)
                .foregroundStyle(Color.P4CE.dim)

            HStack(spacing: AppSpacing.space3.value) {
                TextField("e.g. 87.5", text: Binding(
                    get: { viewModel.bodyWeightInput },
                    set: { viewModel.bodyWeightInput = $0 }
                ))
                .keyboardType(.decimalPad)
                .font(Font.Style.sectionDate.monospacedDigit())
                .foregroundStyle(Color.P4CE.text)
                Text(viewModel.unitDraft.rawValue.uppercased())
                    .font(Font.Style.sessionName.monospacedDigit())
                    .foregroundStyle(Color.P4CE.dim)
                    .padding(.horizontal, AppSpacing.space2.value)
                    .padding(.vertical, AppSpacing.space1.value)
                    .background(Color.P4CE.surfHi.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm.value))
            }

            Picker("", selection: Binding(
                get: { viewModel.unitDraft.rawValue },
                set: {
                    guard let sys = UnitSystem(rawValue: $0) else { return }
                    viewModel.unitDraft = sys
                    viewModel.syncLiftInputUnitsFromDraft()
                }
            )) {
                Text("KG").tag(UnitSystem.kg.rawValue)
                Text("LB").tag(UnitSystem.lb.rawValue)
            }
            .pickerStyle(.segmented)

            CaptionLine(
                hint: "Used for scaled recommendations."
            )
        }
    }

    private func trainingStep(viewModel: OnboardingViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.space4.value) {
            Text("How many days/week do you realistically train, including conditioning?")
                .font(Font.appSans(size: 18, weight: .medium))
                .tracking(Font.Tracking.sectionDate)
                .foregroundStyle(Color.P4CE.text)

            FrequencyPicker(selection: Binding(
                get: { viewModel.trainingFrequency },
                set: { viewModel.trainingFrequency = $0 }
            ))

            Divider().background(Color.P4CE.lineSoft)

            Text("Experience Level")
                .font(Font.Style.metadataCaps)
                .tracking(Font.Tracking.metadataCapsLow)
                .foregroundStyle(Color.P4CE.dim)

            Picker("Experience", selection: Binding(
                get: { viewModel.experienceDraft },
                set: { viewModel.experienceDraft = $0 }
            )) {
                ForEach(ExperienceLevel.allCases, id: \.self) { level in
                    Text(level.displayTitle).tag(level)
                }
            }
            .pickerStyle(.menu)

            CaptionLine(hint: "Frequency shapes how sessions stack each week.")

            Divider().background(Color.P4CE.lineSoft)

            Text("Beginner implies under ~3 structured years — you can tune this anytime.")
                .font(Font.Style.sessionName)
                .foregroundStyle(Color.P4CE.dim)
        }
    }

    private func liftStep(viewModel: OnboardingViewModel) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.space4.value) {
            Text("Enter your current or estimated 1RM.")
                .font(Font.appSans(size: 14, weight: .medium))
                .foregroundStyle(Color.P4CE.dim)
            Text("Olympic lifts last — leave blank if unfamiliar.")
                .font(Font.appSans(size: 14, weight: .medium))
                .foregroundStyle(Color.P4CE.dim)

            ForEach(CoreLift.allCases, id: \.self) { lift in
                HStack(spacing: AppSpacing.space3.value) {
                    Text(lift.rawValue.uppercased())
                        .font(Font.Style.sectionDate.monospacedDigit())
                        .foregroundStyle(Color.P4CE.textDim)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    TextField("—", text: Binding(
                        get: { viewModel.liftInputs[lift, default: ""] },
                        set: { viewModel.liftInputs[lift] = $0 }
                    ))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 88)
                        .font(Font.appDisplay(size: 18, weight: .semibold).monospacedDigit())
                        .foregroundStyle(Color.P4CE.text)
                    Text(viewModel.unitDraft.rawValue.uppercased())
                        .font(Font.Style.sessionName.monospacedDigit())
                        .foregroundStyle(Color.P4CE.muted)
                }
                Divider().background(Color.P4CE.lineSoft)
            }
            CaptionLine(
                hint: "You can tweak these anytime in Settings."
            )
        }
    }

    private func tryLetsGo(_ viewModel: OnboardingViewModel) {
        do {
            try viewModel.completeWithEnteredLiftMaxes()
            dismiss()
        } catch {}
    }

    private func trySkip(_ viewModel: OnboardingViewModel) {
        do {
            try viewModel.skipLiftMaxEntries()
            dismiss()
        } catch {}
    }
}

private struct CaptionLine: View {
    let hint: String

    var body: some View {
        Text(hint)
            .font(Font.Style.sessionName)
            .foregroundStyle(Color.P4CE.dim)
    }
}

/// Segmented picker for weekly frequency (spec: 4 segments 3×…6×).
private struct FrequencyPicker: View {
    @Binding var selection: Int

    private let buckets = Array(3 ... 6)

    var body: some View {
        Picker("", selection: $selection) {
            ForEach(buckets, id: \.self) { freq in
                Text("\(freq)×").tag(freq)
            }
        }
        .pickerStyle(.segmented)
        .foregroundStyle(Color.P4CE.textDim)
        .tint(Color.P4CE.lime)
        .minimumScaleFactor(0.76)
        .environment(\.colorScheme, .dark)
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.md.value)
                .strokeBorder(Color.P4CE.line.opacity(0.35), lineWidth: AppLayout.hairlineBorderWidth)
        }
    }
}

private struct GhostCTAButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Font.appSans(size: 14, weight: .medium))
                .foregroundStyle(Color.P4CE.dim)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.space3.value)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}
