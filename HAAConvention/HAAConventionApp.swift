import SwiftUI

@main
struct HAAConventionApp: App {
    @StateObject private var auth = AuthViewModel()
    @StateObject private var network = NetworkMonitor()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(auth)
                .environmentObject(network)
                .preferredColorScheme(.light)
        }
    }
}
