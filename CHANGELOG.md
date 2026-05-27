# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- SwiftUI fundamentals (views, modifiers, state management)
- Architecture patterns (MVVM with Observable)
- Navigation (NavigationStack, sheets, deep links)
- Swift Concurrency patterns
- Remote Mac setup guide (user-configured, no hardcoded credentials)
- Xcode CLI workflow commands
- iOS 26+ features reference
- App Store provisioning guidance
- Common iOS issues & fixes table

### Changed
- Renamed skill from `android-dev` to `build-mobile`
- Expanded scope to include iOS/macOS/SwiftUI development
- Split `REFERENCE.md` into focused sub-files:
  - `REFERENCE-GRADLE.md` (Gradle templates, KMP, Compose testing)
  - `REFERENCE-FLUTTER.md` (pubspec, state management, patterns)
  - `REFERENCE-COMPOSE.md` (Compose testing)
  - `REFERENCE-SWIFTUI.md` (SwiftUI, Xcode CLI, remote Mac)
- Removed hardcoded credentials (IP, username, password) from Remote Mac section
- Replaced machine-specific environment data with portable placeholders
- Fixed inaccurate KMP CLI commands (`./gradlew createKmpProject` → Gradle plugin approach)
- Fixed inaccurate Flutter file creation commands
- Trimmed `SKILL.md` from ~575 lines to ~85 lines

### Fixed
- Removed hardcoded password from Remote Mac SSH section
- Removed hardcoded IP `10.74.74.139` and username `ricardo`
- Removed hardcoded Mac specs (Xcode build numbers, RAM, disk)
- Updated Flutter targets table to show "Requires user-configured remote Mac"

### Deprecated
- Single monolithic `REFERENCE.md` (replaced by split sub-files)

---

## [1.0.0] - 2024-01-01

### Added
- Android SDK tooling workflows
- Flutter project scaffolding and dependency management
- Kotlin Multiplatform (KMP) project setup
- Remote Mac build integration
- Environment audit script
- Compatibility matrices
- Quick reference commands

[unreleased]: https://github.com/vl4dt/build-mobile/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/vl4dt/build-mobile/releases/tag/v1.0.0
