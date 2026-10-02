# native_bridge_kit_android_gen

Android Kotlin code generator for native_bridge_kit. Automatically generates Kotlin handler stubs from Dart bridge contracts.

This package targets Android only. Web and Linux handler code is not generated.

## Overview

`native_bridge_kit_android_gen` is a code generator that creates Kotlin handler scaffolds from your Dart bridge contracts. It integrates with `build_runner` and generates MethodChannel/EventChannel wiring plus marked implementation points. The generated file is a scaffold: register the implemented handler from your Android host code and fill in the platform-specific behavior.

## Installation

Add to your project's `pubspec.yaml` **dev_dependencies**:

```yaml
dev_dependencies:
  build_runner: ^2.4.0
  native_bridge_kit_gen: ^0.1.3
  native_bridge_kit_android_gen: ^0.1.3
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
- Android: `DeviceHandler.g.kt` — Kotlin stubs

### 3. Implement Kotlin Handler

The generator creates `android/app/src/main/kotlin/com/example/app/DeviceHandler.kt`:

```kotlin
class DeviceHandler(private val context: Context) {
  fun getModel(): String {
    // BEGIN_USER_CODE
    // TODO: Implement your handler
    return ""
    // END_USER_CODE
  }

  fun getBatteryLevel(): Int {
    // BEGIN_USER_CODE
    // TODO: Implement your handler
    return 0
    // END_USER_CODE
  }

  fun onBatteryUpdatesListen(sink: EventSink) {
    // BEGIN_USER_CODE
    // TODO: Implement your stream handler
    // END_USER_CODE
  }

  fun onBatteryUpdatesCancel() {
    // BEGIN_USER_CODE
    // TODO: Cleanup
    // END_USER_CODE
  }
}
```

Fill in the `BEGIN_USER_CODE` / `END_USER_CODE` blocks with your implementation.

Generated Kotlin files are not registered automatically in the Android host and
cannot infer platform-specific behavior. Keep the generated scaffold under
source control, or copy its channel/dispatch structure into a host handler such
as `android/app/src/main/kotlin/.../DeviceInfoBridgeHandler.kt`.

### 4. Run Tests

```bash
flutter test
```

Your Dart unit tests use `MockBridgeTransport` — no Android compilation needed.

## Features

- **Type-safe**: Full Kotlin type checking
- **MethodChannel integration**: Automatic method dispatch
- **EventChannel support**: Stream event handling
- **Error mapping**: Consistent exception handling
- **USER CODE preservation**: Your code survives regenerations
- **Future<T> support**: Async operations with proper error handling
- **Stream<T> support**: Event streaming with onListen/onCancel

## Generated Code Structure

For each method in your contract, the generator creates:

**For Future methods:**
```kotlin
private fun handleGetModel(methodCall: MethodCall, result: Result) {
  try {
    val model = getModel()
    result.success(model)
  } catch (e: Exception) {
    result.error("ERROR_CODE", e.message, null)
  }
}
```

**For Stream methods:**
```kotlin
private fun setupBatteryUpdatesStream(result: Result) {
  val eventSink = object : EventSink {
    override fun onNext(event: Any?) { /* ... */ }
    override fun onError(error: Throwable) { /* ... */ }
    override fun onCompleted() { /* ... */ }
  }
  onBatteryUpdatesListen(eventSink)
}
```

## Type Mapping

The generator automatically maps Dart types to Kotlin types:

| Dart | Kotlin |
|------|--------|
| `String` | `String` |
| `int` | `Int` |
| `double` | `Double` |
| `bool` | `Boolean` |
| `List<T>` | `List<T>` |
| `Map<K, V>` | `Map<K, V>` |
| `Future<T>` | Async method returning `T` |
| `Stream<T>` | EventChannel emitting `T` |

### Custom Type Mapping

Define custom mappings in your contract:

```dart
@NativeBridge(
  typeMapping: {
    'DateTime': 'Long',
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
4. **Document complex logic** — Add comments to non-obvious implementations
5. **Test with MockBridgeTransport first** — Verify logic before native platform

## Testing

Unit test your bridge before running on Android:

```dart
test('getModel returns device model', () async {
  final transport = MockBridgeTransport();
  transport.stubMethodValue('getModel', 'Pixel 6');

  final bridge = DeviceBridgeImpl(transport);
  expect(await bridge.getModel(), 'Pixel 6');
});
```

For integration testing on real Android, see [Testing Guide](../docs/testing-guide.md).

## Troubleshooting

**Generator not running?**
- Ensure `native_bridge_kit_android_gen` is in `dev_dependencies`
- Run `flutter pub get && flutter pub run build_runner clean && flutter pub run build_runner build`

**Type mismatch errors?**
- Check that your Kotlin handler types match the Dart contract
- Use custom type mapping for non-standard types

**USER CODE blocks disappeared?**
- Make sure to use exact `BEGIN_USER_CODE` / `END_USER_CODE` markers
- Don't modify the marker text

## Performance Notes

- Generated code uses MethodChannel/EventChannel for communication
- No reflection — fully type-safe and efficient
- Minimal overhead — pure method dispatch

## API Reference

For complete API details, see [API Reference Guide](../docs/api-reference.md).

## Next Steps

- **Getting Started?** See [Getting Started Guide](../docs/getting-started.md)
- **iOS too?** See [native_bridge_kit_ios_gen](../packages/native_bridge_kit_ios_gen/README.md)
- **CLI Tools?** See [native_bridge_kit_cli](../packages/native_bridge_kit_cli/README.md) for drift-check
- **Examples?** See [Example Project](../examples/device-info-app)

---

[← Back to Root README](../README.md)
