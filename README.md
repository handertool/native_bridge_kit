# Native Bridge Kit

Dart-first code generation for Flutter platform bridges.

Native Bridge Kit lets you describe a Flutter-to-native API once in Dart, generate the Dart transport implementation, and generate Kotlin and Swift handler scaffolds from the same contract. It reduces channel-name drift and repetitive dispatch code while keeping platform behavior in normal Android and iOS application code.

> Native Bridge Kit generates the bridge plumbing. It does not generate your device, SDK, permission, or business logic.

## Why use it?

Manual `MethodChannel` and `EventChannel` code usually duplicates the same information in several places:

- Dart method names and return types
- channel and wire names
- Android dispatch code
- iOS dispatch code
- test doubles
- documentation and drift checks

Those copies can silently diverge. Native Bridge Kit makes the Dart contract the starting point and generates the repetitive parts around it.

## USP

The main differentiator is the combination of four capabilities in one Dart-first workflow:

1. **One contract** — the public bridge API is declared in Dart.
2. **Three generated surfaces** — Dart implementation code, Kotlin scaffolds, and Swift scaffolds can be produced from that contract.
3. **Testable transport** — generated Dart code accepts an injected transport, so application tests can use `MockBridgeTransport` without a device or native build.
4. **Drift detection** — the `native_bridge_kit_cli` package can compare a contract with checked-in native handlers in CI.

This is useful for teams that want typed, reviewable platform boundaries without hiding native code behind a large framework or requiring every platform feature to be modeled in a separate schema language.

## What it can do

- Define annotated Dart bridge contracts.
- Generate concrete Dart implementations that call a `BridgeTransport`.
- Use `MethodChannel` for `Future<T>` methods.
- Use `EventChannel` for annotated `Stream<T>` methods.
- Generate Kotlin handler scaffolds for Android.
- Generate Swift handler scaffolds for iOS.
- Inject `MethodChannelTransport` in production code.
- Inject `MockBridgeTransport` in unit tests.
- Convert native channel failures into `NativeBridgeException`.
- Validate contract/native-handler drift with the CLI.
- Keep generated output reviewable because native output is ordinary Kotlin and Swift source.
- Adopt the system gradually alongside existing manual channels.

## What it cannot do

Native Bridge Kit intentionally does not attempt to be a complete native plugin framework. It does not:

- Implement platform-specific business logic for you.
- Automatically discover or register handlers in every Android/iOS host application.
- Request Android or iOS permissions.
- Configure Gradle, CocoaPods, Xcode targets, manifests, entitlements, or signing.
- Choose the correct platform SDK/API for your feature.
- Guarantee that generated Kotlin or Swift compiles for every project configuration.
- Generate production-ready lifecycle, threading, background execution, or resource-management code.
- Serialize arbitrary Dart classes or complex object graphs automatically.
- Replace native integration tests on real devices and simulators.
- Provide web, desktop, or bidirectional event support automatically.
- Preserve hand-edited generated files; generated files should be treated as disposable outputs.

You remain responsible for native implementation, host registration, lifecycle behavior, permissions, serialization decisions, security, performance, and device testing.

## Installation

The published packages include the runtime, annotations, generators, and CLI:

```yaml
dependencies:
  native_bridge_kit: ^0.1.0
```

When using code generation, add the generator facade as a development dependency:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

The planned supporting packages are:

- `native_bridge_kit_annotation`
- `native_bridge_kit_dart_gen`
- `native_bridge_kit_android_gen`
- `native_bridge_kit_ios_gen`

## Quick start

The contract and generation example below is available in this repository. The generator packages will be added to pub.dev in a later release.

### 1. Define a contract

Create `lib/native/device_info_bridge.dart`:

```dart
import 'package:native_bridge_kit/native_bridge_kit.dart';

part 'device_info_bridge.g.dart';

@NativeBridge(channelPrefix: 'device_info')
abstract class DeviceInfoBridge {
  factory DeviceInfoBridge(BridgeTransport transport) = _$DeviceInfoBridge;

  Future<String?> getModel();
  Future<String?> getOsVersion();

  @NativeStream()
  Stream<double> batteryLevel();
}
```

The contract declares the API and channel prefix. The Dart generator derives wire names such as `get_model`, `get_os_version`, and `device_info/battery_level`.

### 2. Generate the Dart and native scaffolds

```bash
dart run build_runner build --delete-conflicting-outputs
```

Depending on the configured builders, generated output includes:

```text
lib/native/device_info_bridge.g.dart
lib/native/device_info_bridge.g.kt
lib/native/device_info_bridge.g.swift
```

The `.g.dart` file contains the concrete bridge implementation. The `.g.kt` and `.g.swift` files are starting points for native channel dispatch and handler structure.

### 3. Use the generated Dart bridge

```dart
final bridge = DeviceInfoBridge(MethodChannelTransport());

final model = await bridge.getModel();
final osVersion = await bridge.getOsVersion();

await for (final battery in bridge.batteryLevel()) {
  print('Battery: $battery%');
}
```

`MethodChannelTransport` communicates with the host platform. The host must register matching channels and implement the native behavior.

### 4. Implement and register native handlers

The generated native files do not know how your feature works. Implement the methods using platform APIs and register the handler from the host lifecycle, for example in an Android `Activity` or an iOS `AppDelegate`/scene lifecycle.

Android and iOS must agree with the Dart contract:

```text
Method channel: device_info
Methods:        get_model, get_os_version
Event channel:  device_info/battery_level
```

### 5. Test without a device

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';

test('bridge forwards the model call', () async {
  final transport = MockBridgeTransport()
    ..stubMethodValue('device_info', 'get_model', 'Pixel 9');

  final bridge = DeviceInfoBridge(transport);

  expect(await bridge.getModel(), 'Pixel 9');
});
```

This test checks the Dart contract and generated transport behavior. It does not prove that Android or iOS returns the correct real device value; that still requires native tests.

## Architecture

```text
Dart contract
    |
    | build_runner
    v
Generated Dart bridge -------------- MockBridgeTransport -> unit tests
    |
    | BridgeTransport
    v
MethodChannelTransport
    |
    +--> Android MethodChannel/EventChannel handler
    |
    +--> iOS FlutterMethodChannel/FlutterEventChannel handler
             |
             v
       Platform APIs and your native logic
```

The transport abstraction is intentionally small:

```dart
abstract interface class BridgeTransport {
  Future<T?> invoke<T>(
    String channel,
    String method,
    Map<String, dynamic> args,
  );

  Stream<T> listen<T>(String channel);
}
```

That boundary makes the generated Dart class easy to test and keeps Flutter channel details out of the contract itself.

## Generated versus manual work

| Area | Generated | Still manual |
|---|---:|---:|
| Dart bridge implementation | Yes | No, unless customizing |
| Method/event channel naming | Derived from contract | Must keep native host aligned |
| Kotlin/Swift handler scaffold | Yes | Platform logic and registration |
| MethodChannel transport | Yes, runtime package | Host channel setup |
| Mock transport | Yes, runtime package | Test expectations |
| Permissions and entitlements | No | Yes |
| Native SDK integration | No | Yes |
| Lifecycle/background behavior | No | Yes |
| Device/integration testing | No | Yes |

## Contract and type limitations

The current generators are designed for a deliberately small, predictable API surface. Verify the supported mappings in the API documentation before introducing a new type. In particular:

- Primitive values and supported nullable variants are the safest choice.
- `Future<T>` is intended for request/response methods.
- Annotated `Stream<T>` is intended for event output.
- Complex models, enums, lists, maps, binary data, and custom serialization may require explicit generator support or manual adaptation.
- The generated native source is a scaffold and may need edits for nullability, SDK availability, threading, and project conventions.

## Drift checking

Install the optional CLI globally:

```bash
dart pub global activate native_bridge_kit_cli
```

Run it from a project containing a contract and native handlers:

```bash
dart run native_bridge_kit_cli:drift_check \
  --project-root . \
  --fail-on-drift
```

The CLI checks naming and contract/handler alignment. It is not a compiler and cannot prove that native code is correct, safe, performant, or registered at runtime.

## Example project

The repository contains a device-information example in [`examples/device-info-app`](examples/device-info-app). It demonstrates:

- A Dart contract.
- Generated Dart bridge code.
- Android Kotlin channel handling.
- iOS Swift channel handling.
- Mock transport unit tests.
- Native integration-test structure.

The example is reference code, not part of the runtime package and not a general-purpose device-information library.

## Package layout and release scope

The initial pub.dev release contains:

- `native_bridge_kit` — runtime transports, exceptions, mocks, and re-exported annotations.
- `native_bridge_kit_annotation` — the annotation dependency used by the runtime.

The following packages are published alongside the runtime packages:

- `native_bridge_kit_dart_gen` — Dart `.g.dart` generator.
- `native_bridge_kit_android_gen` — Kotlin `.g.kt` generator.
- `native_bridge_kit_ios_gen` — Swift `.g.swift` generator.
- `native_bridge_kit_gen` — generator facade.
- `native_bridge_kit_cli` — optional `drift_check` command.

## Validation commands

From the repository root:

```bash
flutter analyze
flutter test

cd examples/device-info-app
flutter analyze
flutter test
```

For package publication checks:

```bash
dart pub publish --dry-run
```

Run that command separately in each package directory. Publish foundational packages before packages that depend on them.

## Documentation

- [Getting started](docs/getting-started.md)
- [Installation guide](docs/installation.md)
- [API reference](docs/api-reference.md)
- [Testing guide](docs/testing-guide.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Migration from MethodChannel](docs/migrate-from-methodchannel.md)
- [Migration from Pigeon](docs/migrate-from-pigeon.md)
- [Contributing](CONTRIBUTING.md)

## License and contribution

Native Bridge Kit is released under the MIT License. See [`LICENSE`](LICENSE) for details. Contributions and issue reports are welcome at the [GitHub repository](https://github.com/handertool/native_bridge_kit).
