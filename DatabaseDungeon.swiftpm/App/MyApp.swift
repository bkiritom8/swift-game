import SwiftUI
import ARKit

/**
 Database Dungeon - Main Application Entry Point

 This app teaches SQL concepts through an immersive AR dungeon crawler experience.

 The app automatically detects device capabilities:
 - iPhone/iPad with ARKit support → Full AR experience
 - Mac or devices without ARKit → Demo mode with preview
 */

@main
struct DatabaseDungeonApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

/**
 ContentView - Main view that handles device detection

 This view checks if the device supports ARKit and displays the appropriate experience:
 - ARDungeonView for AR-capable devices (iPhone/iPad with ARKit)
 - DemoView for non-AR devices (Mac, older devices)
 */
struct ContentView: View {
    // Check if the device supports ARKit World Tracking (needed for plane detection)
    // ARWorldTrackingConfiguration requires a device with an A9 processor or later
    private var supportsAR: Bool {
        ARWorldTrackingConfiguration.isSupported
    }

    var body: some View {
        if supportsAR {
            // Device supports AR - show full AR experience
            ARDungeonView()
        } else {
            // Device doesn't support AR - show demo/preview mode
            DemoView()
        }
    }
}
