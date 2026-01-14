# SQL Dungeon Crawler

A top-down dungeon crawler game that teaches SQL concepts through gameplay. Built for the Swift Student Challenge.

## 🎮 Current Features

- ✅ Player character with smooth movement
- ✅ Touch controls (iPhone/iPad) and click controls (Mac)
- ✅ Dungeon-themed background with stone tiles
- ✅ Room boundaries (walls)
- ✅ Visual feedback for movement targets
- ✅ Cross-platform support (iOS and macOS)

## 📱 Platform Support

- **Primary**: iPhone (iOS 16+)
- **Secondary**: Mac (macOS 13+)
- **Orientation**: Supports all orientations (portrait and landscape work well)

## ⚠️ Important: Pull Latest Changes

If you see errors about `.iOSApplication` not being recognized, pull the latest changes:

```bash
cd ~/Documents/swift-game  # or wherever your project is
git pull origin claude/sql-dungeon-game-3xQoF
```

Then close and reopen Xcode. The errors should be gone!

## 🚀 Setup Instructions

### Option 1: Xcode (Recommended for Development)

1. **Open the project in Xcode**
   ```bash
   cd swift-game
   open Package.swift
   ```
   This will open the project in Xcode.

2. **Select your target device**
   - For iPhone: Select "iPhone 15 Pro" (or any iPhone simulator) from the device dropdown
   - For Mac: Select "My Mac"

3. **Run the project**
   - Press `Cmd + R` or click the Play button
   - The game should launch in the simulator or on your Mac

### Option 2: Swift Playgrounds (For Final Submission)

1. **Compress the project**
   ```bash
   zip -r SQLDungeonCrawler.swiftpm.zip .
   ```

2. **Transfer to iPad/iPhone**
   - AirDrop the .zip file to your iOS device
   - Unzip and open with Swift Playgrounds app

3. **Run in Swift Playgrounds**
   - Tap "Run My Code" to start the game

## 📲 Testing on iPhone via Xcode

### Prerequisites
- Xcode 26 installed on your Mac
- iPhone connected via USB or on the same Wi-Fi network
- Developer mode enabled on iPhone (Settings > Privacy & Security > Developer Mode)

### Steps

1. **Connect your iPhone**
   - Plug in via USB or ensure Wi-Fi sync is enabled
   - Unlock your iPhone and trust the computer if prompted

2. **Select your iPhone in Xcode**
   - In Xcode, click the device dropdown (top left, next to the scheme)
   - Select your iPhone from the list

3. **Build and Run**
   - Press `Cmd + R`
   - Xcode will build and install the app on your iPhone
   - The app will launch automatically

4. **Test the controls**
   - Tap anywhere on the screen
   - The blue character should move smoothly to that location
   - Try tapping near the walls to see boundary enforcement

### Troubleshooting

**"Failed to install app"**
- Make sure Developer Mode is enabled on your iPhone
- Try cleaning the build folder: `Cmd + Shift + K`

**"Signing requires a development team"**
- In Xcode, go to the project settings
- Under "Signing & Capabilities", select your Apple ID team

**App crashes on launch**
- Check the Xcode console for error messages
- Ensure your iPhone is running iOS 16 or later

## 🎯 How to Play (Current Version)

1. Launch the game
2. You'll see a blue circular character in the center of a dungeon room
3. Tap/click anywhere on the screen
4. The character moves smoothly to that location
5. Try clicking near the edges - the character stays within the room boundaries

## 🏗️ Project Structure

```
swift-game/
├── Package.swift          # Swift Package definition
├── Sources/              # All Swift source files
│   ├── App.swift         # App entry point (SwiftUI)
│   ├── GameView.swift    # Bridge between SwiftUI and SpriteKit
│   ├── GameScene.swift   # Main game scene (dungeon room)
│   └── Player.swift      # Player character class
└── README.md            # This file
```

## 🎨 Design Choices

### Orientation Recommendation: **Landscape Primary, Portrait Supported**

**Why Landscape?**
- More horizontal space for dungeon exploration
- Better view of the room and future SQL query panels
- Traditional dungeon crawler feel

**Why Portrait Still Works?**
- Good for iPhone one-handed use
- Works well for vertical dungeon corridors
- The game auto-adapts to any orientation

**Current Implementation**: The app supports all orientations and will work great in both landscape and portrait. For the best experience during the 3-minute Swift Student Challenge demo, I recommend landscape mode.

### Visual Design
- **Dark theme**: Serious dungeon aesthetic (not cartoony)
- **Stone tiles**: Classic RPG dungeon feel
- **Blue player**: Heroic color that stands out against dark backgrounds
- **Smooth animations**: Professional, polished movement

## 📝 Code Architecture

### Key Design Patterns

1. **MVC-inspired structure**
   - `Player.swift` = Model (player data and logic)
   - `GameScene.swift` = Controller (game logic)
   - `GameView.swift` = View (SwiftUI presentation)

2. **Cross-platform input handling**
   - `touchesBegan` for iOS
   - `mouseDown` for macOS
   - Unified `handleInput` method

3. **Action-based movement**
   - Uses SpriteKit's `SKAction` for smooth animations
   - Easing functions for natural movement
   - Visual feedback with target indicators

## 🔮 Next Steps

Here's what I recommend building next, in priority order:

### Phase 1: Core Gameplay (Next 2-3 steps)
1. **Add enemies/obstacles**
   - Create simple enemy sprites
   - Add collision detection
   - Implement basic health system

2. **Add SQL interaction points**
   - Create "query terminals" in the dungeon
   - Add SwiftUI overlay for SQL input
   - Implement simple SELECT queries

3. **Add rooms/levels**
   - Create multiple dungeon rooms
   - Add doors/transitions between rooms
   - Each room teaches a different SQL concept

### Phase 2: SQL Integration (4-5 steps)
4. **Implement SQLite database**
   - Create a local database with game data
   - Add tables for items, enemies, quests
   - Players query the database to progress

5. **Add query validation**
   - Check if SQL queries are correct
   - Provide helpful error messages
   - Reward correct queries with game progress

6. **Create tutorial system**
   - Intro room that teaches basic SELECT
   - Progressive difficulty (WHERE, JOIN, etc.)
   - Visual feedback for query results

### Phase 3: Polish (Final steps)
7. **Improve visuals**
   - Replace colored shapes with sprites
   - Add particle effects (torches, magic)
   - Enhance UI with dungeon-themed elements

8. **Add sound effects**
   - Footsteps, sword swings
   - Background music (dark, mysterious)
   - Query success/failure sounds

9. **Optimize for 3-minute experience**
   - Create a compelling opening
   - Ensure players understand SQL concept quickly
   - Add a satisfying conclusion/victory state

### Immediate Next Action

I recommend starting with **Step 1: Add enemies/obstacles**. This will make the game feel more like a real dungeon crawler and set up the foundation for the SQL learning mechanics.

Would you like me to implement any of these next steps?

## 🛠️ Development Tips

### For Python Developers (like you!)

**Swift vs Python syntax quick reference:**

```swift
// Variables
let constant = 10        // Python: constant = 10 (but not enforced)
var variable = 20        // Python: variable = 20

// Optionals (no None in Swift, use optionals)
var maybeValue: String?  // Python: maybe_value = None
if let value = maybeValue { }  // Python: if maybe_value is not None:

// Functions
func greet(name: String) -> String {  // Python: def greet(name: str) -> str:
    return "Hello, \(name)"           //     return f"Hello, {name}"
}

// Classes
class Player: SKSpriteNode {  // Python: class Player(SKSpriteNode):
    private var health = 100  //     self.health = 100
}
```

### Debugging in Xcode

- **Print statements**: Use `print("Debug: \(variable)")`
- **Breakpoints**: Click left margin in code editor
- **View Hierarchy**: Debug menu > View Debugging > Capture View Hierarchy

## 📦 Creating Final Submission

When you're ready to submit to Swift Student Challenge:

1. **Clean the project**
   ```bash
   # Remove build artifacts
   rm -rf .build
   ```

2. **Test in Swift Playgrounds**
   - Essential: Test on an actual iPad/iPhone with Swift Playgrounds
   - Ensure it runs smoothly and loads in under 3 seconds

3. **Create submission ZIP**
   ```bash
   # From the parent directory of swift-game
   zip -r SQLDungeonCrawler.swiftpm.zip swift-game -x "*.git*" -x ".build/*"
   ```

4. **Verify ZIP contents**
   - Unzip and test the .swiftpm folder
   - Make sure it opens in Swift Playgrounds

## 📚 Resources

- [SpriteKit Documentation](https://developer.apple.com/documentation/spritekit)
- [Swift Playgrounds](https://developer.apple.com/swift-playgrounds/)
- [Swift Student Challenge](https://developer.apple.com/wwdc24/swift-student-challenge/)
- [SQL Tutorial](https://www.w3schools.com/sql/) - for reference when building SQL puzzles

## 🎓 Learning Notes

This project teaches:
- **Swift basics**: Variables, classes, functions
- **SpriteKit**: Game development framework
- **SwiftUI**: Modern Apple UI framework
- **Cross-platform development**: iOS and macOS
- **Game architecture**: Scene management, input handling
- **SQL**: Through gameplay mechanics (coming soon!)

---

Built with ❤️ for Swift Student Challenge 2026
