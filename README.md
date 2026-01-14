# Database Dungeon 🏰

An immersive AR dungeon crawler that teaches SQL concepts through gameplay. Built for the **Swift Student Challenge 2026**.

## 🎯 Project Overview

**Database Dungeon** transforms SQL learning into an engaging AR adventure. Players explore a dungeon that appears in their real-world environment, learning fundamental SQL concepts through interactive gameplay.

- **Target**: Swift Playgrounds 4.6+
- **Platform**: iPhone/iPad with ARKit support (iOS 15.0+)
- **Experience**: 3-minute AR dungeon crawler
- **Theme**: Dark, serious dungeon aesthetic
- **Size**: Under 25MB, fully offline

---

## 📱 How to Test on iPhone/iPad

### Step 1: Transfer the Project

You have several options to get the project onto your iPhone/iPad:

**Option A: AirDrop** (Easiest)
1. On your Mac, right-click the `DatabaseDungeon.swiftpm` folder
2. Click Share → AirDrop
3. Select your iPhone/iPad
4. Accept the file on your device

**Option B: iCloud Drive**
1. Copy the `DatabaseDungeon.swiftpm` folder to iCloud Drive
2. On your iPhone/iPad, open Files app
3. Navigate to iCloud Drive
4. Find the folder

**Option C: Git Clone** (if using Working Copy app)
1. Install Working Copy app on your iPhone/iPad
2. Clone this repository
3. The folder will be accessible to Swift Playgrounds

### Step 2: Open in Swift Playgrounds

1. **Open Swift Playgrounds** app on your iPhone/iPad (version 4.6+)
2. Tap **"Open"** or the folder icon
3. Navigate to where you saved `DatabaseDungeon.swiftpm`
4. Tap to open the project

### Step 3: Run the AR Experience

1. Tap the **▶️ Run My Code** button (top right)
2. **Grant camera permission** when prompted
3. Point your camera at a **floor or table surface**
4. Move slowly to help ARKit detect the plane
5. When you see the **purple indicator**, tap to **place the dungeon**
6. **Tap on the ground** inside the dungeon to **move your character**

---

## 🎮 AR Experience Guide

### What You'll See

- **Purple Placement Indicator**: Shows where the dungeon will appear
- **Dungeon Room**: A dark 1m × 1m room with walls, floor, and ceiling
- **Player Character**: A glowing cyan sphere (represents you)
- **Coaching Messages**: Instructions at the top of the screen

### Controls

- **Before Placement**: Tap the purple indicator to place the dungeon
- **After Placement**: Tap anywhere on the ground to move your character

### Tips for Best Results

✅ **Good Lighting**: ARKit needs light to detect surfaces
✅ **Textured Surfaces**: Works better than plain white floors/tables
✅ **Clear Space**: At least 2m × 2m area
✅ **Slow Movement**: Move device slowly when scanning
✅ **Keep in View**: Keep camera pointed at dungeon during gameplay

---

## 💻 Testing on Mac (Demo Mode)

If you open the project on a Mac or non-AR device:

1. Open `DatabaseDungeon.swiftpm` in Swift Playgrounds or Xcode
2. Run the project
3. You'll see a **Demo View** with:
   - Project overview and features
   - Step-by-step AR instructions
   - Device requirements
   - Placeholder for screenshots (add your own later!)

This demo mode is perfect for Swift Student Challenge reviewers who are evaluating on Mac.

---

## 📁 Project Structure

```
DatabaseDungeon.swiftpm/
├── Package.swift              # Project manifest with AR capabilities
├── App/
│   ├── MyApp.swift           # Main entry point with device detection
│   ├── ARDungeonView.swift   # AR experience view (iPhone/iPad)
│   ├── DemoView.swift        # Demo mode (Mac/non-AR devices)
│   └── DungeonScene.swift    # 3D scene with dungeon and player
└── Resources/                # Assets (add screenshots here)
```

---

## 🏗️ Architecture & Key Concepts

### ARKit Concepts (Explained for Beginners)

**1. Device Detection**
```swift
ARWorldTrackingConfiguration.isSupported
```
Checks if device has the sensors needed for AR (requires A9+ processor)

**2. Plane Detection**
```swift
configuration.planeDetection = [.horizontal]
```
ARKit analyzes the camera feed to find flat surfaces (floors, tables)

**3. Raycasting**
```swift
arView.raycast(from: point, allowing: .estimatedPlane, alignment: .horizontal)
```
Shoots a virtual ray from screen coordinates into the 3D world to find positions

**4. Anchors**
```swift
AnchorEntity(world: transform)
```
Pins virtual content to specific real-world positions

### RealityKit Scene Graph

```
ARView.scene
└── AnchorEntity (at placement location)
    ├── Floor (gray, 2cm thick)
    ├── North Wall (dark brown)
    ├── South Wall
    ├── East Wall
    ├── West Wall
    ├── Ceiling (dark gray)
    ├── Player (cyan sphere, 10cm diameter)
    └── PointLight (purple-tinted, dim)
```

### Code Files Breakdown

**MyApp.swift** (~45 lines)
- App entry point with `@main`
- Device capability detection
- Routes to AR or Demo view

**ARDungeonView.swift** (~260 lines)
- SwiftUI view wrapping ARView
- `UIViewRepresentable` bridge pattern
- Coordinator for AR session management
- Tap gesture handling
- Placement indicator logic

**DungeonScene.swift** (~270 lines)
- `ObservableObject` for 3D content
- Creates dungeon geometry
- Player spawning and movement
- Atmospheric lighting

**DemoView.swift** (~305 lines)
- SwiftUI information screen
- Tabbed interface
- Feature descriptions
- Requirements checklist

---

## ✅ Current Features

### AR Mode (iPhone/iPad) ✓
- ✅ Horizontal plane detection
- ✅ Visual placement indicator
- ✅ Dark dungeon room (1m × 1m × 0.5m)
- ✅ Player character (cyan sphere)
- ✅ Tap-to-move with smooth animation
- ✅ Boundary detection (walls)
- ✅ Atmospheric lighting
- ✅ Coaching UI

### Demo Mode (Mac) ✓
- ✅ Welcome screen
- ✅ Tabbed interface
- ✅ Feature descriptions
- ✅ Step-by-step guide
- ✅ Device requirements
- ✅ Screenshot placeholders

---

## 🚀 Next Steps: Adding SQL Gameplay

The AR foundation is complete! Here's how to add SQL learning features:

### Phase 1: SQL Puzzle System
1. Create `SQLPuzzle.swift` model
2. Add treasure chest entities (represent database tables)
3. Create query input UI overlay
4. Design 3-5 progressive SQL challenges:
   - **Level 1**: `SELECT * FROM items`
   - **Level 2**: `SELECT name FROM items WHERE rarity = 'rare'`
   - **Level 3**: `SELECT ... JOIN ...`

### Phase 2: Multiple Rooms
1. Expand to 2-3 connected dungeon rooms
2. Add door entities that unlock with correct SQL
3. Implement room transitions

### Phase 3: Polish
1. Replace sphere player with character model
2. Add textures to walls
3. Particle effects for success/failure
4. Sound effects and ambient audio
5. Record AR gameplay video for demo mode

### Phase 4: Educational Content
1. SQL hint system
2. In-game SQL reference guide
3. Progress tracking
4. Victory screen with learning summary

---

## 🎨 Design Decisions

### Dungeon Dimensions
- **1m × 1m × 0.5m**: Perfect for table-top viewing
- **Real-world scale**: Makes AR feel grounded and realistic
- **5cm walls**: Thick enough to see, thin enough to not obstruct

### Why Simple Geometry?
- **Performance**: Maintains 60fps for smooth AR
- **File Size**: Primitives are tiny (~KB vs models ~MB)
- **Rapid Iteration**: Easy to modify dimensions and materials
- **Foundation First**: Replace with models once gameplay is solid

### Color Choices
- **Gray floor (0.8 alpha)**: Stone dungeon aesthetic
- **Dark brown walls (RGB: 0.3, 0.25, 0.2)**: Earthy dungeon stone
- **Cyan player**: High contrast, easy to see
- **Dim lighting (800 intensity)**: Moody atmosphere

---

## 🐛 Troubleshooting

### "Camera Permission Denied"
**Solution**: Settings → Privacy & Security → Camera → Swift Playgrounds → Enable

### "No Surface Detected"
**Causes**:
- Poor lighting (ARKit needs light)
- Plain surfaces (try textured floors/tables)
- Moving too fast (slow scanning motion)

**Solutions**:
- Use in well-lit environment
- Point at textured surfaces
- Move device slowly

### "Dungeon Appears Too Small/Large"
**This is expected!** The dungeon uses real-world scale:
- 1m = 3.3 feet (about arm's length)
- Perfect for desk/table placement

To adjust: Edit `DungeonScene.swift` lines 30-33:
```swift
private let dungeonWidth: Float = 1.0
private let dungeonDepth: Float = 1.0
private let dungeonHeight: Float = 0.5
```

### "Player Won't Move"
**Checklist**:
1. Have you placed the dungeon? (tap the purple indicator first)
2. Are you tapping inside the dungeon bounds?
3. Is the coaching message updated to "Tap on the ground to move"?

### "Build Errors in Swift Playgrounds"
**Check**:
- Swift Playgrounds version 4.6+
- iOS 15.0+ on device
- All files are in correct locations

---

## 📚 Learning Resources

### For AR Beginners
- [Apple ARKit Documentation](https://developer.apple.com/augmented-reality/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [ARKit by Tutorials Book](https://www.kodeco.com/books/arkit-by-tutorials)

### For Swift Playgrounds
- [Swift Playgrounds User Guide](https://www.apple.com/swift/playgrounds/)
- [App Development Tutorials](https://developer.apple.com/tutorials/app-dev-training)

### Code Comments
Every file includes extensive beginner-friendly comments explaining:
- **What** the code does
- **Why** this approach was chosen
- **How** ARKit/RealityKit concepts work
- **Definitions** of technical terms

---

## 📊 Project Stats

- **Total Code**: ~880 lines (excluding comments)
- **Total with Comments**: ~1,100 lines
- **Estimated Size**: <1MB (plenty of room for SQL content!)
- **Target**: Under 25MB ✓
- **iOS Requirement**: 15.0+ ✓
- **Offline**: 100% ✓

---

## 📱 Device Compatibility

### Full AR Experience
- iPhone 6s or newer
- iPad (5th generation) or newer
- iPad Pro (all models)
- iPad Air (3rd generation) or newer
- iPad mini (5th generation) or newer
- **Requires iOS 15.0+**

### Enhanced AR (with LiDAR)
Faster plane detection and better tracking:
- iPhone 12 Pro / Pro Max or newer Pro models
- iPad Pro (2020 and newer)

### Demo Mode Only
- Mac (with Swift Playgrounds or Xcode)
- Older iOS devices without ARKit

---

## 🎯 Swift Student Challenge Readiness

### ✅ Completed
- Unique, creative AR experience
- Educational focus (SQL learning)
- Well-structured code
- Extensive beginner-friendly comments
- Device compatibility (AR + Demo modes)
- Under 25MB size requirement
- Fully offline
- 3-minute experience framework

### 🚧 To Add
- SQL puzzle gameplay mechanics
- Educational content integration
- AR gameplay video for demo mode
- Polish and sound effects

---

## 💡 Tips for Development

### Testing Workflow
1. **Make changes** in Swift Playgrounds on Mac
2. **Save** (automatically syncs via iCloud if enabled)
3. **Open on iPhone** and run immediately
4. **Iterate quickly** with this workflow

### Adding Screenshots to Demo Mode
1. Run the AR experience on iPhone
2. Take screenshots (Volume Up + Side Button)
3. Add to `DatabaseDungeon.swiftpm/Resources/`
4. Update `DemoView.swift` to display them

### Performance Tips
- Keep geometries simple (primitives preferred)
- Limit entities (<50 for good performance)
- Use collision detection sparingly
- Test on real devices (Simulator doesn't support AR)

---

## 🏆 What Makes This Special

1. **Dual Experience**: Works on both AR devices and Mac
2. **Educational**: Teaches real SQL concepts
3. **Well-Documented**: Perfect for beginners to learn AR
4. **Foundation First**: Solid AR base to build SQL gameplay on
5. **Challenge-Ready**: Meets all Swift Student Challenge requirements

---

## 📝 Final Notes

This project provides a **solid AR foundation** for your SQL learning game. The hardest parts (plane detection, AR session management, user interaction) are complete and working.

**Your next session should focus on**: Adding the SQL puzzle system and educational content. The AR framework is ready!

---

**Questions?** Check the extensive code comments in each file. Every concept is explained for AR beginners.

**Ready to test?** Follow the iPhone/iPad testing instructions above and see your dungeon come to life! 🎮✨
