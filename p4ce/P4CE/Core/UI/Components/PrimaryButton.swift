import SwiftUI

/// Primary CTA — DESIGN.md component pattern (accent / inverse, 56 pt height, radius.lg).
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Font.Style.ctaLabel)
                .tracking(Font.Tracking.ctaLabel)
                .foregroundStyle(Color.P4CE.limeInk)
                .frame(maxWidth: .infinity)
                .frame(height: AppLayout.primaryCTAHeight)
        }
        .buttonStyle(PrimaryChromeButtonStyle())
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(title)
    }
}

private struct PrimaryChromeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.P4CE.limeDeep : Color.P4CE.lime)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.lg.value, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview("PrimaryButton") {
    PrimaryButton(title: "LOG SET") {}
        .padding(AppSpacing.space4.value)
        .background(Color.P4CE.bg)
        .preferredColorScheme(.dark)
}
