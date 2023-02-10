// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZeplinPersistence",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ZeplinPersistence",
            targets: ["ZeplinPersistence"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Snapp-Mobile/Fetcher", from: "0.0.2"),
        .package(url: "https://github.com/Snapp-Mobile/ZeplinKit", from: "0.0.3"),
        .package(url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ZeplinPersistence",
            dependencies: ["ZeplinKit", "Fetcher", "SwiftKeychainWrapper"]),
        .testTarget(
            name: "ZeplinPersistenceTests",
            dependencies: ["ZeplinPersistence"]),
    ]
)
