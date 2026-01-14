// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DatabaseDungeon",
    platforms: [
        // Requires iOS 15.0+ for ARKit and RealityKit features
        .iOS(.v15)
    ],
    products: [
        .iOSApplication(
            name: "DatabaseDungeon",
            targets: ["AppModule"],
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .tower),
            accentColor: .presetColor(.purple),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft
            ],
            capabilities: [
                // Request camera permission for AR
                .camera(purposeString: "AR dungeon experience requires camera access to place the dungeon in your real world environment.")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "App"
        )
    ]
)
