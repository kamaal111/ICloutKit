// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ICloutKit",
    platforms: [.iOS(.v10), .macOS(.v10_12)],
    products: [
        .library(
            name: "ICloutKit",
            targets: ["ICloutKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ICloutKit",
            dependencies: []),
        .testTarget(
            name: "ICloutKitTests",
            dependencies: ["ICloutKit"]),
    ]
)
