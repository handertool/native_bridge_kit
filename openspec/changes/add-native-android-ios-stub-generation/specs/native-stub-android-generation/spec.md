## ADDED Requirements

### Requirement: Generate Kotlin method handler stubs from Dart bridge contracts

The code generator SHALL read a Dart class marked with `@NativeBridge` annotation and emit a Kotlin handler file with method dispatch, argument extraction, type conversion, and error mapping scaffolding. Generated code SHALL support Future<T> and Stream<T> return types, with named parameters only. Each method SHALL include a USER CODE block that developers edit without risk of overwrite on regeneration.

#### Scenario: Generate handler for simple Future method
- **WHEN** a Dart contract defines `Future<String?> getModel()`
- **THEN** generator emits Kotlin code with:
  - MethodChannel registered on channel `device_info_bridge`
  - Method `get_model` registered in handler
  - Named arguments extracted from Map
  - Return type mapped to Kotlin type (e.g., String?), with nullability preserved
  - USER CODE block where developer implements business logic
  - Error caught and mapped to PlatformException

#### Scenario: Generate handler for Stream method
- **WHEN** a Dart contract defines `Stream<double> batteryLevel()`
- **THEN** generator emits Kotlin code with:
  - EventChannel registered on channel `device_info_bridge/battery_level`
  - EventChannel.StreamHandler implementation with onListen and onCancel
  - USER CODE block where developer sets up stream logic and emits events
  - Error propagated through EventChannel error handler

#### Scenario: Handle custom type mappings
- **WHEN** a Dart method has parameter of type `DateTime` and @NativeBridge annotation specifies type mapping `DateTime → java.time.Instant`
- **THEN** generated Kotlin code:
  - Extracts parameter as Long (milliseconds since epoch)
  - Converts to specified native type (Instant)
  - Includes comment showing the mapping rule used

### Requirement: Generator configuration and output path resolution

The generator SHALL respect build_runner conventions and emit Kotlin files adjacent to the Dart contract or in a configurable output directory. Generator SHALL include options for output path, package name, and class name overrides.

#### Scenario: Default output location
- **WHEN** Dart contract is at `lib/native/device_info_bridge.dart`
- **THEN** Kotlin handler is generated at `android/app/src/main/kotlin/DeviceInfoHandler.kt` (or project-configured path)

#### Scenario: Custom output path via annotation
- **WHEN** @NativeBridge includes parameter `kotlinOutputPath: "custom/path"`
- **THEN** generator respects the override and writes to that path

### Requirement: Type mapping and serialization

The generator SHALL map Dart types to Kotlin types for all parameters and return values, handling standard types (String, int, double, bool, List, Map, null). For unsupported types, generator SHALL fail with clear error message listing supported types and migration path.

#### Scenario: Map standard Dart types
- **WHEN** contract includes parameters: String, int, double, bool, List<String>, Map<String, int>
- **THEN** generator maps to Kotlin types: String, Int, Double, Boolean, List<String>, Map<String, Int>

#### Scenario: Handle nullable types
- **WHEN** contract includes `String?`, `List<int>?`
- **THEN** generator maps to Kotlin: String?, List<Int>?, respecting nullability

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

Generated Kotlin handlers SHALL catch exceptions during method dispatch and map them to PlatformException with code, message, and optional details. Business logic errors thrown in USER CODE SHALL propagate as PlatformException.

#### Scenario: Catch and map native exception
- **WHEN** USER CODE throws Exception("Permission denied")
- **THEN** Dart client receives PlatformException with code "Exception" and message "Permission denied"

#### Scenario: Propagate custom error code
- **WHEN** USER CODE throws custom exception with code "ERR_PERMISSION"
- **THEN** Dart client receives PlatformException with code "ERR_PERMISSION"

### Requirement: Generated code is Dart unit-testable via MockBridgeTransport

Generated Kotlin handlers are verifiable through Dart unit tests without native platform setup. The bridge contract can be mocked and stubbed, allowing developers to test Dart-side logic against predictable native responses.

#### Scenario: Stub Kotlin method in Dart test
- **WHEN** Dart unit test creates MockBridgeTransport and stubs method `device_info/get_model` to return "iPhone 99"
- **THEN** Dart code calling `bridge.getModel()` receives "iPhone 99" without native compilation
- **THEN** Test verifies Dart-side business logic (UI updates, error handling) works correctly

#### Scenario: Stub Kotlin exception in Dart test
- **WHEN** Dart unit test stubs method to throw PlatformException with code "ERR_PERMISSION"
- **THEN** Dart code calling bridge method receives PlatformException with correct code
- **THEN** Test verifies Dart error handling logic (catch block, retry, user feedback) works as expected
