// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "APIClient",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "APIClient",
            targets: ["APIClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        // C helpers
        .target(name: "CURLParser"),
        .target(
            name: "APIClient",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .target(name: "CURLParser"),
            ]
        ),
        .testTarget(
            name: "APIClientTests",
            dependencies: ["APIClient"]
        ),
    ]
)
