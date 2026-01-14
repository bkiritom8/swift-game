import SpriteKit

/// The player character in the dungeon crawler
/// Represents the player-controlled hero who will learn SQL through dungeon exploration
class Player: SKSpriteNode {

    // MARK: - Properties

    /// Movement speed in points per second
    private let moveSpeed: CGFloat = 300

    /// Player size (both width and height)
    private let playerSize: CGFloat = 40

    /// Visual indicator showing where the player will move
    private var targetIndicator: SKShapeNode?

    // MARK: - Initialization

    /// Create a new player at the specified position
    /// - Parameter position: Starting position in the scene
    init(position: CGPoint) {
        // Create a simple colored circle for the player
        // Color: Heroic blue (you can change this later to a sprite)
        let playerColor = SKColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0)

        // Initialize as a colored square (we'll make it circular visually)
        super.init(texture: nil, color: playerColor, size: CGSize(width: playerSize, height: playerSize))

        // Make the player circular instead of square
        // This is done by creating a circular physics body and visual appearance
        self.position = position
        self.zPosition = 10 // Above background

        // Make it visually circular by using a texture
        setupAppearance()

        // Optional: Add a subtle glow effect for visibility
        addGlowEffect()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Appearance

    /// Set up the player's visual appearance
    private func setupAppearance() {
        // Create a circular shape for the player
        let circle = SKShapeNode(circleOfRadius: playerSize / 2)
        circle.fillColor = SKColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 1.0)
        circle.strokeColor = SKColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 1.0)
        circle.lineWidth = 3
        circle.zPosition = 1
        addChild(circle)

        // Add a simple "face" or direction indicator
        let directionDot = SKShapeNode(circleOfRadius: 5)
        directionDot.fillColor = .white
        directionDot.position = CGPoint(x: 0, y: playerSize / 4)
        directionDot.zPosition = 2
        circle.addChild(directionDot)
    }

    /// Add a subtle glow effect to make the player stand out
    private func addGlowEffect() {
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 5])

        // Create glow sprite
        let glowSprite = SKShapeNode(circleOfRadius: playerSize / 2)
        glowSprite.fillColor = SKColor(red: 0.2, green: 0.5, blue: 1.0, alpha: 0.3)
        glowSprite.strokeColor = .clear

        glow.addChild(glowSprite)
        glow.zPosition = -1
        addChild(glow)
    }

    // MARK: - Movement

    /// Move the player smoothly to a target position
    /// - Parameter target: The destination point
    func move(to target: CGPoint) {
        // Remove any existing move actions
        removeAction(forKey: "moving")

        // Calculate the distance to the target
        let dx = target.x - position.x
        let dy = target.y - position.y
        let distance = sqrt(dx * dx + dy * dy)

        // Calculate how long the movement should take based on distance and speed
        let duration = TimeInterval(distance / moveSpeed)

        // Create a smooth movement action
        let moveAction = SKAction.move(to: target, duration: duration)
        moveAction.timingMode = .easeInEaseOut // Smooth acceleration and deceleration

        // Run the movement
        run(moveAction, withKey: "moving")

        // Show a visual indicator at the target location
        showTargetIndicator(at: target)

        // Add a subtle rotation animation while moving to show activity
        addMovementAnimation(duration: duration)
    }

    /// Show a visual indicator at the target location
    /// This helps the player see where they clicked
    private func showTargetIndicator(at location: CGPoint) {
        // Remove existing indicator if any
        targetIndicator?.removeFromParent()

        // Create a ring at the target location
        guard let parent = self.parent else { return }

        let ring = SKShapeNode(circleOfRadius: 20)
        ring.strokeColor = SKColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 0.8)
        ring.lineWidth = 3
        ring.fillColor = .clear
        ring.position = location
        ring.zPosition = 5

        parent.addChild(ring)
        targetIndicator = ring

        // Animate the ring: fade out and expand
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.5)
        let group = SKAction.group([fadeOut, scaleUp])

        ring.run(SKAction.sequence([group, SKAction.removeFromParent()]))
    }

    /// Add a subtle animation while the player is moving
    /// Makes the movement feel more alive
    private func addMovementAnimation(duration: TimeInterval) {
        // Subtle pulse effect while moving
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let pulse = SKAction.sequence([scaleUp, scaleDown])

        // Repeat the pulse for the duration of movement
        let repeatCount = Int(duration / 0.6) + 1
        let repeatPulse = SKAction.repeat(pulse, count: repeatCount)

        run(repeatPulse, withKey: "movementAnimation")
    }

    // MARK: - Future Enhancements

    // Future methods you might add:
    // - func attack() -> for combat
    // - func interact(with object: GameObject) -> for SQL query interactions
    // - func takeDamage(_ amount: Int) -> for health system
    // - var inventory: [Item] -> for item collection
}
