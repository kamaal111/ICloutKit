// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ICloutKit",
    platforms: [.iOS(.v12), .macOS(.v10_13)],
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
