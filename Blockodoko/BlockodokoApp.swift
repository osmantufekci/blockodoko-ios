import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct BlockodokoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            MainGameView()
                .environmentObject(viewModel)
                .preferredColorScheme(.dark) // Force dark mode as per design
        }
    }
}
