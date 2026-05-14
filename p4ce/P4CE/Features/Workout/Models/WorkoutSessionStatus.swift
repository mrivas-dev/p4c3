import Foundation

enum WorkoutSessionStatus: String, Codable {
    case inProgress
    case finished
    /// Session was discarded (e.g. to start over); hidden from banners and workout history queries.
    case abandoned
}
