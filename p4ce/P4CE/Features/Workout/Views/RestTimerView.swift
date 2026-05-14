import SwiftUI

/// Lightweight rest countdown surfaced after logging a set (P4CE-14).
struct RestTimerView: View {
    let remainingSeconds: Int
    let onDismissTap: () -> Void

    var body: some View {
        Button(action: onDismissTap) {
            HStack(spacing: AppSpacing.space3.value) {
                Image(systemName: "timer")
                    .foregroundStyle(Color.P4CE.lime)
                    .imageScale(.large)

                Text("Rest \(formatCountdown(remainingSeconds)) — tap to skip")
                    .font(Font.Style.sessionName.weight(.medium))
                    .foregroundStyle(Color.P4CE.text)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, AppSpacing.space4.value)
            .padding(.vertical, AppSpacing.space3.value)
            .background(Color.P4CE.surfHi.opacity(0.98))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.md.value, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md.value, style: .continuous)
                    .strokeBorder(Color.P4CE.line, lineWidth: AppLayout.hairlineBorderWidth)
            )
            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
            .padding(.horizontal, AppSpacing.space4.value)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "Rest countdown"))
        .accessibilityValue("\(remainingSeconds)")
        .accessibilityHint(String(localized: "Tap to dismiss rest timer early"))
    }

    private func formatCountdown(_ total: Int) -> String {
        let clamped = max(0, total)
        let m = clamped / 60
        let s = clamped % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview("RestTimerView") {
    ZStack {
        Color.P4CE.bg.ignoresSafeArea()
        VStack {
            Spacer()
            RestTimerView(remainingSeconds: 87, onDismissTap: {})
                .padding(.bottom, AppSpacing.space6.value)
        }
    }
    .preferredColorScheme(.dark)
}
