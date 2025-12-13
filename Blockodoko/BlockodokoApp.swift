import SwiftUI
import FirebaseCore
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { self.requestTrackingPermission() }
        return true
    }

    func requestTrackingPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
            // İzin verilse de verilmese de reklam servisini başlat
            MobileAds.shared.start(completionHandler: nil)

            switch status {
            case .authorized:
                print("ATT: İzin Verildi ✅")
            case .denied, .restricted:
                print("ATT: İzin Verilmedi ❌")
            case .notDetermined:
                print("ATT: Belirsiz")
            @unknown default:
                break
            }
        }
    }
}

@main
struct BlockodokoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var viewModel = GameViewModel()
    @StateObject var adsManager = AdsManager.shared
    @StateObject var navigationManager: NavigationManager = .shared

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navigationManager.path) {
                MainGameView()
                    .environmentObject(viewModel)
                    .environmentObject(adsManager)
                    .preferredColorScheme(.dark)
                    .navigationDestination(for: NavigationView<AnyView>.self) { destination in
                        destination
                    }
            }
            .environmentObject(navigationManager)
        }
    }
}
