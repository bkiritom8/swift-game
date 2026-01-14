// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SQLDungeonCrawler",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "SQLDungeonCrawler",
            targets: ["SQLDungeonCrawler"]
        )
    ],
    targets: [
        .executableTarget(
            name: "SQLDungeonCrawler",
            path: "Sources"
        )
    ]
)
