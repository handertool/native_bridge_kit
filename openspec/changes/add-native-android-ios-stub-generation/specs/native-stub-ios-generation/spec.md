## ADDED Requirements

### Requirement: Generate Swift method handler stubs from Dart bridge contracts

The code generator SHALL read a Dart class marked with `@NativeBridge` annotation and emit a Swift handler class with method dispatch, argument extraction, type conversion, and error mapping scaffolding. Generated code SHALL support Future<T> and Stream<T> return types, with named parameters only. Each method SHALL include a USER CODE block that developers edit without risk of overwrite on regeneration.

#### Scenario: Generate handler for simple Future method
- **WHEN** a Dart contract defines `Future<String?> getModel()`
- **THEN** generator emits Swift code with:
  - FlutterMethodChannel initialized on channel `device_info_bridge`
  - Method `get_model` registered in handler
  - Named arguments extracted from method arguments
  - Return type mapped to Swift type (e.g., String?), with optionality preserved
  - USER CODE block where developer implements business logic
  - Error caught and mapped to FlutterError or appropriate error handling

#### Scenario: Generate handler for Stream method
- **WHEN** a Dart contract defines `Stream<double> batteryLevel()`
- **THEN** generator emits Swift code with:
  - FlutterEventChannel initialized on channel `device_info_bridge/battery_level`
  - EventChannel.StreamHandler implementation with onListen and onCancel
  - USER CODE block where developer sets up stream logic and emits events
  - Error propagated through EventChannel error handler

#### Scenario: Handle custom type mappings
- **WHEN** a Dart method has parameter of type `DateTime` and @NativeBridge annotation specifies type mapping `DateTime → Date`
- **THEN** generated Swift code:
  - Extracts parameter as Int64 (milliseconds since epoch or ISO8601 string)
  - Converts to specified native type (Date)
  - Includes comment showing the mapping rule used

### Requirement: Generator configuration and output path resolution

The generator SHALL respect Xcode project conventions and emit Swift files in the appropriate iOS target directory. Generator SHALL include options for output path, module name, and class name overrides.

#### Scenario: Default output location
- **WHEN** Dart contract is at `lib/native/device_info_bridge.dart`
- **THEN** Swift handler is generated at `ios/Runner/GeneratedPlugins/DeviceInfoHandler.swift` (or project-configured path)

#### Scenario: Custom output path via annotation
- **WHEN** @NativeBridge includes parameter `swiftOutputPath: "custom/path"`
- **THEN** generator respects the override and writes to that path

### Requirement: Type mapping and serialization

The generator SHALL map Dart types to Swift types for all parameters and return values, handling standard types (String, Int, Double, Bool, Array, Dictionary, nil). For unsupported types, generator SHALL fail with clear error message listing supported types and migration path.

#### Scenario: Map standard Dart types
- **WHEN** contract includes parameters: String, int, double, bool, List<String>, Map<String, int>
- **THEN** generator maps to Swift types: String, Int, Double, Bool, [String], [String: Int]

#### Scenario: Handle optional types
- **WHEN** contract includes `String?`, `List<int>?`
- **THEN** generator maps to Swift: String?, [Int]?, respecting optionality

#### Scenario: Reject unsupported types with guidance
- **WHEN** contract includes parameter of type `DateTime` without type mapping annotation
- **THEN** generator fails with message: "Type DateTime not supported. Add type mapping to @NativeBridge or use adapter."

### Requirement: Method channel naming consistency

Generator SHALL use snake_case convention for channel names (class name) and method names, matching current Dart generator behavior for consistency across platforms.

#### Scenario: Channel name from class name
- **WHEN** Dart class is `DeviceInfoBridge`
- **THEN** channel name is `device_info_bridge`

#### Scenario: Method name from Dart method
- **WHEN** Dart method is `getOsVersion()`
- **THEN** method name on channel is `get_os_version`

### Requirement: Error handling and exception mapping

Generated Swift handlers SHALL catch exceptions during method dispatch and map them to FlutterError with code, message, and optional details. Business logic errors thrown in USER CODE SHALL propagate as FlutterError.

#### Scenario: Catch and map native exception
- **WHEN** USER CODE throws NSError with code "NSPermissionError" and localizedDescription "Permission denied"
- **THEN** Dart client receives PlatformException with code "NSPermissionError" and message "Permission denied"

#### Scenario: Propagate custom error code
- **WHEN** USER CODE throws custom error with code "ERR_PERMISSION"
- **THEN** Dart client receives PlatformException with code "ERR_PERMISSION"

### Requirement: iOS platform-specific considerations

Generator SHALL emit code compatible with modern Swift (5.0+) and respect iOS plugin conventions (e.g., GeneratedPluginRegistrant pattern, Pods integration).

#### Scenario: Support Swift 5.0+ concurrency
- **WHEN** Dart contract uses Stream<T>
- **THEN** generated Swift code uses async/await patterns or completion handlers compatible with iOS deployment target

#### Scenario: Handle Cocoapods and Swift package manager
- **WHEN** iOS project uses Cocoapods
- **THEN** generated code respects Podfile configuration and doesn't require additional CocoaPods setup

### Requirement: Generated code is Dart unit-testable via MockBridgeTransport

Generated Swift handlers are verifiable through Dart unit tests without native platform setup. The bridge contract can be mocked and stubbed, allowing developers to test Dart-side logic against predictable native responses.

#### Scenario: Stub Swift method in Dart test
- **WHEN** Dart unit test creates MockBridgeTransport and stubs method `device_info/get_model` to return "iPhone 99"
- **THEN** Dart code calling `bridge.getModel()` receives "iPhone 99" without iOS compilation
- **THEN** Test verifies Dart-side business logic (UI updates, error handling) works correctly

#### Scenario: Stub Swift exception in Dart test
- **WHEN** Dart unit test stubs method to throw PlatformException with code "ERR_PERMISSION"
- **THEN** Dart code calling bridge method receives PlatformException with correct code
- **THEN** Test verifies Dart error handling logic (catch block, retry, user feedback) works as expected
