import SwiftUI
import ARKit
import RealityKit
import AVFoundation

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
        // We manage the session manually via updateUIView to ensure the view
        // has real bounds and all coordinator bindings are set before starting.
        arView.automaticallyConfigureSession = false

        let coordinator = context.coordinator
        coordinator.arView = arView
        coordinator.dungeonScene = dungeonScene
        arView.session.delegate = coordinator

        let tap = UITapGestureRecognizer(target: coordinator,
                                         action: #selector(Coordinator.handleTap(_:)))
        arView.addGestureRecognizer(tap)

        return arView
    }

    // updateUIView is called after the view has been laid out with real bounds.
    // We start the AR session here (once) so the view is properly sized and
    // all coordinator bindings are guaranteed to be set.
    func updateUIView(_ uiView: ARView, context: Context) {
        let coordinator = context.coordinator
        coordinator.isDungeonPlaced = $isDungeonPlaced
        coordinator.coachingMessage = $coachingMessage

        if !coordinator.sessionStarted {
            coordinator.sessionStarted = true
            coordinator.startARSession()
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    // Coordinator handles ARSession events and gesture input.
    class Coordinator: NSObject, ARSessionDelegate {
        var arView: ARView?
        var dungeonScene: DungeonScene?
        var isDungeonPlaced: Binding<Bool>?
        var coachingMessage: Binding<String>?
        var sessionStarted = false

        private var placementIndicator: ModelEntity?
        private var indicatorAnchor: AnchorEntity?
        private var frameCount = 0

        // Called from updateUIView on main thread — safe to call session.run() here.
        func startARSession() {
            // Explicitly request camera permission so the iOS dialog appears.
            // session.run() alone does not reliably trigger the prompt in Swift Playgrounds.
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self = self, let arView = self.arView else { return }
                    guard granted else {
                        self.coachingMessage?.wrappedValue =
                            "Camera access denied — enable it in Settings \u{203A} Privacy \u{203A} Camera"
                        return
                    }
                    let configuration = ARWorldTrackingConfiguration()
                    configuration.planeDetection = [.horizontal]
                    configuration.environmentTexturing = .automatic
                    arView.session.run(configuration)
                }
            }
        }

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

        // Surface AR session errors into the coaching label so they're visible.
        func session(_ session: ARSession, didFailWithError error: Error) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if let arError = error as? ARError, arError.code == .cameraUnauthorized {
                    self.coachingMessage?.wrappedValue =
                        "Camera access denied — enable it in Settings \u{203A} Privacy \u{203A} Camera"
                } else {
                    self.coachingMessage?.wrappedValue = "AR failed: \(error.localizedDescription)"
                }
            }
        }

        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            // frameCount is only ever touched on ARKit's serial queue — safe to read/write here.
            frameCount += 1
            guard frameCount % 30 == 0 else { return }
            frameCount = 0

            // All other state (@Binding, ARView) is main-thread-owned — never read it here.
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
