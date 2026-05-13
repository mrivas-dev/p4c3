import SwiftUI

struct AnalyticsRootView: View {
    var body: some View {
        FeatureTabPlaceholder(
            title: "Analytics",
            systemImage: "chart.line.uptrend.xyaxis",
            message: "Trends, volume, and PR history will live here."
        )
    }
}

#Preview("AnalyticsRootView") {
    NavigationStack {
        AnalyticsRootView()
    }
    .preferredColorScheme(.dark)
}
