import SwiftUI
import ARKit
import RealityKit

/**
 ARDungeonView - The main AR experience view

 This view sets up and manages the AR session where the dungeon is placed in the real world.

 Key ARKit Concepts:
 - ARView: A RealityKit view that displays AR content
 - ARSession: Manages the AR experience lifecycle
 - Plane Detection: ARKit can detect horizontal/vertical surfaces in the real world
 - Anchors: Points in the real world where we attach virtual content

 User Flow:
 1. App launches and requests camera permission
 2. Point camera at a floor or table surface
 3. ARKit detects the plane and places a visual indicator
 4. Tap the indicator to place the dungeon
 5. Once placed, tap on the ground to move your character
 */

struct ARDungeonView: View {
    // StateObject creates and manages the DungeonScene throughout the view's lifetime
    @StateObject private var dungeonScene = DungeonScene()

    // Track whether the user has placed the dungeon yet
    @State private var isDungeonPlaced = false

    // Track coaching state - helps user understand what to do
    @State private var coachingMessage = "Point camera at the floor or a table"

    var body: some View {
        ZStack {
            // The main AR view that shows the camera feed and virtual content
            ARViewContainer(
                dungeonScene: dungeonScene,
                isDungeonPlaced: $isDungeonPlaced,
                coachingMessage: $coachingMessage
            )
            .edgesIgnoringSafeArea(.all)

            // Overlay UI with instructions
            VStack {
                // Top instruction panel
                VStack(spacing: 8) {
                    Text("Database Dungeon")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text(coachingMessage)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.black.opacity(0.7))
                )
                .padding(.top, 50)

                Spacer()

                // Bottom hint panel (only show before dungeon is placed)
                if !isDungeonPlaced {
                    HStack(spacing: 12) {
                        Image(systemName: "hand.tap")
                            .font(.title3)
                        Text("Tap the surface indicator to place dungeon")
                            .font(.subheadline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.purple.opacity(0.8))
                    )
                    .padding(.bottom, 40)
                }
            }
            .padding()
        }
    }
}

/**
 ARViewContainer - UIViewRepresentable wrapper for ARView

 SwiftUI doesn't directly support ARView, so we use UIViewRepresentable to bridge UIKit and SwiftUI.
 This is a common pattern when integrating UIKit components into SwiftUI.
 */
struct ARViewContainer: UIViewRepresentable {
    let dungeonScene: DungeonScene

    @Binding var isDungeonPlaced: Bool
    @Binding var coachingMessage: String

    // Creates the ARView when SwiftUI first renders this view
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Set up the AR session configuration
        // ARWorldTrackingConfiguration enables:
        // - 6DOF tracking (device position and rotation)
        // - Plane detection
        // - Light estimation
        let configuration = ARWorldTrackingConfiguration()

        // Enable horizontal plane detection (floors, tables)
        // This allows ARKit to identify flat surfaces where we can place the dungeon
        configuration.planeDetection = [.horizontal]

        // Enable realistic lighting based on the real environment
        configuration.environmentTexturing = .automatic

        // Start the AR session
        arView.session.run(configuration)

        // Set up the scene coordinator to handle AR interactions
        let coordinator = context.coordinator
        coordinator.arView = arView
        coordinator.dungeonScene = dungeonScene

        // Add tap gesture recognizer for placing dungeon and moving player
        let tapGesture = UITapGestureRecognizer(
            target: coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tapGesture)

        // Subscribe to AR session updates
        arView.session.delegate = coordinator

        return arView
    }

    // Called when SwiftUI updates the view (we don't need to do anything here)
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update coordinator bindings
        context.coordinator.isDungeonPlaced = $isDungeonPlaced
        context.coordinator.coachingMessage = $coachingMessage
    }

    // Creates the coordinator that handles AR events
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    /**
     Coordinator - Handles AR session events and user interactions

     The Coordinator pattern is used by UIViewRepresentable to manage the lifecycle
     and events of the UIKit view (ARView in this case).
     */
    class Coordinator: NSObject, ARSessionDelegate {
        var arView: ARView?
        var dungeonScene: DungeonScene?

        var isDungeonPlaced: Binding<Bool>?
        var coachingMessage: Binding<String>?

        // Visual indicator for where the dungeon will be placed
        var placementIndicator: ModelEntity?

        // Called when user taps the screen
        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = arView,
                  let dungeonScene = dungeonScene else { return }

            // Get the tap location in the view
            let tapLocation = recognizer.location(in: arView)

            if let isDungeonPlaced = isDungeonPlaced?.wrappedValue,
               !isDungeonPlaced {
                // Dungeon not placed yet - try to place it on a detected plane
                placeDungeon(at: tapLocation, in: arView)
            } else {
                // Dungeon already placed - move player to tapped location
                dungeonScene.movePlayer(to: tapLocation, in: arView)
            }
        }

        // Places the dungeon on a detected plane
        private func placeDungeon(at point: CGPoint, in arView: ARView) {
            // Raycast from the tap point to find a horizontal plane
            // Raycasting shoots a virtual ray from the screen point into the AR world
            let results = arView.raycast(
                from: point,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )

            // If we hit a plane, place the dungeon there
            if let firstResult = results.first {
                // Remove the placement indicator if it exists
                placementIndicator?.removeFromParent()

                // Create and add the dungeon at the raycast hit location
                dungeonScene?.createDungeon(at: firstResult.worldTransform, in: arView)

                // Update state
                isDungeonPlaced?.wrappedValue = true
                coachingMessage?.wrappedValue = "Tap on the ground to move your character"
            }
        }

        // ARSessionDelegate method - called when ARKit detects or updates planes
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // Only show indicator if dungeon hasn't been placed
            guard let isDungeonPlaced = isDungeonPlaced?.wrappedValue,
                  !isDungeonPlaced,
                  let arView = arView else { return }

            // Raycast from center of screen to find planes
            let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
            let results = arView.raycast(
                from: center,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )

            if let firstResult = results.first {
                // Plane detected - show or update indicator
                updatePlacementIndicator(at: firstResult.worldTransform, in: arView)
                coachingMessage?.wrappedValue = "Surface detected! Tap to place dungeon"
            } else {
                // No plane detected - remove indicator
                placementIndicator?.removeFromParent()
                placementIndicator = nil
                coachingMessage?.wrappedValue = "Point camera at the floor or a table"
            }
        }

        // Shows a visual indicator where the dungeon will be placed
        private func updatePlacementIndicator(at transform: simd_float4x4, in arView: ARView) {
            if placementIndicator == nil {
                // Create a simple circular indicator
                let indicator = ModelEntity(
                    mesh: .generateBox(width: 0.5, height: 0.01, depth: 0.5, cornerRadius: 0.01),
                    materials: [SimpleMaterial(
                        color: .purple.withAlphaComponent(0.6),
                        isMetallic: false
                    )]
                )

                // Create anchor entity at world origin
                let anchor = AnchorEntity(world: .zero)
                anchor.addChild(indicator)
                arView.scene.addAnchor(anchor)

                placementIndicator = indicator
            }

            // Update indicator position to match the plane
            if let indicator = placementIndicator {
                // Extract position from transform matrix
                let position = SIMD3<Float>(
                    transform.columns.3.x,
                    transform.columns.3.y,
                    transform.columns.3.z
                )
                indicator.position = position
            }
        }
    }
}
