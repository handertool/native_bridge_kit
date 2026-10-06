# native_bridge_kit_ios_gen

iOS Swift code generator for native_bridge_kit. Automatically generates Swift handler stubs from Dart bridge contracts.

This package targets iOS only. Web and Linux handler code is not generated.

## Overview

`native_bridge_kit_ios_gen` is a code generator that creates Swift handler scaffolds from your Dart bridge contracts. It integrates with `build_runner` and generates FlutterMethodChannel/FlutterEventChannel wiring plus marked implementation points. The generated file is a scaffold: register the implemented handler from your iOS host code and fill in the platform-specific behavior.

## Installation

Add to your project's `pubspec.yaml` **dev_dependencies**:

```yaml
dev_dependencies:
  build_runner: ^2.4.0
  native_bridge_kit_gen: ^0.1.4
  native_bridge_kit_ios_gen: ^0.1.4
```

## Quick Start

### 1. Define Your Dart Contract

```dart
// lib/native/device_bridge.dart
import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';

part 'device_bridge.g.dart';

@NativeBridge()
abstract class DeviceBridge {
  @NativeMethod()
  Future<String> getModel();

  @NativeMethod()
  Future<int> getBatteryLevel();

  @NativeStream()
  Stream<int> get batteryUpdates;
}
```

### 2. Generate Dart Code

```bash
flutter pub run build_runner build
```

This generates:
- `device_bridge.g.dart` — Dart implementation
- iOS: `DeviceHandler.g.swift` — Swift stubs

### 3. Implement Swift Handler

The generator creates `ios/Runner/DeviceHandler.swift`:

```swift
class DeviceHandler {
  func getModel() -> String {
    // MARK: - BEGIN USER CODE
    // TODO: Implement your handler
    return ""
    // MARK: - END USER CODE
  }

  func getBatteryLevel() -> Int {
    // MARK: - BEGIN USER CODE
    // TODO: Implement your handler
    return 0
    // MARK: - END USER CODE
  }

  func onBatteryUpdatesListen(sink: FlutterEventSink) {
    // MARK: - BEGIN USER CODE
    // TODO: Implement your stream handler
    // MARK: - END USER CODE
  }

  func onBatteryUpdatesCancel() {
    // MARK: - BEGIN USER CODE
    // TODO: Cleanup
    // MARK: - END USER CODE
  }
}
```

Fill in the `MARK: - BEGIN USER CODE` / `MARK: - END USER CODE` blocks with your implementation.

Generated Swift files are not registered automatically in the iOS host and
cannot infer platform-specific behavior. Keep the generated scaffold under
source control, or copy its channel/dispatch structure into a host handler such
as `ios/Runner/SceneDelegate.swift`.

### 4. Run Tests

```bash
flutter test
```

Your Dart unit tests use `MockBridgeTransport` — no iOS compilation needed.

## Features

- **Type-safe**: Full Swift type checking
- **FlutterMethodChannel integration**: Automatic method dispatch
- **FlutterEventChannel support**: Stream event handling
- **Error mapping**: Consistent exception handling with FlutterError
- **USER CODE preservation**: Your code survives regenerations
- **Future<T> support**: Async operations with proper error handling
- **Stream<T> support**: Event streaming with onListen/onCancel

## Generated Code Structure

For each method in your contract, the generator creates:

**For Future methods:**
```swift
private func handleGetModel(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
  do {
    let model = try getModel()
    result(model)
  } catch {
    result(FlutterError(code: "ERROR_CODE", message: error.localizedDescription, details: nil))
  }
}
```

**For Stream methods:**
```swift
private func setupBatteryUpdatesStream(_ arguments: Any?, eventSink: @escaping FlutterEventSink) {
  onBatteryUpdatesListen(sink: eventSink)
}
```

## Type Mapping

The generator automatically maps Dart types to Swift types:

| Dart | Swift |
|------|-------|
| `String` | `String` |
| `int` | `Int` |
| `double` | `Double` |
| `bool` | `Bool` |
| `List<T>` | `[T]` (Array) |
| `Map<K, V>` | `[K: V]` (Dictionary) |
| `Future<T>` | Async method returning `T` |
| `Stream<T>` | FlutterEventChannel emitting `T` |

### Custom Type Mapping

Define custom mappings in your contract:

```dart
@NativeBridge(
  typeMapping: {
    'DateTime': 'TimeInterval',
    'Uri': 'String',
  }
)
abstract class FileBridge {
  Future<void> saveFile(Uri path, DateTime modified);
}
```

## Best Practices

1. **Fill in USER CODE blocks carefully** — Your implementation is preserved across regenerations
2. **Keep handlers focused** — Each handler should do one thing
3. **Use meaningful error codes** — Use consistent error codes for similar failures
4. **Handle iOS-specific APIs** — Use `@available` guards for version-specific features
5. **Test with MockBridgeTransport first** — Verify logic before native platform

## Testing

Unit test your bridge before running on iOS:

```dart
test('getModel returns device model', () async {
  final transport = MockBridgeTransport();
  transport.stubMethodValue('getModel', 'iPhone 13');

  final bridge = DeviceBridgeImpl(transport);
  expect(await bridge.getModel(), 'iPhone 13');
});
```

For integration testing on real iOS, see [Testing Guide](../docs/testing-guide.md).

## Troubleshooting

**Generator not running?**
- Ensure `native_bridge_kit_ios_gen` is in `dev_dependencies`
- Run `flutter pub get && flutter pub run build_runner clean && flutter pub run build_runner build`

**Type mismatch errors?**
- Check that your Swift handler types match the Dart contract
- Use custom type mapping for non-standard types

**USER CODE blocks disappeared?**
- Make sure to use exact `MARK: - BEGIN USER CODE` / `MARK: - END USER CODE` markers
- Don't modify the marker text

## Performance Notes

- Generated code uses FlutterMethodChannel/FlutterEventChannel for communication
- No reflection — fully type-safe and efficient
- Minimal overhead — pure method dispatch

## API Reference

For complete API details, see [API Reference Guide](../docs/api-reference.md).

## Next Steps

- **Getting Started?** See [Getting Started Guide](../docs/getting-started.md)
- **Android too?** See [native_bridge_kit_android_gen](../packages/native_bridge_kit_android_gen/README.md)
- **CLI Tools?** See [native_bridge_kit_cli](../packages/native_bridge_kit_cli/README.md) for drift-check
- **Examples?** See [Example Project](../examples/device-info-app)

---

[← Back to Root README](../README.md)
