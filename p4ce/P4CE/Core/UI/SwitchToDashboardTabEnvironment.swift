import SwiftUI

private struct SwitchToDashboardTabKey: EnvironmentKey {
    static let defaultValue: @Sendable () -> Void = {}
}

extension EnvironmentValues {
    /// Switches the tab shell to Dashboard — set from ``MainTabView`` after a workout is saved.
    var switchToDashboardTab: @Sendable () -> Void {
        get { self[SwitchToDashboardTabKey.self] }
        set { self[SwitchToDashboardTabKey.self] = newValue }
    }
}
