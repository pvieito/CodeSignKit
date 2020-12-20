// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "CodeSignKit",
    platforms: [
        .macOS(.v10_13)
    ],
    products: [
        .executable(
            name: "CodeSignTool",
            targets: ["CodeSignTool"]
        ),
        .library(
            name: "CodeSignKit",
            targets: ["CodeSignKit"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pvieito/FoundationKit.git", .branch("master")),
        .package(url: "https://github.com/pvieito/LoggerKit.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "CodeSignTool",
            dependencies: ["CodeSignKit", "LoggerKit", "FoundationKit", .product(name: "ArgumentParser", package: "swift-argument-parser")],
            path: "CodeSignTool"
        ),
        .target(
            name: "CodeSignKit",
            dependencies: ["FoundationKit", "LoggerKit"],
            path: "CodeSignKit"
        )
    ]
)
