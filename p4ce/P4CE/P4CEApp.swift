import SwiftData
import SwiftUI

@main
struct P4CEApp: App {
    private static func makeContainer() -> ModelContainer {
        let schema = Schema([SeedModel.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    private let modelContainer = makeContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(modelContainer)
    }
}
