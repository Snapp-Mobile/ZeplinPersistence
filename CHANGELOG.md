# Change Log
All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-01-12

First public release of ZeplinPersistence.

### Added
- Documentation comments for all public APIs
- DocC documentation with package overview
- Comprehensive README with installation and usage examples
- MIT License
- Swift Package Index configuration
- GitHub Actions CI workflow for running tests
- Issue and pull request templates
- Basic XCTest suite for CoreData persistence
- SwiftFormat lint plugin for code consistency

## [0.0.2] - 2025-01-12

### Changed
- Updated to Fetcher v0.0.2 and ZeplinKit v0.0.3
- Made AppTarget conform to Sendable for Swift concurrency

## [0.0.1] - 2025-01-12

Initial internal release.

### Added
- PersistenceController for managing CoreData stack with app group support
- TokenRepository actor for secure keychain-based token management
- NotificationRecord entity with CoreData model
- AppTarget enum for configuring different app targets
- Support for iOS, macOS, and watchOS platforms
