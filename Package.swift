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
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
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
