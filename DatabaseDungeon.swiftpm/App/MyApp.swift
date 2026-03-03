import SwiftUI
import ARKit

@main
struct DatabaseDungeonApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// ContentView routes to the AR experience on supported devices,
// or to the demo/info view on Mac and older hardware.
struct ContentView: View {
    private var supportsAR: Bool {
        ARWorldTrackingConfiguration.isSupported
    }

    var body: some View {
        if supportsAR {
            ARDungeonView()
        } else {
            DemoView()
        }
    }
}
