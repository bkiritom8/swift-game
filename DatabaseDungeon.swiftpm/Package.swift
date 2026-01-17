// swift-tools-version: 5.6

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "DatabaseDungeon",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .iOSApplication(
            name: "DatabaseDungeon",
            targets: ["AppModule"],
            displayVersion: "1.0",
            bundleVersion: "1",
            accentColor: .presetColor(.purple),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft
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
