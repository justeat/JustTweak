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
       .executable(name: "TweakAccessorGenerator", targets: ["TweakAccessorGenerator"])
    ],
    dependencies: [.package(url: "https://github.com/apple/swift-argument-parser", from: "1.1.2")],
    targets: [
        .target(
            name: "JustTweak",
            path: "Framework/Sources",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "JustTweak_Tests",
            dependencies: ["JustTweak"],
            path: "Tests/Sources",
            resources: [.process("Resources")]
        ),
        .executableTarget(
            name: "TweakAccessorGenerator",
            dependencies: [.product(name: "ArgumentParser", package: "swift-argument-parser")],
            path: "TweakAccessorGenerator/Sources",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "TweakAccessorGenerator_Tests",
            dependencies: ["TweakAccessorGenerator"],
            path: "TweakAccessorGenerator/Tests/Sources",
            resources: [.process("Resources")]
        )
    ]
)
