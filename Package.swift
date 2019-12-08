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
        .package(path: "../LoggerKit"),
        .package(path: "../CommandLineKit"),
        .package(path: "../FoundationKit")
    ],
    targets: [
        .target(
            name: "CodeSignTool",
            dependencies: ["CodeSignKit", "LoggerKit", "FoundationKit", "CommandLineKit"],
            path: "CodeSignTool"
        ),
        .target(
            name: "CodeSignKit",
            dependencies: ["FoundationKit"],
            path: "CodeSignKit"
        )
    ]
)
