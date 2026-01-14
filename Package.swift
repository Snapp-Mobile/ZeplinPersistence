// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ZeplinPersistence",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "ZeplinPersistence",
            targets: ["ZeplinPersistence"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Snapp-Mobile/Fetcher", branch: "next"),
        .package(url: "https://github.com/Snapp-Mobile/ZeplinKit", branch: "next"),
        .package(url: "https://github.com/jrendel/SwiftKeychainWrapper", from: "4.0.0"),
        .package(url: "https://github.com/Snapp-Mobile/SwiftFormatLintPlugin.git", from: "1.0.4"),
    ],
    targets: [
        .target(
            name: "ZeplinPersistence",
            dependencies: ["ZeplinKit", "Fetcher", "SwiftKeychainWrapper"],
            plugins: [.plugin(name: "Lint", package: "SwiftFormatLintPlugin")]
        ),
        .testTarget(
            name: "ZeplinPersistenceTests",
            dependencies: ["ZeplinPersistence"]
        ),
    ]
)
