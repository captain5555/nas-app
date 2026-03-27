import SwiftUI

@main
struct NASMaterialManagerApp: App {
    @StateObject private var env = AppEnvironment.shared

    var body: some Scene {
        WindowGroup {
            if env.isLoggedIn {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
