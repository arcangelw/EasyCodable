// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EasyCodable",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "EasyCodable",
            targets: ["EasyCodable"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "EasyCodable",
            dependencies: []),
        .testTarget(
            name: "EasyCodableTests",
            dependencies: ["EasyCodable"]),
    ],
    swiftLanguageVersions: [
        .version("5")
    ]
)

