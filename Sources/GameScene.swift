import SpriteKit
#if canImport(UIKit)
import UIKit
#endif

/// Main game scene for the SQL Dungeon Crawler
/// Handles the dungeon room, player, and input (touch/click)
class GameScene: SKScene {

    // MARK: - Properties

    /// The player character
    private var player: Player!

    /// Camera that follows the player
    private var gameCamera: SKCameraNode!

    /// World size configuration
    private let tileSize: CGFloat = 64
    private let worldWidthInTiles: Int = 30  // 30 tiles wide
    private let worldHeightInTiles: Int = 50 // 50 tiles tall

    /// Calculated world dimensions
    private var worldWidth: CGFloat { CGFloat(worldWidthInTiles) * tileSize }
    private var worldHeight: CGFloat { CGFloat(worldHeightInTiles) * tileSize }

    /// Dungeon room boundaries (margin from world edges)
    private let worldMargin: CGFloat = 40

    /// Minimum and maximum positions the player can move to
    private var minX: CGFloat = 0
    private var maxX: CGFloat = 0
    private var minY: CGFloat = 0
    private var maxY: CGFloat = 0

    // MARK: - Scene Lifecycle

    /// Called when the scene is first created
    override func didMove(to view: SKView) {
        setupScene()
        setupCamera()
        setupDungeonBackground()
        setupPlayer()
        calculateBoundaries()
    }

    // MARK: - Setup Methods

    /// Configure the scene properties
    private func setupScene() {
        // Dark background for dungeon atmosphere
        backgroundColor = SKColor(red: 0.15, green: 0.12, blue: 0.12, alpha: 1.0)

        // Set the scene size to the full world size
        // The camera will handle showing only the visible portion
        size = CGSize(width: worldWidth, height: worldHeight)

        // Ensure user interaction is enabled
        isUserInteractionEnabled = true

        // Debug: Print world and viewport sizes
        print("🗺️  World size: \(worldWidthInTiles)x\(worldHeightInTiles) tiles")
        print("🎮 Scene size: \(size) (\(worldWidth)x\(worldHeight) points)")
        if let view = view {
            print("📱 Viewport size: \(view.bounds.size)")
        }
    }

    /// Set up the camera to follow the player
    private func setupCamera() {
        gameCamera = SKCameraNode()
        camera = gameCamera
        addChild(gameCamera)

        print("📷 Camera created and attached to scene")
    }

    /// Create the dungeon room background
    /// Uses a grid of stone tiles for that classic dungeon feel
    /// Now covers the entire world (30x50 tiles)
    private func setupDungeonBackground() {
        // Stone floor color (dark gray with slight brown tint)
        let stoneColor = SKColor(red: 0.25, green: 0.23, blue: 0.21, alpha: 1.0)
        let darkerStone = SKColor(red: 0.20, green: 0.18, blue: 0.16, alpha: 1.0)

        // Create alternating stone tiles across the entire world
        for row in 0..<worldHeightInTiles {
            for col in 0..<worldWidthInTiles {
                let tile = SKSpriteNode(color: (row + col) % 2 == 0 ? stoneColor : darkerStone,
                                       size: CGSize(width: tileSize, height: tileSize))
                tile.position = CGPoint(x: CGFloat(col) * tileSize, y: CGFloat(row) * tileSize)
                tile.anchorPoint = CGPoint(x: 0, y: 0)
                tile.zPosition = -10 // Behind everything else
                addChild(tile)
            }
        }

        // Add walls around the world boundary
        createWalls()

        print("🏰 Dungeon background created: \(worldWidthInTiles)x\(worldHeightInTiles) tiles")
    }

    /// Create visible walls around the world boundary
    private func createWalls() {
        let wallColor = SKColor(red: 0.1, green: 0.08, blue: 0.08, alpha: 1.0)
        let wallThickness: CGFloat = worldMargin

        // Top wall (across entire world width)
        let topWall = SKSpriteNode(color: wallColor,
                                   size: CGSize(width: worldWidth, height: wallThickness))
        topWall.position = CGPoint(x: worldWidth / 2, y: worldHeight - wallThickness / 2)
        topWall.zPosition = -5
        addChild(topWall)

        // Bottom wall
        let bottomWall = SKSpriteNode(color: wallColor,
                                      size: CGSize(width: worldWidth, height: wallThickness))
        bottomWall.position = CGPoint(x: worldWidth / 2, y: wallThickness / 2)
        bottomWall.zPosition = -5
        addChild(bottomWall)

        // Left wall (across entire world height)
        let leftWall = SKSpriteNode(color: wallColor,
                                    size: CGSize(width: wallThickness, height: worldHeight))
        leftWall.position = CGPoint(x: wallThickness / 2, y: worldHeight / 2)
        leftWall.zPosition = -5
        addChild(leftWall)

        // Right wall
        let rightWall = SKSpriteNode(color: wallColor,
                                     size: CGSize(width: wallThickness, height: worldHeight))
        rightWall.position = CGPoint(x: worldWidth - wallThickness / 2, y: worldHeight / 2)
        rightWall.zPosition = -5
        addChild(rightWall)

        print("🧱 World walls created at boundaries")
    }

    /// Create and position the player character
    private func setupPlayer() {
        // Start player at the bottom-center of the world
        // This gives them room to explore upward and to the sides
        let startPosition = CGPoint(x: worldWidth / 2, y: worldHeight / 4)
        player = Player(position: startPosition)
        addChild(player)

        // Position camera at player's starting location
        gameCamera.position = startPosition

        print("👤 Player spawned at: \(startPosition)")
    }

    /// Calculate the boundaries where the player can move
    /// This prevents the player from walking into walls or leaving the world
    private func calculateBoundaries() {
        let playerRadius = player.size.width / 2

        minX = worldMargin + playerRadius
        maxX = worldWidth - worldMargin - playerRadius
        minY = worldMargin + playerRadius
        maxY = worldHeight - worldMargin - playerRadius

        print("🚧 World boundaries: X[\(minX) - \(maxX)], Y[\(minY) - \(maxY)]")
    }

    // MARK: - Input Handling

    #if os(iOS)
    /// Handle touch input on iPhone/iPad
    /// When the player taps, the character moves to that location
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("👆 Touch detected!")
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        print("📍 Touch location: \(location)")
        handleInput(at: location)
    }
    #endif

    #if os(macOS)
    /// Handle mouse click on Mac
    /// When the player clicks, the character moves to that location
    override func mouseDown(with event: NSEvent) {
        print("🖱️ Mouse click detected!")
        let location = event.location(in: self)
        print("📍 Click location: \(location)")
        handleInput(at: location)
    }
    #endif

    // MARK: - Movement Logic

    /// Process input from either touch or mouse
    /// Moves the player to the target location while respecting boundaries
    private func handleInput(at location: CGPoint) {
        print("🎯 handleInput called with location: \(location)")

        // Clamp the target position to stay within boundaries
        let targetX = max(minX, min(maxX, location.x))
        let targetY = max(minY, min(maxY, location.y))
        let clampedLocation = CGPoint(x: targetX, y: targetY)

        print("✅ Moving player to clamped location: \(clampedLocation)")

        // Tell the player to move to this location
        player.move(to: clampedLocation)
    }

    // MARK: - Update Loop

    /// Called every frame (60 times per second)
    /// Use this for continuous game logic updates
    override func update(_ currentTime: TimeInterval) {
        // Update camera to follow player smoothly
        updateCamera()
    }

    /// Smoothly move camera to follow the player
    private func updateCamera() {
        // Smoothly interpolate camera position toward player position
        let lerpFactor: CGFloat = 0.1 // Lower = smoother, higher = more responsive
        let targetPosition = player.position

        let newX = gameCamera.position.x + (targetPosition.x - gameCamera.position.x) * lerpFactor
        let newY = gameCamera.position.y + (targetPosition.y - gameCamera.position.y) * lerpFactor

        // Get viewport size to calculate camera boundaries
        guard let view = view else { return }
        let viewportWidth = view.bounds.width
        let viewportHeight = view.bounds.height

        // Clamp camera position so it doesn't show area outside the world
        let halfViewportWidth = viewportWidth / 2
        let halfViewportHeight = viewportHeight / 2

        let clampedX = max(halfViewportWidth, min(worldWidth - halfViewportWidth, newX))
        let clampedY = max(halfViewportHeight, min(worldHeight - halfViewportHeight, newY))

        gameCamera.position = CGPoint(x: clampedX, y: clampedY)
    }
}
