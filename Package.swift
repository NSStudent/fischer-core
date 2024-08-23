// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "FischerCore",
    products: [
        .library(
            name: "FischerCore",
            targets: ["FischerCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FischerCore"),
        .testTarget(
            name: "FischerCoreTests",
            dependencies: ["FischerCore"]),
    ]
)
