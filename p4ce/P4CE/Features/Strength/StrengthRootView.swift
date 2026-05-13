import SwiftUI

struct StrengthRootView: View {
    var body: some View {
        FeatureTabPlaceholder(
            title: "Strength",
            systemImage: "figure.strengthtraining.traditional",
            message: "Program structure and lift assignments will live here."
        )
    }
}

#Preview("StrengthRootView") {
    NavigationStack {
        StrengthRootView()
    }
    .preferredColorScheme(.dark)
}
