// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "ValhallaModels",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "ValhallaModels",
            targets: ["ValhallaModels"]
        ),
        .library(
            name: "ValhallaConfigModels",
            targets: ["ValhallaConfigModels"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Flight-School/AnyCodable", .upToNextMajor(from: "0.6.1")),
    ],
    targets: [
        .target(
            name: "ValhallaConfigModels",
            dependencies: ["AnyCodable"]
        ),
        .target(
            name: "ValhallaModels",
            dependencies: ["AnyCodable"]
        ),

        .testTarget(
            name: "Tests",
            dependencies: ["ValhallaModels", "ValhallaConfigModels"],
            resources: [.process("Resources")])
    ]
)
