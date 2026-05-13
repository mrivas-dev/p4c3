import SwiftData
import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview("ContentView") {
    ContentView()
        .preferredColorScheme(.dark)
        .modelContainer(for: SeedModel.self, inMemory: true)
}
