import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \AthleteProfile.createdAt, order: .forward)
    private var athleteProfiles: [AthleteProfile]

    /// Manual sheet flag — syncing from SwiftData onboarding flag without blocking dismiss.
    @State
    private var showOnboarding = false

    var body: some View {
        MainTabView()
            .task {
                try? AthleteProfile.fetchOrInsertSingleton(in: modelContext)
                refreshOnboardingPresentation()
            }
            .onAppear {
                refreshOnboardingPresentation()
            }
            .onChange(of: athleteProfiles.count) { _, _ in
                refreshOnboardingPresentation()
            }
            .onChange(of: athleteProfiles.first?.onboardingCompleted) { _, completed in
                guard let completed else {
                    showOnboarding = false
                    return
                }
                showOnboarding = !completed
            }
            .sheet(isPresented: $showOnboarding) {
                if let profile = athleteProfiles.first {
                    OnboardingSheetView(profile: profile)
                        .presentationDetents([.large])
                }
            }
            .preferredColorScheme(.dark)
    }

    private func refreshOnboardingPresentation() {
        guard let profile = athleteProfiles.first else {
            showOnboarding = false
            return
        }
        showOnboarding = !profile.onboardingCompleted
    }
}

#Preview("ContentView") {
    ContentView()
        .preferredColorScheme(.dark)
        .modelContainer(try! P4CESchema.previewContainer())
}
