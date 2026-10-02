## ADDED Requirements

### Requirement: Complete example Android+iOS sample project
examples/device-info-app/ SHALL be a complete, runnable Flutter app demonstrating the native_bridge_kit pattern on both Android and iOS with working Dart unit tests.

#### Scenario: Developer clones and runs example
- **WHEN** developer clones the repository and runs `flutter run` in examples/device-info-app
- **THEN** the app builds and runs on device/simulator without errors

#### Scenario: Developer sees generated code
- **WHEN** developer explores examples/device-info-app/lib/native
- **THEN** they see: contract file and generated _$ implementation file

#### Scenario: Developer sees Kotlin implementation
- **WHEN** developer explores examples/device-info-app/android
- **THEN** they see: DeviceInfoHandler.kt with @BEGIN_USER_CODE/@END_USER_CODE blocks filled in

#### Scenario: Developer sees Swift implementation
- **WHEN** developer explores examples/device-info-app/ios/Runner
- **THEN** they see: DeviceInfoHandler.swift with MARK: - BEGIN/END USER CODE sections filled in

### Requirement: Example project has complete Dart unit tests
The example project SHALL include a comprehensive test suite using MockBridgeTransport that runs with `flutter test` without native platform.

#### Scenario: Developer runs tests
- **WHEN** developer runs `flutter test` in examples/device-info-app
- **THEN** all tests pass, covering: methods, streams, errors

#### Scenario: Developer sees test patterns
- **WHEN** developer reads examples/device-info-app/test/device_info_bridge_test.dart
- **THEN** they see: test patterns for Future, Stream, error cases with assertions

#### Scenario: Developer sees mocking patterns
- **WHEN** developer reads the test file
- **THEN** they see: `transport.stubMethodValue()`, `transport.stubStreamValues()`, `transport.stubMethodError()` usage

### Requirement: Example project includes integration tests
The example project SHALL include integration tests that verify the bridge works with real native code on device/simulator.

#### Scenario: Developer runs integration tests
- **WHEN** developer runs `flutter test integration_test/` on device/simulator
- **THEN** integration tests pass, calling real native code

#### Scenario: Developer sees real vs. mock comparison
- **WHEN** developer compares unit tests and integration tests
- **THEN** they see: same test logic, different transport (MockBridgeTransport vs. MethodChannelTransport)

### Requirement: Example project README
examples/device-info-app/README.md SHALL explain the structure, how to run, and what to modify for learning.

#### Scenario: Developer understands project structure
- **WHEN** developer reads examples/device-info-app/README.md
- **THEN** they understand: folder structure, which files were auto-generated, which were written by hand

#### Scenario: Developer knows what to modify
- **WHEN** developer reads the README
- **THEN** it shows: which methods to implement, where USER CODE blocks are, how to add new methods

### Requirement: Example project demonstrates best practices
The example project SHALL follow best practices for error handling, documentation, naming conventions, and code organization.

#### Scenario: Developer learns best practices
- **WHEN** developer reads examples/device-info-app code
- **THEN** they see: meaningful error codes, descriptive comments, consistent naming

#### Scenario: Developer can copy patterns
- **WHEN** developer creates their own bridge
- **THEN** they can reference the example project's patterns: contracts, handlers, tests, organization
