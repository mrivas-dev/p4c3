import Foundation

enum CoreLift: String, Codable, CaseIterable {
    case backSquat = "Back Squat"
    case frontSquat = "Front Squat"
    case deadlift = "Deadlift"
    case benchPress = "Bench Press"
    case snatch = "Snatch"
    case cleanAndJerk = "Clean & Jerk"
}

enum ExperienceLevel: String, Codable, CaseIterable {
    case beginner
    case intermediate
    case advanced
    case elite

    var displayTitle: String {
        rawValue.capitalized
    }
}

enum UnitSystem: String, Codable, CaseIterable {
    case kg
    case lb
}
