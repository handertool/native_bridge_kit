## ADDED Requirements

### Requirement: Troubleshooting guide for common setup errors
docs/troubleshooting.md SHALL document common errors during installation, setup, and development with solutions for each.

#### Scenario: Developer encounters build_runner error
- **WHEN** developer runs `build_runner build` and gets an error
- **THEN** they can look up the error in the troubleshooting guide and find a solution

#### Scenario: Developer encounters generator not found error
- **WHEN** developer sees "Generator for annotation NativeBridge not found"
- **THEN** the troubleshooting guide explains: need to add dev_dependency in pubspec.yaml

#### Scenario: Developer encounters compilation error
- **WHEN** developer gets Kotlin/Swift compilation error in generated code
- **THEN** the troubleshooting guide shows: likely causes and how to fix contract definition

### Requirement: Troubleshooting guide covers Android-specific issues
The troubleshooting guide SHALL include common Android development issues like SDK version mismatches, NDK setup, and Kotlin version conflicts.

#### Scenario: Developer fixes Android SDK version issue
- **WHEN** developer encounters Android SDK version error
- **THEN** the guide shows: correct minSdkVersion, targetSdkVersion, and compilation settings

#### Scenario: Developer fixes Kotlin version mismatch
- **WHEN** developer encounters Kotlin compiler error
- **THEN** the guide shows: compatible Kotlin and Gradle versions

### Requirement: Troubleshooting guide covers iOS-specific issues
The troubleshooting guide SHALL include common iOS development issues like Xcode version, CocoaPods, and Swift version conflicts.

#### Scenario: Developer fixes iOS deployment target
- **WHEN** developer encounters deployment target error
- **THEN** the guide shows: minimum iOS version and how to set it in Xcode

#### Scenario: Developer fixes Swift version issue
- **WHEN** developer encounters Swift compiler error
- **THEN** the guide shows: compatible Swift versions and how to update Xcode

### Requirement: Troubleshooting guide covers drift-check issues
The troubleshooting guide SHALL document common drift-check problems like file not found, parser failures, and CI integration issues.

#### Scenario: Developer fixes drift-check file not found
- **WHEN** drift-check reports "contract file not found"
- **THEN** the guide explains: expected file path and how to configure it

#### Scenario: Developer fixes drift-check CI failure
- **WHEN** drift-check fails in CI but passes locally
- **THEN** the guide explains: path differences, file discovery, and --platform flags

### Requirement: Troubleshooting guide covers testing issues
The troubleshooting guide SHALL document common unit testing problems with MockBridgeTransport like missing stubs and assertion failures.

#### Scenario: Developer fixes missing stub error
- **WHEN** test fails with "no stub registered for channel/method"
- **THEN** the guide shows: how to add stubMethod() and verify method name

#### Scenario: Developer fixes assertion failure
- **WHEN** test assertion fails unexpectedly
- **THEN** the guide explains: common assertion errors and debugging techniques

### Requirement: Troubleshooting has FAQ section
The troubleshooting guide SHALL include a FAQ section with questions frequently asked by developers.

#### Scenario: Developer finds answer in FAQ
- **WHEN** developer has a common question
- **THEN** they find answer in FAQ without reading entire troubleshooting guide
