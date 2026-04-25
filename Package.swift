// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "FischerCore",
    platforms: [
        .iOS(.v13),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FischerCore",
            targets: ["FischerCore"]),
        .executable(
            name: "fischer-cli",
            targets: ["fischer-cli"])
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/Noora", .upToNextMajor(from: "0.15.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-parsing", from: "0.14.1")
    ],
    targets: [
        .target(
            name: "FischerCore",
            dependencies: [
                .product(name: "Parsing", package: "swift-parsing")
            ]
        ),
        .executableTarget(
            name: "fischer-cli",
            dependencies: [
                "FischerCore",
                .product(name: "Noora", package: "Noora")
            ]
        ),
        .testTarget(
            name: "FischerCoreTests",
            dependencies: [
                "FischerCore",
                .product(name: "Parsing", package: "swift-parsing")
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
