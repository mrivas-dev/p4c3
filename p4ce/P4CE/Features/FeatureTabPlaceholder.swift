import SwiftUI

/// Minimal shell for tabs that do not have feature UI yet.
struct FeatureTabPlaceholder: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        ZStack {
            Color.P4CE.bg.ignoresSafeArea()
            VStack(spacing: AppSpacing.space4.value) {
                Image(systemName: systemImage)
                    .font(.system(size: 40))
                    .foregroundStyle(Color.P4CE.muted)
                Text(title)
                    .font(Font.Style.sectionDate)
                    .foregroundStyle(Color.P4CE.text)
                Text(message)
                    .font(Font.Style.sessionName)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.P4CE.textDim)
                    .padding(.horizontal, AppSpacing.space8.value)
            }
        }
    }
}
