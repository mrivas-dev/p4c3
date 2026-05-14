import SwiftData
import SwiftUI

/// Bottom sheet to pick core lifts and custom exercises before starting a session.
struct StartWorkoutSheet: View {
    @Environment(\.dismiss)
    private var dismiss

    @EnvironmentObject
    private var workoutViewModel: WorkoutViewModel

    let onStarted: () -> Void

    @State
    private var selectedCoreLifts: Set<CoreLift> = []

    @State
    private var customPool: [String] = []

    @State
    private var selectedCustomNames: Set<String> = []

    @State
    private var customDraft: String = ""

    private var orderedExerciseNames: [String] {
        var names: [String] = []
        for lift in CoreLift.allCases where selectedCoreLifts.contains(lift) {
            names.append(lift.rawValue)
        }
        for custom in customPool where selectedCustomNames.contains(custom) {
            names.append(custom)
        }
        return names
    }

    private var canStart: Bool {
        !orderedExerciseNames.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section {
                        Text("Select at least one movement. Confirm starts the session instantly.")
                            .font(Font.Style.sessionName)
                            .foregroundStyle(Color.P4CE.textDim)
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init(top: 8, leading: 0, bottom: 12, trailing: 0))
                    }

                    Section("Core lifts") {
                        ForEach(CoreLift.allCases, id: \.self) { lift in
                            exerciseRow(title: lift.rawValue, selected: selectedCoreLifts.contains(lift)) {
                                toggleCore(lift)
                            }
                            .listRowBackground(Color.P4CE.surfHi.opacity(0.45))
                            .listRowSeparatorTint(Color.P4CE.lineSoft)
                        }
                    }

                    Section("Custom movement") {
                        HStack(spacing: AppSpacing.space3.value) {
                            TextField("Name", text: $customDraft)
                                .textInputAutocapitalization(.words)
                                .foregroundStyle(Color.P4CE.text)
                                .submitLabel(.done)

                            Button("Add") {
                                addCustomFromDraft()
                            }
                            .font(Font.appSans(size: 14, weight: .semibold))
                            .foregroundStyle(Color.P4CE.lime)
                            .disabled(normalizedDraft() == nil)
                        }
                        .frame(minHeight: 44)

                        ForEach(customPool, id: \.self) { name in
                            exerciseRow(title: name, selected: selectedCustomNames.contains(name)) {
                                toggleCustom(name)
                            }
                            .listRowBackground(Color.P4CE.surfHi.opacity(0.45))
                            .listRowSeparatorTint(Color.P4CE.lineSoft)
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .background(Color.P4CE.bg)

                PrimaryButton(title: "START SESSION", action: confirmStart)
                    .disabled(!canStart)
                    .opacity(canStart ? 1 : 0.35)
                    .padding(.horizontal, AppSpacing.space4.value)
                    .padding(.bottom, AppSpacing.space4.value)
                    .padding(.top, AppSpacing.space2.value)
                    .background(Color.P4CE.bg.opacity(0.98))
            }
            .navigationTitle("Start workout")
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
    }

    private func exerciseRow(title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.space3.value) {
                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .imageScale(.large)
                    .foregroundStyle(selected ? Color.P4CE.lime : Color.P4CE.muted)

                Text(title)
                    .font(Font.Style.sessionName.weight(.medium))
                    .foregroundStyle(Color.P4CE.text)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityValue(selected ? "Selected" : "Not selected")
        .accessibilityHint("Tap to toggle")
    }

    private func normalizedDraft() -> String? {
        let trimmed = customDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let taken = Set(customPool.map { $0.lowercased() }).union(Set(CoreLift.allCases.map { $0.rawValue.lowercased() }))
        guard !taken.contains(trimmed.lowercased()) else { return nil }
        return trimmed
    }

    private func addCustomFromDraft() {
        guard let name = normalizedDraft() else { return }
        customPool.append(name)
        selectedCustomNames.insert(name)
        customDraft = ""
    }

    private func toggleCore(_ lift: CoreLift) {
        if selectedCoreLifts.contains(lift) {
            selectedCoreLifts.remove(lift)
        } else {
            selectedCoreLifts.insert(lift)
        }
    }

    private func toggleCustom(_ name: String) {
        if selectedCustomNames.contains(name) {
            selectedCustomNames.remove(name)
        } else {
            selectedCustomNames.insert(name)
        }
    }

    private func confirmStart() {
        guard canStart else { return }
        _ = workoutViewModel.startSession(exercises: orderedExerciseNames)
        dismiss()
        onStarted()
    }
}

private struct StartWorkoutSheetPreviewHarness: View {
    @Environment(\.modelContext)
    private var modelContext

    @StateObject
    private var workoutViewModel = WorkoutViewModel()

    var body: some View {
        NavigationStack {
            StartWorkoutSheet(onStarted: {})
                .environmentObject(workoutViewModel)
        }
        .task {
            workoutViewModel.attach(modelContext: modelContext)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview("StartWorkoutSheet") {
    StartWorkoutSheetPreviewHarness()
        .modelContainer(try! P4CESchema.previewContainer())
}
