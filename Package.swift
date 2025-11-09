// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MobileDiceRoller",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MobileDiceRoller",
            targets: ["MobileDiceRoller"]
        )
    ],
    dependencies: [
        // SQLCipher for encrypted database
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1"),

        // Swift Testing (once available, for now using XCTest)
        // Note: Swift Testing is built into Xcode 15+
    ],
    targets: [
        // Main app target
        .target(
            name: "MobileDiceRoller",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources/MobileDiceRoller"
        ),

        // Test target
        .testTarget(
            name: "MobileDiceRollerTests",
            dependencies: ["MobileDiceRoller"],
            path: "Tests/MobileDiceRollerTests"
        )
    ]
)
