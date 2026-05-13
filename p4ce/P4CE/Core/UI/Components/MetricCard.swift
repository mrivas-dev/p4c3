import SwiftUI

/// Card surface token preview — DESIGN.md surf fill + subtle border.
struct MetricCard<Content: View>: View {
    @ViewBuilder var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(AppSpacing.space4.value)
            .background(Color.P4CE.surf)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.lg.value, style: .continuous)
                    .strokeBorder(Color.P4CE.lineSoft, lineWidth: AppLayout.hairlineBorderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg.value, style: .continuous))
    }
}

#Preview("MetricCard") {
    MetricCard {
        SectionHeader(title: "Streak")
        Text("14 days")
            .font(Font.Style.statsLarge)
            .tracking(Font.Tracking.statsLarge)
            .foregroundStyle(Color.P4CE.text)
    }
    .padding(AppSpacing.space4.value)
    .background(Color.P4CE.bg)
    .preferredColorScheme(.dark)
}
