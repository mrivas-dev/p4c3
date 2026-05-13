import Foundation
import Observation

/// Dashboard copy and metric snapshot — stub data until SwiftData wiring (P4CE-6).
@Observable
final class DashboardViewModel {
    var workoutHeadline: String
    var workoutDetail: String
    var lastSessionLabel: String
    var lastSessionValue: String
    var weeklyVolumeLabel: String
    var weeklyVolumeValue: String

    init(
        workoutHeadline: String = "Back squat — strength",
        workoutDetail: String = "5 × 5 @ 82% · est. time 35m",
        lastSessionLabel: String = "Last session",
        lastSessionValue: String = "Mon · Vol 12.4t",
        weeklyVolumeLabel: String = "Week volume",
        weeklyVolumeValue: String = "38.2t"
    ) {
        self.workoutHeadline = workoutHeadline
        self.workoutDetail = workoutDetail
        self.lastSessionLabel = lastSessionLabel
        self.lastSessionValue = lastSessionValue
        self.weeklyVolumeLabel = weeklyVolumeLabel
        self.weeklyVolumeValue = weeklyVolumeValue
    }
}
