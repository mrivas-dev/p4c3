import Foundation
import SwiftData

/// Minimal schema seed so `ModelContainer` can be created at launch. Replace with real models in later tickets.
@Model
final class SeedModel {
    var id: UUID

    init(id: UUID = UUID()) {
        self.id = id
    }
}
