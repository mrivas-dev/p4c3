import SwiftUI

/// Section caption — monospace, all caps metadata style (ticket: 10 pt, muted, +1.5 tracking).
struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title.uppercased())
            .font(Font.appMono(size: 10, weight: .medium))
            .tracking(Font.Tracking.sectionHeaderCaps)
            .foregroundStyle(Color.P4CE.muted)
            .accessibilityLabel(title)
            .accessibilityAddTraits(.isHeader)
    }
}

#Preview("SectionHeader") {
    SectionHeader(title: "Volume")
        .padding(AppSpacing.space4.value)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.P4CE.bg)
        .preferredColorScheme(.dark)
}
