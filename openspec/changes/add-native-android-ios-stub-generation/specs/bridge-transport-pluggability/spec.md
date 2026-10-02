## ADDED Requirements

### Requirement: Abstract transport interface for future extensibility

The BridgeTransport interface SHALL remain platform-agnostic, defining only the contract for invoking methods and listening to streams. This design SHALL allow for future transport implementations (e.g., Dart isolate ports, direct FFI, gRPC) without affecting generated code or runtime.

#### Scenario: Current MethodChannelTransport implementation
- **WHEN** app initializes with `BridgeTransport transport = MethodChannelTransport()`
- **THEN** all bridge invocations use Flutter's MethodChannel and EventChannel under the hood

#### Scenario: Swap transport at runtime
- **WHEN** developer creates alternative `NativePortTransport` implementing BridgeTransport
- **THEN** app can use it by passing `BridgeTransport transport = NativePortTransport()` to bridge constructor without changing generated or hand-written bridge code

### Requirement: Transport interface stability

The BridgeTransport interface (methods `invoke<T>` and `listen<T>`) SHALL remain stable and version-compatible across releases. Any breaking changes to transport interface SHALL require major version bump.

#### Scenario: Transport interface immutability in v0.1
- **WHEN** v0.1 release is published
- **THEN** BridgeTransport interface is locked (no method additions without new version)

#### Scenario: Add new transport method in future major release
- **WHEN** v1.0 is planned with new transport feature (e.g., bidirectional streams)
- **THEN** interface is extended only with new methods, old methods retained for backward compatibility

### Requirement: Documentation and examples for transport pluggability

Generated code SHALL include comments explaining how developers can provide custom transports. Documentation SHALL include example of implementing a custom transport for testing or special use cases.

#### Scenario: Bridge constructor accepts any BridgeTransport
- **WHEN** developer reads generated bridge code and javadoc/swiftdoc
- **THEN** documentation shows `DeviceInfoBridge(BridgeTransport transport)` and explains transport pluggability

#### Scenario: Example test double transport
- **WHEN** developer reads plugin docs
- **THEN** docs include MockBridgeTransport example (already exists in test utils) and show how to use it in unit tests

#### Scenario: Test your bridge in Dart without native platform
- **WHEN** developer reads testing guide
- **THEN** docs include complete example: create MockBridgeTransport, stub methods and streams, write unit tests for Dart-side logic
- **THEN** example shows how to test error cases, stream cancellation, and business logic without compiling native code
