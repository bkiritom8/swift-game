import SwiftUI

/**
 DemoView - Preview mode for devices without ARKit support

 This view is displayed on Mac or older iOS devices that don't support ARKit.
 It provides:
 - Information about the AR experience
 - Visual previews (screenshots/videos can be added later)
 - Explanation of gameplay mechanics
 - Requirements for running the full AR experience

 This is important for the Swift Student Challenge submission since reviewers
 on Mac can understand your app without needing an AR device.
 */

struct DemoView: View {
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 12) {
                        Image(systemName: "arkit")
                            .font(.system(size: 80))
                            .foregroundColor(.purple)

                        Text("Database Dungeon")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Learn SQL Through AR Adventure")
                            .font(.title3)
                            .foregroundColor(.secondary)

                        // AR requirement notice
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text("AR Experience requires iPhone or iPad with ARKit")
                                .font(.footnote)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.orange.opacity(0.15))
                        )
                    }
                    .padding(.top, 32)

                    Divider()

                    // Tabbed content
                    Picker("Content", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("How It Works").tag(1)
                        Text("Requirements").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    // Tab content
                    Group {
                        if selectedTab == 0 {
                            overviewSection
                        } else if selectedTab == 1 {
                            howItWorksSection
                        } else {
                            requirementsSection
                        }
                    }
                    .animation(.easeInOut, value: selectedTab)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Overview Section

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "About the Experience", icon: "book.fill")

            Text("""
            Database Dungeon is an immersive AR experience that teaches SQL database \
            concepts through interactive dungeon exploration.

            Walk through a real-world dungeon that appears on your floor or table, \
            solve SQL puzzles, and learn database fundamentals in a fun, engaging way.
            """)
            .font(.body)

            // Preview placeholder
            VStack(spacing: 12) {
                Text("AR Experience Preview")
                    .font(.headline)

                // Placeholder for screenshot - you can replace this with actual images
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 200)

                    VStack(spacing: 8) {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.white.opacity(0.6))
                        Text("Preview Screenshot")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("(Add actual AR screenshot here)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.5), lineWidth: 2)
                )
            }

            // Key features
            SectionHeader(title: "Key Features", icon: "star.fill")

            FeatureRow(
                icon: "arkit",
                title: "Immersive AR",
                description: "Place a dungeon in your real world"
            )

            FeatureRow(
                icon: "figure.walk",
                title: "Interactive Movement",
                description: "Tap to move your character through the dungeon"
            )

            FeatureRow(
                icon: "cylinder.split.1x2",
                title: "Learn SQL",
                description: "Solve database puzzles to progress"
            )

            FeatureRow(
                icon: "gamecontroller.fill",
                title: "3-Minute Adventure",
                description: "Complete experience designed for quick sessions"
            )
        }
    }

    // MARK: - How It Works Section

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "How the AR Experience Works", icon: "info.circle.fill")

            // Step by step guide
            StepRow(
                number: 1,
                title: "Launch the App",
                description: "Open Database Dungeon on your iPhone or iPad"
            )

            StepRow(
                number: 2,
                title: "Find a Surface",
                description: "Point your camera at a floor or table. Move slowly for best results."
            )

            StepRow(
                number: 3,
                title: "Place the Dungeon",
                description: "When you see the purple indicator, tap to place your dungeon"
            )

            StepRow(
                number: 4,
                title: "Explore & Learn",
                description: "Tap the ground to move your character. Solve SQL puzzles as you explore!"
            )

            // Tips
            SectionHeader(title: "Tips for Best Experience", icon: "lightbulb.fill")

            TipRow(tip: "Use in a well-lit environment")
            TipRow(tip: "Ensure at least 2m × 2m of clear space")
            TipRow(tip: "Move your device slowly when scanning surfaces")
            TipRow(tip: "Keep your device pointed at the dungeon during gameplay")
        }
    }

    // MARK: - Requirements Section

    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(title: "Device Requirements", icon: "iphone")

            RequirementRow(
                met: false,
                title: "ARKit Support",
                description: "iPhone 6s / iPad (5th gen) or newer"
            )

            RequirementRow(
                met: true,
                title: "iOS Version",
                description: "iOS 15.0 or later"
            )

            RequirementRow(
                met: true,
                title: "Swift Playgrounds",
                description: "Swift Playgrounds 4.6 or later"
            )

            Divider()

            SectionHeader(title: "Supported Devices", icon: "checkmark.circle.fill")

            Text("""
            The full AR experience works on:
            • iPhone 6s and newer
            • iPad (5th generation) and newer
            • iPad Pro (all models)
            • iPad Air (3rd generation) and newer
            • iPad mini (5th generation) and newer

            Devices with LiDAR (iPhone 12 Pro and newer, iPad Pro 2020 and newer) \
            provide enhanced AR tracking.
            """)
            .font(.body)
            .foregroundColor(.secondary)

            Divider()

            // Alternative: Demo on Mac
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "desktopcomputer")
                        .foregroundColor(.blue)
                    Text("Viewing on Mac?")
                        .font(.headline)
                }

                Text("""
                This demo mode lets you understand the concept. To experience the full AR \
                dungeon, please run this playground on an iPhone or iPad with ARKit support.
                """)
                .font(.body)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.1))
            )
        }
    }
}

// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.purple)
            Text(title)
                .font(.headline)
        }
        .padding(.top, 8)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.purple)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct StepRow: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 32, height: 32)
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TipRow: View {
    let tip: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.caption)
            Text(tip)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct RequirementRow: View {
    let met: Bool
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: met ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(met ? .green : .orange)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    DemoView()
}
