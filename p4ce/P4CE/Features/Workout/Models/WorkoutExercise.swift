import Foundation
import SwiftData

@Model
final class WorkoutExercise {
    @Attribute(.unique)
    var id: UUID

    var name: String

    /// Display / sort order inside the owning session (0-based).
    var order: Int

    /// Links to ``CoreLift`` when this slot is one of the app’s curated lifts (`nil` for custom work).
    var liftRaw: String?

    var coreLift: CoreLift? {
        get {
            guard let liftRaw else { return nil }
            return CoreLift(rawValue: liftRaw)
        }
        set {
            liftRaw = newValue?.rawValue
        }
    }

    var session: WorkoutSession?

    @Relationship(deleteRule: .cascade, inverse: \SetEntry.exercise)
    var sets: [SetEntry]

    init(
        id: UUID = UUID(),
        name: String,
        order: Int = 0,
        coreLift: CoreLift? = nil,
        session: WorkoutSession? = nil,
        sets: [SetEntry] = []
    ) {
        self.id = id
        self.name = name
        self.order = order
        liftRaw = coreLift?.rawValue
        self.session = session
        self.sets = sets
    }
}
