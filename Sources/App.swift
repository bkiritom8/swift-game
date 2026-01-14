import SwiftUI

/// Main entry point for the SQL Dungeon Crawler game
/// This app teaches SQL concepts through dungeon exploration gameplay
@main
struct SQLDungeonCrawlerApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .ignoresSafeArea() // Full-screen game experience
        }
    }
}
