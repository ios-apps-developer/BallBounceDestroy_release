import SwiftUI

@main
struct BallBounceDestroyApp: App {
    @StateObject private var shopManager = ShopManager()
    @StateObject private var gameCoordinator = GameCoordinator()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shopManager)
                .environmentObject(gameCoordinator)
        }
    }
}
