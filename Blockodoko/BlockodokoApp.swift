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
    @StateObject var navigationManager: NavigationManager = .shared

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationManager.path) {
                MainGameView()
                    .environmentObject(viewModel)
                    .environmentObject(navigationManager)
                    .preferredColorScheme(.dark)
                    .navigationDestination(for: NavigationView<AnyView>.self) { destination in
                        destination
                    }
            }
        }
    }
}
