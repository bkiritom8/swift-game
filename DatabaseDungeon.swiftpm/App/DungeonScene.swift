import RealityKit
import ARKit

// DungeonScene manages the 3D dungeon environment and player character.
// It creates the room geometry, player, and lighting, and handles tap-to-move.
class DungeonScene: ObservableObject {
    private var dungeonAnchor: AnchorEntity?
    private var playerEntity: ModelEntity?
    private var playerPosition: SIMD3<Float> = [0, 0.1, 0]

    // Dungeon dimensions in meters
    private let dungeonWidth: Float = 1.0
    private let dungeonDepth: Float = 1.0
    private let dungeonHeight: Float = 0.5
    private let wallThickness: Float = 0.05

    // Creates the full dungeon at the given AR world transform (from a raycast hit).
    func createDungeon(at transform: simd_float4x4, in arView: ARView) {
        let anchor = AnchorEntity(world: transform)
        createDungeonRoom(in: anchor)
        createPlayer(in: anchor)
        createLighting(in: anchor)
        arView.scene.addAnchor(anchor)
        dungeonAnchor = anchor
    }

    private func createDungeonRoom(in anchor: AnchorEntity) {
        // Floor
        let floor = ModelEntity(
            mesh: .generateBox(width: dungeonWidth, height: 0.02, depth: dungeonDepth),
            materials: [SimpleMaterial(color: .gray.withAlphaComponent(0.8), isMetallic: false)]
        )
        floor.position = [0, 0, 0]
        floor.generateCollisionShapes(recursive: false)
        anchor.addChild(floor)

        // Four walls defined as (position, shouldRotate90°)
        let wallConfigs: [(SIMD3<Float>, Bool)] = [
            ([0,  dungeonHeight / 2,  dungeonDepth / 2], false), // North
            ([0,  dungeonHeight / 2, -dungeonDepth / 2], false), // South
            ([ dungeonWidth / 2, dungeonHeight / 2, 0], true),   // East
            ([-dungeonWidth / 2, dungeonHeight / 2, 0], true),   // West
        ]
        for (position, rotate) in wallConfigs {
            let wall = createWall()
            wall.position = position
            if rotate {
                wall.orientation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
            }
            anchor.addChild(wall)
        }

        // Ceiling
        let ceiling = ModelEntity(
            mesh: .generateBox(width: dungeonWidth, height: 0.02, depth: dungeonDepth),
            materials: [SimpleMaterial(color: .darkGray.withAlphaComponent(0.9), isMetallic: false)]
        )
        ceiling.position = [0, dungeonHeight, 0]
        anchor.addChild(ceiling)
    }

    private func createWall() -> ModelEntity {
        ModelEntity(
            mesh: .generateBox(width: dungeonWidth, height: dungeonHeight, depth: wallThickness),
            materials: [SimpleMaterial(
                color: .init(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0),
                roughness: 0.9,
                isMetallic: false
            )]
        )
    }

    private func createPlayer(in anchor: AnchorEntity) {
        let player = ModelEntity(
            mesh: .generateSphere(radius: 0.05),
            materials: [SimpleMaterial(color: .cyan, roughness: 0.3, isMetallic: true)]
        )
        player.position = playerPosition
        player.generateCollisionShapes(recursive: false)
        anchor.addChild(player)
        playerEntity = player
    }

    private func createLighting(in anchor: AnchorEntity) {
        let light = PointLight()
        light.light.intensity = 800
        light.light.color = .init(red: 0.8, green: 0.7, blue: 0.9, alpha: 1.0)
        light.position = [0, dungeonHeight * 0.8, 0]
        anchor.addChild(light)
    }

    // Raycasts from a screen tap and moves the player to the hit point on the floor.
    func movePlayer(to point: CGPoint, in arView: ARView) {
        guard let dungeonAnchor = dungeonAnchor,
              let playerEntity = playerEntity else { return }

        let results = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal)
        guard let hit = results.first else { return }

        let worldPos = SIMD3<Float>(
            hit.worldTransform.columns.3.x,
            hit.worldTransform.columns.3.y,
            hit.worldTransform.columns.3.z
        )
        let localPos = dungeonAnchor.convert(position: worldPos, from: nil)

        // Clamp to stay 10 cm inside the walls
        let halfWidth = dungeonWidth / 2 - 0.1
        let halfDepth = dungeonDepth / 2 - 0.1
        let target = SIMD3<Float>(
            max(-halfWidth, min(halfWidth, localPos.x)),
            0.1,
            max(-halfDepth, min(halfDepth, localPos.z))
        )

        let distance = simd_distance(playerEntity.position, target)
        let duration = min(max(Double(distance * 2), 0.3), 1.0)

        var newTransform = playerEntity.transform
        newTransform.translation = target
        playerEntity.move(to: newTransform, relativeTo: playerEntity.parent,
                          duration: duration, timingFunction: .easeInOut)
        playerPosition = target
    }
}
