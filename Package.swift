// swift-tools-version:5.5

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
            path: "Framework/Sources",
            resources: [.process("Resources")]
        )
    ]
)
