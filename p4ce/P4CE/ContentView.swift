import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.space6.value) {
                    MetricCard {
                        SectionHeader(title: "Today")
                        Text("Back Squat")
                            .font(Font.Style.sectionDate)
                            .tracking(Font.Tracking.sectionDate)
                            .foregroundStyle(Color.P4CE.textDim)
                        Text("5 × 5")
                            .font(Font.Style.workoutHero)
                            .tracking(Font.Tracking.workoutHero)
                            .foregroundStyle(Color.P4CE.text)
                    }

                    PrimaryButton(title: "START WORKOUT", action: {})
                }
                .padding(AppSpacing.space4.value)
            }
            .background(Color.P4CE.bg.ignoresSafeArea())
            .navigationTitle("P4CE")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

#Preview("ContentView") {
    ContentView()
        .preferredColorScheme(.dark)
        .modelContainer(for: SeedModel.self, inMemory: true)
}
