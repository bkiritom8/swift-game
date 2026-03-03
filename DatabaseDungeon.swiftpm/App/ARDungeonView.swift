import SwiftUI
import ARKit
import RealityKit

// ARDungeonView is the main AR experience screen.
// It wraps ARViewContainer (a UIViewRepresentable) with a SwiftUI overlay
// that shows coaching instructions and a placement hint.
struct ARDungeonView: View {
    @StateObject private var dungeonScene = DungeonScene()
    @State private var isDungeonPlaced = false
    @State private var coachingMessage = "Point camera at the floor or a table"

    var body: some View {
        ZStack {
            ARViewContainer(
                dungeonScene: dungeonScene,
                isDungeonPlaced: $isDungeonPlaced,
                coachingMessage: $coachingMessage
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                instructionPanel
                Spacer()
                if !isDungeonPlaced {
                    placementHint
                }
            }
            .padding()
        }
    }

    private var instructionPanel: some View {
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
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.7)))
        .padding(.top, 50)
    }

    private var placementHint: some View {
        HStack(spacing: 12) {
            Image(systemName: "hand.tap").font(.title3)
            Text("Tap the surface indicator to place dungeon").font(.subheadline)
        }
        .foregroundColor(.white)
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.purple.opacity(0.8)))
        .padding(.bottom, 40)
    }
}

// ARViewContainer bridges ARView (UIKit) into SwiftUI via UIViewRepresentable.
struct ARViewContainer: UIViewRepresentable {
    let dungeonScene: DungeonScene
    @Binding var isDungeonPlaced: Bool
    @Binding var coachingMessage: String

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)

        // Disable auto-session so our manual configuration isn't overridden when the view appears.
        arView.automaticallyConfigureSession = false

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)

        let coordinator = context.coordinator
        coordinator.arView = arView
        coordinator.dungeonScene = dungeonScene

        let tap = UITapGestureRecognizer(target: coordinator,
                                         action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tap)
        arView.session.delegate = coordinator

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Keep coordinator bindings fresh whenever SwiftUI re-renders.
        context.coordinator.isDungeonPlaced = $isDungeonPlaced
        context.coordinator.coachingMessage = $coachingMessage
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    // Coordinator handles ARSession events and gesture input.
    class Coordinator: NSObject, ARSessionDelegate {
        var arView: ARView?
        var dungeonScene: DungeonScene?
        var isDungeonPlaced: Binding<Bool>?
        var coachingMessage: Binding<String>?

        // Track both the model and its parent anchor so we can cleanly remove both.
        private var placementIndicator: ModelEntity?
        private var indicatorAnchor: AnchorEntity?

        // Throttle: session(_:didUpdate:frame:) fires at 60 fps — only process every 30th frame.
        private var frameCount = 0

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let arView = arView, let dungeonScene = dungeonScene else { return }
            let location = recognizer.location(in: arView)

            if isDungeonPlaced?.wrappedValue == false {
                placeDungeon(at: location, in: arView)
            } else {
                dungeonScene.movePlayer(to: location, in: arView)
            }
        }

        private func placeDungeon(at point: CGPoint, in arView: ARView) {
            let results = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal)
            guard let hit = results.first else { return }

            removeIndicator()
            dungeonScene?.createDungeon(at: hit.worldTransform, in: arView)
            isDungeonPlaced?.wrappedValue = true
            coachingMessage?.wrappedValue = "Tap on the ground to move your character"
        }

        // Called on the ARSession's internal queue — throttle and dispatch UI work to main.
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            frameCount += 1
            guard frameCount % 30 == 0 else { return } // ~2 updates/second
            frameCount = 0

            guard isDungeonPlaced?.wrappedValue == false, arView != nil else { return }

            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                      let arView = self.arView,
                      self.isDungeonPlaced?.wrappedValue == false else { return }

                let center = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
                let results = arView.raycast(from: center, allowing: .estimatedPlane, alignment: .horizontal)

                if let hit = results.first {
                    self.updatePlacementIndicator(at: hit.worldTransform, in: arView)
                    self.coachingMessage?.wrappedValue = "Surface detected! Tap to place dungeon"
                } else {
                    self.removeIndicator()
                    self.coachingMessage?.wrappedValue = "Point camera at the floor or a table"
                }
            }
        }

        private func updatePlacementIndicator(at transform: simd_float4x4, in arView: ARView) {
            let position = SIMD3<Float>(
                transform.columns.3.x,
                transform.columns.3.y,
                transform.columns.3.z
            )

            if placementIndicator == nil {
                let indicator = ModelEntity(
                    mesh: .generateBox(width: 0.5, height: 0.01, depth: 0.5, cornerRadius: 0.01),
                    materials: [SimpleMaterial(
                        color: .purple.withAlphaComponent(0.6),
                        isMetallic: false
                    )]
                )
                let anchor = AnchorEntity(world: position)
                anchor.addChild(indicator)
                arView.scene.addAnchor(anchor)
                placementIndicator = indicator
                indicatorAnchor = anchor
            } else {
                // Move the existing anchor to follow the detected plane.
                indicatorAnchor?.position = position
            }
        }

        private func removeIndicator() {
            indicatorAnchor?.removeFromParent()
            indicatorAnchor = nil
            placementIndicator = nil
        }
    }
}
