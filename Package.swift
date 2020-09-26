// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JustTweak",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "JustTweak",
            targets: ["JustTweak"]),
    ],
    targets: [
        .target(
            name: "JustTweak",
            dependencies: []),
        .testTarget(
            name: "JustTweakTests",
            dependencies: ["JustTweak"]),
    ]
)
