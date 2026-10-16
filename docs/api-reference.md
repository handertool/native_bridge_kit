# API Reference Guide

Complete API documentation for all native_bridge_kit components and APIs.

## Table of Contents

1. [Annotations](#annotations)
2. [Supported Contract Types](#supported-contract-types)
3. [MockBridgeTransport](#mockbridgetransport)
4. [drift-check CLI](#drift-check-cli)
5. [Error Codes](#error-codes)

---

## Annotations

### @NativeBridge()

Marks a Dart class as a native bridge contract.

```dart
@NativeBridge()
abstract class MyBridge {
  // Define your methods here
}
```

The optional `channelPrefix` parameter sets the base method-channel name.
Without it, the generator derives the prefix from the bridge class name in
`snake_case`.

---

### @NativeMethod()

Optionally marks a `Future<T>` method and overrides its wire name. Generated
one-shot methods must return `Future<T>` and may use named parameters only.
Synchronous and `void` methods are not supported.

```dart
@NativeBridge()
abstract class DeviceBridge {
  @NativeMethod(name: 'device_model')
  Future<String> getModel();

  Future<void> vibrate({required int durationMs});

  @NativeMethod()
  Future<Map<String, dynamic>> getDeviceInfo();
}
```

---

### @NativeStream()

Marks a parameterless `Stream<T>` method as an event stream and optionally
overrides its event-channel suffix. Stream parameters are not supported because
the transport cannot currently pass arguments when subscribing.

```dart
@NativeStream(name: 'sensor-events')
Stream<int> updates();
```

**Examples:**

```dart
@NativeBridge()
abstract class SensorBridge {
  // Simple stream
  @NativeStream()
  Stream<int> accelerometerEvents();

  // Stream of complex objects
  @NativeStream()
  Stream<Map<String, dynamic>> locationUpdates();

  // Stream of multiple events
  @NativeStream()
  Stream<List<int>> multiSensorData();
}
```

---

## Supported Contract Types

The generators support standard message-codec values and collections composed
of those values. Custom Dart objects need application-defined serialization
before they cross the platform channel; the annotations do not define custom
native type mappings.

| Dart | Kotlin | Swift | Example |
|------|--------|-------|---------|
| `String` | `String` | `String` | `"hello"` |
| `int` | `Int` | `Int` | `42` |
| `double` | `Double` | `Double` | `3.14` |
| `bool` | `Boolean` | `Bool` | `true` |
| `List<T>` | `List<T>` | `[T]` | `[1, 2, 3]` |
| `Map<K, V>` | `Map<K, V>` | `[K: V]` | `{"key": "value"}` |
| `Future<T>` | Async `T` | Async `T` | — |
| `Stream<T>` | `EventSink<T>` | `FlutterEventSink` | — |

---

## MockBridgeTransport

Complete API for unit testing bridge code without requiring native platform compilation.

### Basic Usage

```dart
import 'package:native_bridge_kit/native_bridge_kit.dart';

test('example', () {
  final transport = MockBridgeTransport();
  // Configure stubs
  // Use bridge
  // Assert
});
```

### Method Stubbing

#### `stubMethod(channel, method, result)`

```dart
transport.stubMethod('device', 'getModel', 'Pixel 6');
```

#### `stubMethodValue<T>(method, value)`

```dart
transport.stubMethodValue('getModel', 'Pixel 6');
transport.stubMethodValue('getBatteryLevel', 85);
```

**Examples:**

```dart
test('getModel returns device model', () async {
  final transport = MockBridgeTransport();
  transport.stubMethodValue('getModel', 'iPhone 13');

  final bridge = MyBridgeImpl(transport);
  expect(await bridge.getModel(), 'iPhone 13');
});

test('complex return type', () async {
  final transport = MockBridgeTransport();
  transport.stubMethodValue('getInfo', {
    'model': 'Pixel 6',
    'os': 'Android',
    'version': 13,
  });

  final bridge = MyBridgeImpl(transport);
  final info = await bridge.getInfo();
  expect(info['model'], 'Pixel 6');
});
```

#### `stubMethodError(method, code, [message])`

```dart
transport.stubMethodError('getModel', 'DEVICE_ERROR', 'Failed to get model');
```

**Example:**

```dart
test('handles errors', () async {
  final transport = MockBridgeTransport();
  transport.stubMethodError('getModel', 'DEVICE_ERROR');

  final bridge = MyBridgeImpl(transport);

  expect(
    bridge.getModel(),
    throwsA(isA<PlatformException>()),
  );
});
```

### Stream Stubbing

#### `stubStreamValue<T>(stream, value)`

```dart
transport.stubStreamValue('updates', 42);
```

#### `stubStreamValues<T>(stream, values)`

```dart
transport.stubStreamValues('updates', [1, 2, 3, 4, 5]);
```

**Examples:**

```dart
test('stream emits multiple values', () async {
  final transport = MockBridgeTransport();
  transport.stubStreamValues('batteryUpdates', [100, 95, 90, 85]);

  final bridge = MyBridgeImpl(transport);
  final values = await bridge.batteryUpdates.toList();

  expect(values, equals([100, 95, 90, 85]));
});
```

#### `stubStreamError(stream, code, [message])`

```dart
transport.stubStreamError('updates', 'STREAM_ERROR');
```

**Example:**

```dart
test('stream emits error', () async {
  final transport = MockBridgeTransport();
  transport.stubStreamError('updates', 'STREAM_ERROR');

  final bridge = MyBridgeImpl(transport);

  expect(
    bridge.batteryUpdates.first,
    throwsException,
  );
});
```

### Invocation Capture

#### `captureInvocations()`

Enable invocation recording:

```dart
transport.captureInvocations();
```

#### `getInvocations()`

Get all captured invocations:

```dart
final invocations = transport.getInvocations();
// Returns List<CapturedInvocation>
```

#### `getInvocationsFor(method)`

Get invocations for a specific method:

```dart
final modelCalls = transport.getInvocationsFor('getModel');
```

#### `verifyMethodCalled(method)`

Verify a method was called at least once:

```dart
transport.verifyMethodCalled('getModel');
// Throws if not called
```

#### `verifyMethodCalledTimes(method, times)`

Verify a method was called exactly N times:

```dart
transport.verifyMethodCalledTimes('getModel', 3);
```

#### `clearInvocations()`

Clear captured invocations:

```dart
transport.clearInvocations();
```

**Examples:**

```dart
test('method call verification', () async {
  final transport = MockBridgeTransport();
  transport.stubMethodValue('getModel', 'Pixel 6');
  transport.captureInvocations();

  final bridge = MyBridgeImpl(transport);

  await bridge.getModel();
  await bridge.getModel();

  transport.verifyMethodCalled('getModel');
  transport.verifyMethodCalledTimes('getModel', 2);

  final invocations = transport.getInvocationsFor('getModel');
  expect(invocations.length, 2);
});
```

---

## drift-check CLI

Command-line tool for detecting contract-handler drift.

### Usage

```bash
dart run native_bridge_kit_cli:drift_check [options]
```

### Options

```
--platform <platform>      Platform: android, ios, or all (default: all)
--contract <path>          Path to Dart contract file
--handler <path>           Path to Kotlin/Swift handler file
--json                     Output as JSON (default: human-readable)
--fail-on-drift            Exit code 1 if drift detected
--help                     Show help message
```

### Examples

```bash
# Check both platforms
dart run native_bridge_kit_cli:drift_check

# Check only Android
dart run native_bridge_kit_cli:drift_check --platform android

# JSON output for CI/CD
dart run native_bridge_kit_cli:drift_check --json --fail-on-drift

# Specify custom paths
dart run native_bridge_kit_cli:drift_check \
  --contract lib/native/my_bridge.dart \
  --handler android/app/src/main/kotlin/.../MyHandler.kt
```

### JSON Output Format

```json
{
  "in_sync": true,
  "issues": [],
  "summary": {
    "total_methods": 5,
    "android_methods": 5,
    "ios_methods": 5,
    "status": "OK"
  }
}
```

**With drift:**

```json
{
  "in_sync": false,
  "issue_count": 2,
  "issues": [
    {
      "type": "missing_operation",
      "platform": "android",
      "method": "new_method",
      "message": "Method \"new_method\" is missing in android handler",
      "details": null
    },
    {
      "type": "operation_kind_mismatch",
      "platform": "ios",
      "method": "battery_level",
      "message": "Operation \"battery_level\" is a stream in the Dart contract but a method in the ios handler",
      "details": null
    }
  ]
}
```

Drift-check compares exact wire names and whether each operation is a method or
stream. It does not validate parameter names, parameter types, or return types.
Explicit `@NativeMethod(name: ...)` and `@NativeStream(name: ...)` overrides
are included in the comparison.

---

## Error Codes

Common error codes thrown by native handlers.

### Standard Error Codes

| Code | Meaning | Usual Cause |
|------|---------|-----------|
| `PLATFORM_CHANNEL_ERROR` | Channel communication failed | Bridge misconfiguration |
| `METHOD_NOT_FOUND` | Method doesn't exist on handler | Contract-handler mismatch |
| `INVALID_ARGUMENT` | Parameter type mismatch | Wrong parameter type passed |
| `IO_ERROR` | File/resource access failed | Permissions or missing resource |
| `TIMEOUT_ERROR` | Operation exceeded timeout | Long-running operation |
| `PERMISSION_DENIED` | Permission not granted | Missing Android/iOS permission |
| `NOT_SUPPORTED` | Operation not supported | Platform limitation |

### Custom Error Codes

Define custom error codes in your handlers:

**Kotlin:**
```kotlin
result.error("DEVICE_ERROR", "Device info unavailable", null)
```

**Swift:**
```swift
result(FlutterError(
  code: "DEVICE_ERROR",
  message: "Device info unavailable",
  details: nil
))
```

**Dart:**
```dart
try {
  await bridge.getDeviceInfo();
} catch (e) {
  if (e is PlatformException) {
    if (e.code == 'DEVICE_ERROR') {
      // Handle specific error
    }
  }
}
```

---

## Next Steps

- **[Getting Started](getting-started.md)** — Build your first bridge
- **[Testing Guide](testing-guide.md)** — Advanced testing patterns
- **[Troubleshooting](troubleshooting.md)** — Common issues

---

**[← Back to Root README](../README.md)**
