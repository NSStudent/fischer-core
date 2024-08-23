// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "FischerCore",
    products: [
        .library(
            name: "FischerCore",
            targets: ["FischerCore"]),
    ],
    targets: [
        .target(
            name: "FischerCore"),
        .testTarget(
            name: "FischerCoreTests",
            dependencies: ["FischerCore"]),
    ]
)
