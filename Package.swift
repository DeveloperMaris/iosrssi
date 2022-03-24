// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSRSSI",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "iOSRSSI", targets: ["iOSRSSI"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/dehesa/CodableCSV", from: "0.0.1")
    ],
    targets: [
        .executableTarget(
            name: "iOSRSSI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "CodableCSV", package: "CodableCSV")
            ]),
        .testTarget(
            name: "iOSRSSITests",
            dependencies: ["iOSRSSI"])
    ]
)
