import SwiftUI

/// Highlights a persisted in-progress workout on the dashboard (P4CE-17).
struct ResumeBanner: View {
    let onResume: () -> Void
    let onDiscardTapped: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.space4.value) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.P4CE.amber)
                .frame(width: 4)

            VStack(alignment: .leading, spacing: AppSpacing.space2.value) {
                Text("Session in progress")
                    .font(Font.appSans(size: 15, weight: .semibold))
                    .foregroundStyle(Color.P4CE.text)

                Text("Tap Resume to reopen your live workout.")
                    .font(Font.Style.sessionName)
                    .foregroundStyle(Color.P4CE.textDim)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: AppSpacing.space2.value) {
                Button(action: onResume) {
                    Text("Resume →")
                        .font(Font.appSans(size: 14, weight: .bold))
                        .foregroundStyle(Color.P4CE.limeInk)
                        .padding(.horizontal, AppSpacing.space3.value)
                        .padding(.vertical, AppSpacing.space2.value)
                        .background(Color.P4CE.amber)
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm.value, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Resume workout")

                Button("Discard") {
                    onDiscardTapped()
                }
                .font(Font.appSans(size: 13, weight: .medium))
                .foregroundStyle(Color.P4CE.red)
                .accessibilityHint("Marks this session abandoned after confirmation")
            }
        }
        .padding(AppSpacing.space3.value)
        .background(Color.P4CE.surfHi.opacity(0.85))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.md.value, style: .continuous)
                .strokeBorder(Color.P4CE.amber.opacity(0.45), lineWidth: AppLayout.hairlineBorderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.md.value, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}

#Preview("ResumeBanner") {
    ResumeBanner(onResume: {}, onDiscardTapped: {})
        .padding()
        .background(Color.P4CE.bg)
        .preferredColorScheme(.dark)
}
