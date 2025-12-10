import SwiftUI

@main
struct BlockodokoApp: App {
    var body: some Scene {
        WindowGroup {
            MainGameView()
                .preferredColorScheme(.dark) // Force dark mode as per design
        }
    }
}
