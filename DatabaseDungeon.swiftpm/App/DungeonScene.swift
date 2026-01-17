import RealityKit
import ARKit
import Combine

/**
 DungeonScene - Manages the 3D dungeon environment and player character

 This class is responsible for:
 - Creating the dungeon room (floor, walls, ceiling)
 - Spawning the player character
 - Handling player movement
 - Managing game state

 RealityKit Key Concepts:
 - Entity: Any object in the 3D scene (like a game object)
 - ModelEntity: An entity with a 3D mesh and materials
 - AnchorEntity: Attaches entities to real-world positions
 - Materials: Define how surfaces look (color, texture, metallic, etc.)
 */

class DungeonScene: ObservableObject {
    // The root anchor that holds all dungeon entities
    private var dungeonAnchor: AnchorEntity?

    // Reference to the player character entity
    private var playerEntity: ModelEntity?

    // Current player position in the dungeon's local coordinate system
    private var playerPosition: SIMD3<Float> = [0, 0.1, 0]

    // Dungeon dimensions (in meters)
    private let dungeonWidth: Float = 1.0    // 1 meter wide
    private let dungeonDepth: Float = 1.0    // 1 meter deep
    private let dungeonHeight: Float = 0.5   // 0.5 meters tall
    private let wallThickness: Float = 0.05  // 5cm thick walls

    /**
     Creates the dungeon at the specified world position

     - Parameter transform: The 4x4 transformation matrix defining position and rotation
                           This comes from ARKit's plane detection raycast
     - Parameter arView: The AR view to add the dungeon to
     */
    func createDungeon(at transform: simd_float4x4, in arView: ARView) {
        // Create an anchor at the specified world position
        // The anchor acts as the "root" of our dungeon - everything is positioned relative to it
        let anchor = AnchorEntity(world: transform)

        // Build the dungeon room components
        createDungeonRoom(in: anchor)

        // Spawn the player character in the center of the room
        createPlayer(in: anchor)

        // Add atmospheric lighting
        createLighting(in: anchor)

        // Add the anchor to the AR scene
        arView.scene.addAnchor(anchor)

        // Store reference to the anchor
        self.dungeonAnchor = anchor
    }

    /**
     Creates the dungeon room structure (floor, walls, ceiling)

     The room is built from simple box geometries with dark materials to create
     a dungeon aesthetic. In future iterations, these could be replaced with
     custom 3D models or textures.
     */
    private func createDungeonRoom(in anchor: AnchorEntity) {
        // --- FLOOR ---
        // Create a flat box for the floor
        let floor = ModelEntity(
            mesh: .generateBox(
                width: dungeonWidth,
                height: 0.02,  // Thin floor (2cm)
                depth: dungeonDepth
            ),
            materials: [SimpleMaterial(
                color: .gray.withAlphaComponent(0.8),  // Dark gray stone floor
                isMetallic: false
            )]
        )
        floor.position = [0, 0, 0]  // Floor at ground level
        anchor.addChild(floor)

        // Add collision component so we can raycast to the floor for movement
        floor.generateCollisionShapes(recursive: false)

        // --- WALLS ---
        // We'll create 4 walls (north, south, east, west)

        // North wall (back wall, positive Z)
        let northWall = createWall()
        northWall.position = [0, dungeonHeight / 2, dungeonDepth / 2]
        anchor.addChild(northWall)

        // South wall (front wall, negative Z)
        let southWall = createWall()
        southWall.position = [0, dungeonHeight / 2, -dungeonDepth / 2]
        anchor.addChild(southWall)

        // East wall (right wall, positive X)
        let eastWall = createWall()
        eastWall.position = [dungeonWidth / 2, dungeonHeight / 2, 0]
        eastWall.orientation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])  // Rotate 90°
        anchor.addChild(eastWall)

        // West wall (left wall, negative X)
        let westWall = createWall()
        westWall.position = [-dungeonWidth / 2, dungeonHeight / 2, 0]
        westWall.orientation = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])  // Rotate 90°
        anchor.addChild(westWall)

        // --- CEILING ---
        // Optional: Add a ceiling for enclosed feeling
        let ceiling = ModelEntity(
            mesh: .generateBox(
                width: dungeonWidth,
                height: 0.02,
                depth: dungeonDepth
            ),
            materials: [SimpleMaterial(
                color: .darkGray.withAlphaComponent(0.9),
                isMetallic: false
            )]
        )
        ceiling.position = [0, dungeonHeight, 0]
        anchor.addChild(ceiling)
    }

    /**
     Creates a single wall entity

     Helper function to create wall geometry with dungeon aesthetic
     */
    private func createWall() -> ModelEntity {
        let wall = ModelEntity(
            mesh: .generateBox(
                width: dungeonWidth,
                height: dungeonHeight,
                depth: wallThickness
            ),
            materials: [SimpleMaterial(
                color: .init(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0),  // Dark brown stone
                roughness: 0.9,  // Rough surface (not shiny)
                isMetallic: false
            )]
        )
        return wall
    }

    /**
     Creates the player character

     For now, this is a simple colored sphere. In future iterations, this could be
     replaced with a character model or SQL-themed representation.
     */
    private func createPlayer(in anchor: AnchorEntity) {
        // Create a sphere to represent the player
        // The sphere is 10cm in diameter (0.1m radius)
        let player = ModelEntity(
            mesh: .generateSphere(radius: 0.05),
            materials: [SimpleMaterial(
                color: .cyan,  // Bright cyan color stands out in dark dungeon
                roughness: 0.3,  // Slightly shiny, magical appearance
                isMetallic: true
            )]
        )

        // Position player in center of room, slightly above floor
        player.position = playerPosition

        // Enable collision detection for raycasting
        player.generateCollisionShapes(recursive: false)

        // Add to scene
        anchor.addChild(player)

        // Store reference
        self.playerEntity = player
    }

    /**
     Adds atmospheric lighting to the dungeon

     Creates dim, moody lighting appropriate for a dungeon environment
     */
    private func createLighting(in anchor: AnchorEntity) {
        // Create a point light above the player
        // Point lights emit light in all directions from a single point
        let light = PointLight()
        light.light.intensity = 800  // Dim lighting for atmosphere
        light.light.color = .init(red: 0.8, green: 0.7, blue: 0.9, alpha: 1.0)  // Slight purple tint

        // Position light in center of room, near ceiling
        light.position = [0, dungeonHeight * 0.8, 0]

        anchor.addChild(light)
    }

    /**
     Moves the player to a tapped location

     - Parameter point: The screen coordinates where the user tapped
     - Parameter arView: The AR view to perform raycasting
     */
    func movePlayer(to point: CGPoint, in arView: ARView) {
        guard let dungeonAnchor = dungeonAnchor,
              let playerEntity = playerEntity else { return }

        // Perform a raycast from the tap point to find what was hit in the scene
        // We're looking for collision with the dungeon floor
        let results = arView.raycast(
            from: point,
            allowing: .estimatedPlane,
            alignment: .horizontal
        )

        if let firstResult = results.first {
            // Convert the hit position from world coordinates to dungeon local coordinates
            // This is necessary because the dungeon anchor might be rotated or offset
            let worldPosition = SIMD3<Float>(
                firstResult.worldTransform.columns.3.x,
                firstResult.worldTransform.columns.3.y,
                firstResult.worldTransform.columns.3.z
            )

            // Convert to local space relative to dungeon anchor
            let localPosition = dungeonAnchor.convert(position: worldPosition, from: nil)

            // Clamp position to stay within dungeon bounds
            let halfWidth = dungeonWidth / 2 - 0.1  // 10cm margin from walls
            let halfDepth = dungeonDepth / 2 - 0.1

            let clampedX = max(-halfWidth, min(halfWidth, localPosition.x))
            let clampedZ = max(-halfDepth, min(halfDepth, localPosition.z))

            // Keep player slightly above floor
            let targetPosition = SIMD3<Float>(clampedX, 0.1, clampedZ)

            // Animate the player movement
            animatePlayerMovement(to: targetPosition)
        }
    }

    /**
     Animates smooth player movement to target position

     Uses RealityKit's animation system to create smooth movement
     */
    private func animatePlayerMovement(to targetPosition: SIMD3<Float>) {
        guard let playerEntity = playerEntity else { return }

        // Calculate movement duration based on distance (faster for short distances)
        let distance = simd_distance(playerEntity.position, targetPosition)
        let duration = min(max(Double(distance * 2), 0.3), 1.0)  // Between 0.3s and 1.0s

        // Create transform with new position
        var newTransform = playerEntity.transform
        newTransform.translation = targetPosition

        // Animate the movement
        playerEntity.move(
            to: newTransform,
            relativeTo: playerEntity.parent,
            duration: duration,
            timingFunction: .easeInOut
        )

        // Update stored position
        playerPosition = targetPosition
    }
}
