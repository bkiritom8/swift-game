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

    /// Dungeon room boundaries (inset from screen edges)
    private let roomMargin: CGFloat = 40

    /// Minimum and maximum positions the player can move to
    private var minX: CGFloat = 0
    private var maxX: CGFloat = 0
    private var minY: CGFloat = 0
    private var maxY: CGFloat = 0

    // MARK: - Scene Lifecycle

    /// Called when the scene is first created
    override func didMove(to view: SKView) {
        setupScene()
        setupDungeonBackground()
        setupPlayer()
        calculateBoundaries()
    }

    // MARK: - Setup Methods

    /// Configure the scene properties
    private func setupScene() {
        // Dark background for dungeon atmosphere
        backgroundColor = SKColor(red: 0.15, green: 0.12, blue: 0.12, alpha: 1.0)

        // Use the view's size for the scene
        // This ensures proper sizing on both iPhone and Mac
        if let view = view {
            size = view.bounds.size
        }
    }

    /// Create the dungeon room background
    /// Uses a grid of stone tiles for that classic dungeon feel
    private func setupDungeonBackground() {
        // Stone floor color (dark gray with slight brown tint)
        let stoneColor = SKColor(red: 0.25, green: 0.23, blue: 0.21, alpha: 1.0)
        let darkerStone = SKColor(red: 0.20, green: 0.18, blue: 0.16, alpha: 1.0)

        // Create a tile-based floor pattern
        let tileSize: CGFloat = 64
        let cols = Int(size.width / tileSize) + 2
        let rows = Int(size.height / tileSize) + 2

        // Create alternating stone tiles for visual interest
        for row in 0..<rows {
            for col in 0..<cols {
                let tile = SKSpriteNode(color: (row + col) % 2 == 0 ? stoneColor : darkerStone,
                                       size: CGSize(width: tileSize, height: tileSize))
                tile.position = CGPoint(x: CGFloat(col) * tileSize, y: CGFloat(row) * tileSize)
                tile.anchorPoint = CGPoint(x: 0, y: 0)
                tile.zPosition = -10 // Behind everything else
                addChild(tile)
            }
        }

        // Add room walls (dark borders)
        createWalls()
    }

    /// Create visible walls around the dungeon room
    private func createWalls() {
        let wallColor = SKColor(red: 0.1, green: 0.08, blue: 0.08, alpha: 1.0)
        let wallThickness: CGFloat = roomMargin

        // Top wall
        let topWall = SKSpriteNode(color: wallColor,
                                   size: CGSize(width: size.width, height: wallThickness))
        topWall.position = CGPoint(x: size.width / 2, y: size.height - wallThickness / 2)
        topWall.zPosition = -5
        addChild(topWall)

        // Bottom wall
        let bottomWall = SKSpriteNode(color: wallColor,
                                      size: CGSize(width: size.width, height: wallThickness))
        bottomWall.position = CGPoint(x: size.width / 2, y: wallThickness / 2)
        bottomWall.zPosition = -5
        addChild(bottomWall)

        // Left wall
        let leftWall = SKSpriteNode(color: wallColor,
                                    size: CGSize(width: wallThickness, height: size.height))
        leftWall.position = CGPoint(x: wallThickness / 2, y: size.height / 2)
        leftWall.zPosition = -5
        addChild(leftWall)

        // Right wall
        let rightWall = SKSpriteNode(color: wallColor,
                                     size: CGSize(width: wallThickness, height: size.height))
        rightWall.position = CGPoint(x: size.width - wallThickness / 2, y: size.height / 2)
        rightWall.zPosition = -5
        addChild(rightWall)
    }

    /// Create and position the player character
    private func setupPlayer() {
        // Create player at the center of the room
        let startPosition = CGPoint(x: size.width / 2, y: size.height / 2)
        player = Player(position: startPosition)
        addChild(player)
    }

    /// Calculate the boundaries where the player can move
    /// This prevents the player from walking into walls or off-screen
    private func calculateBoundaries() {
        let playerRadius = player.size.width / 2

        minX = roomMargin + playerRadius
        maxX = size.width - roomMargin - playerRadius
        minY = roomMargin + playerRadius
        maxY = size.height - roomMargin - playerRadius
    }

    // MARK: - Input Handling (iOS - Touch)

    /// Handle touch input on iPhone/iPad
    /// When the player taps, the character moves to that location
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        handleInput(at: location)
    }

    #if os(macOS)
    // MARK: - Input Handling (macOS - Mouse)

    /// Handle mouse click on Mac
    /// When the player clicks, the character moves to that location
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        handleInput(at: location)
    }
    #endif

    // MARK: - Movement Logic

    /// Process input from either touch or mouse
    /// Moves the player to the target location while respecting boundaries
    private func handleInput(at location: CGPoint) {
        // Clamp the target position to stay within boundaries
        let targetX = max(minX, min(maxX, location.x))
        let targetY = max(minY, min(maxY, location.y))
        let clampedLocation = CGPoint(x: targetX, y: targetY)

        // Tell the player to move to this location
        player.move(to: clampedLocation)
    }

    // MARK: - Update Loop

    /// Called every frame (60 times per second)
    /// Use this for continuous game logic updates
    override func update(_ currentTime: TimeInterval) {
        // Future: Update game state, check for collisions, etc.
    }
}
