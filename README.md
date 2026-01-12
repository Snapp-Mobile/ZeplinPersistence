<div align="center">
  <img src="Sources/ZeplinPersistence/ZeplinPersistence.docc/Resources/ZeplinPersistance-logo.png" width="200" alt="ZeplinPersistence Logo">
</div>

# ZeplinPersistence

A Swift Package that wraps up a CoreData container for persisting user's notifications

[![Swift Package Index](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FSnapp-Mobile%2FZeplinPersistence%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/Snapp-Mobile/ZeplinPersistence)
[![iOS 13.0+](https://img.shields.io/badge/iOS-13.0+-007AFF?logo=apple&logoColor=white)](https://www.apple.com/ios/)
[![Latest Release](https://img.shields.io/github/v/release/Snapp-Mobile/ZeplinPersistence?color=8B5CF6&logo=github&logoColor=white)](https://github.com/Snapp-Mobile/ZeplinPersistence/releases)
[![Tests](https://github.com/Snapp-Mobile/ZeplinPersistence/actions/workflows/test.yml/badge.svg)](https://github.com/Snapp-Mobile/ZeplinPersistence/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-22C55E)](LICENSE)

## Overview

ZeplinPersistence is the data layer for the Zeplin Mobile app. It handles storing notifications using CoreData and manages authentication tokens through the iOS keychain. The package uses app groups to share data between the main app and extensions like widgets or notification extensions.

The `PersistenceController` sets up a CoreData stack that can work with shared containers or in-memory stores for testing. The `TokenRepository` is an actor that safely manages OAuth tokens, handling refreshes and waiting for the device to unlock before accessing the keychain.

## Installation

Add ZeplinPersistence to your project using Swift Package Manager. In Xcode, go to File → Add Package Dependencies and enter the repository URL, or add it to your `Package.swift` file.

```swift
dependencies: [
    .package(url: "https://github.com/Snapp-Mobile/ZeplinPersistence.git", from: "0.1.0")
]
```

## Usage

Create a persistence controller for your app target. The controller handles setting up the CoreData stack with the appropriate app group identifier.

```swift
import ZeplinPersistence

let persistence = PersistenceController(target: .iOSApp, inMemory: false)
let context = persistence.container.viewContext
```

For testing, use the built-in test controller that creates an in-memory store.

```swift
let testPersistence = PersistenceController.test
```

The token repository manages authentication tokens across your app. Initialize it with your keychain settings and app target.

```swift
let tokenRepo = TokenRepository(
    key: "auth-token",
    serviceName: "com.snapp.zeplin",
    appTarget: .iOSApp,
    configuration: apiConfig
)
```

## License

ZeplinPersistence is available under the MIT license. See the LICENSE file for details.
