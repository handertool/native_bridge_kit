## Why

Flutter developers currently use MethodChannel and EventChannel with manual boilerplate on both Dart and native sides, or rely on code generators like Pigeon that introduce cognitive overhead through separate API definition languages. This creates friction: contracts drift across platforms, changes require editing multiple languages, new developers face high setup complexity, and testing is difficult without a native platform.

We're building a Dart-first bridge system where developers define platform APIs once in Dart and automatically generate typed Dart clients, Kotlin handlers, and Swift handlers—keeping the contract as the single source of truth and minimizing boilerplate. **Critically, developers can unit test bridge code in Dart without native platform setup**, using MockBridgeTransport to mock native responses and verify Dart-side logic.

## What Changes

- **New Dart generators** for Kotlin and Swift handler stubs that mirror Dart contract signatures, maintaining channel naming conventions
- **Contract drift detection**: add `openspec drift-check` command to catch sync issues before runtime
- **Test doubles and mocking**: MockBridgeTransport with builder API for stubbing methods and streams; Dart developers can unit test bridge code in isolation without native platform
- **Testability-first architecture**: transport abstraction enables all bridge code to be unit tested in Dart; generated handlers are inherently verifiable via contract
- **Phase 2 transport layer**: prepare architecture for pluggable transport beyond MethodChannel (e.g., Dart isolate ports)
- **Documentation and templates**: one end-to-end Android+iOS sample plugin demonstrating single contract → runnable native code with Dart unit tests

## Capabilities

### New Capabilities

- `native-stub-android-generation`: Generate Kotlin handler stubs from Dart bridge contracts, including method dispatch, argument extraction, and error mapping
- `native-stub-ios-generation`: Generate Swift handler stubs from Dart bridge contracts with same channel and argument conventions as Kotlin
- `contract-drift-check`: Validate Dart contract matches generated native stubs; fail fast on mismatch
- `bridge-transport-pluggability`: Extend BridgeTransport interface to support alternative transports (Phase 2); current implementation uses MethodChannel + EventChannel

### Modified Capabilities

- `dart-code-generation`: Existing Dart generator updated to support new field in annotations for native type mappings and to emit transport-agnostic invocation code

## Impact

- **New packages**: native_bridge_kit_android_gen (Kotlin generator), native_bridge_kit_ios_gen (Swift generator)
- **Modified packages**: native_bridge_kit_gen (add type mapping rules), native_bridge_kit_annotation (add optional native type mappings)
- **CLI enhancement**: openspec CLI adds `drift-check` subcommand
- **Dependencies**: Add analyzer and build dependencies for new generators
- **Breaking changes**: None in v0.1; transport is internal API

## Scope for v0.1

- Android (Kotlin) and iOS (Swift) only
- Support Future<T> and Stream<T> return types
- Named parameters only (matching current Dart generator)
- Standard types (String, int, double, bool, List, Map) with optional custom type adapters
- MethodChannel and EventChannel transport
- Dev-time drift checking, not runtime enforcement
- **Dart unit test support**: MockBridgeTransport fully functional for all Future and Stream methods; test examples and documentation included
