import SwiftUI

/// Settings entry (not a root tab in MVP) — reached from Dashboard toolbar.
struct SettingsRootView: View {
    var body: some View {
        ZStack {
            Color.P4CE.bg.ignoresSafeArea()
            VStack(spacing: AppSpacing.space4.value) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.P4CE.muted)
                Text("Settings")
                    .font(Font.Style.sectionDate)
                    .foregroundStyle(Color.P4CE.text)
                Text("Profile, 1RMs, and preferences will live here.")
                    .font(Font.Style.sessionName)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.P4CE.textDim)
                    .padding(.horizontal, AppSpacing.space8.value)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.P4CE.bg, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview("SettingsRootView") {
    NavigationStack {
        SettingsRootView()
    }
    .preferredColorScheme(.dark)
}
