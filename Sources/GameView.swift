import SwiftUI
import SpriteKit

/// SwiftUI view that hosts the SpriteKit game scene
/// This bridges SwiftUI (required for Swift Playgrounds) with SpriteKit (game engine)
struct GameView: View {

    // Create the game scene
    // We use @State to ensure the scene persists across view updates
    @State private var scene: GameScene = {
        let scene = GameScene()
        scene.scaleMode = .resizeFill // Adapt to different screen sizes
        return scene
    }()

    var body: some View {
        ZStack {
            // SpriteKit game scene takes up the full view
            SpriteView(scene: scene)
                .ignoresSafeArea()

            // Optional: Add SwiftUI overlay for UI elements later
            // (e.g., SQL query input, inventory, health bars)
            VStack {
                Spacer()
                // Future: Add game UI here
            }
            .allowsHitTesting(false) // Don't block touches to the game scene
        }
        .background(Color.black) // Fallback background color
    }
}

#Preview {
    GameView()
}
