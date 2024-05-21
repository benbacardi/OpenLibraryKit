// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenLibraryKit",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OpenLibraryKit",
            targets: ["OpenLibraryKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/koshakji/APIClient", from: "0.0.8"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OpenLibraryKit", dependencies: [.product(name: "APIClient", package: "APIClient")]),
        .testTarget(
            name: "OpenLibraryKitTests",
            dependencies: ["OpenLibraryKit"]),
    ]
)
