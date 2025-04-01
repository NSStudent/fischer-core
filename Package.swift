// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "FischerCore",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "FischerCore",
            targets: ["FischerCore"])
    ],
    dependencies: [
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
        .testTarget(
            name: "FischerCoreTests",
            dependencies: [
                "FischerCore",
                .product(name: "Parsing", package: "swift-parsing")
            ]),
    ]
)
