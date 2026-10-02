# Device Info Example App

A complete, runnable Flutter example demonstrating native_bridge_kit with full Android and iOS support, unit tests, and integration tests.

## Overview

This example app shows:
- ✓ Dart bridge contract definition (@NativeBridge)
- ✓ Android Kotlin handler implementation
- ✓ iOS Swift handler implementation
- ✓ Unit tests using MockBridgeTransport (no native platform needed)
- ✓ Integration tests on real device/simulator
- ✓ Real app with UI showing device info and battery level updates

## Project Structure

```
device-info-app/
├── lib/
│   ├── main.dart                          # Main Flutter app
│   └── native/
│       └── device_info_bridge.dart        # Dart contract (single source of truth)
├── android/
│   └── app/src/main/kotlin/.../
│       └── DeviceInfoBridgeHandler.kt     # Android Kotlin handler
├── ios/
│   └── Runner/
│       └── DeviceInfoBridgeHandler.swift  # iOS Swift handler
├── test/
│   └── device_info_bridge_test.dart       # Unit tests (12 test cases)
├── integration_test/
│   └── device_info_test.dart              # Integration tests
└── pubspec.yaml
```

## Getting Started

### Prerequisites

- Flutter 3.0+ and Dart 3.0+
- Android Studio with Kotlin support
- Xcode with Swift support (for iOS)

### Setup

```bash
# Get dependencies
flutter pub get

# Generate code
flutter pub run build_runner build

# Run unit tests (no platform needed)
flutter test

# Run on device/simulator
flutter run
```

> **Note**: `pubspec.yaml` uses the 2-import pattern — `native_bridge_kit` (runtime + annotations)
> and `native_bridge_kit_gen` (all generators). No need to add platform generators separately.

## Running Tests

### Unit Tests (Pure Dart, no native platform)

```bash
flutter test

# Output:
# ✓ DeviceInfoBridge › getModel returns expected device name
# ✓ DeviceInfoBridge › getModel throws error when unavailable
# ✓ DeviceInfoBridge › getManufacturer returns manufacturer name
# ✓ DeviceInfoBridge › getBatteryLevel returns valid percentage
# ✓ DeviceInfoBridge › getBatteryLevel handles edge cases
# ✓ DeviceInfoBridge › batteryUpdates emits multiple values
# ✓ DeviceInfoBridge › batteryUpdates values are in descending order
# ✓ DeviceInfoBridge › batteryUpdates with take(2)
# ✓ DeviceInfoBridge › calls getModel twice
# ✓ DeviceInfoBridge › inspect method invocations
# ✓ DeviceInfoBridge › batteryUpdates emits error
# ✓ DeviceInfoBridge › call getModel and getBatteryLevel together
#
# 12 tests passed (< 1 second)
```

### Integration Tests (On real device/simulator)

```bash
# On Android emulator or device
flutter test integration_test/

# On iOS simulator or device
flutter test -d <device_id> integration_test/
```

## What This Example Demonstrates

### 1. Dart Contract (Single Source of Truth)

See `lib/native/device_info_bridge.dart`:

```dart
@NativeBridge()
abstract class DeviceInfoBridge {
  @NativeMethod()
  Future<String> getModel();

  @NativeMethod()
  Future<String> getManufacturer();

  @NativeMethod()
  Future<int> getBatteryLevel();

  @NativeStream()
  Stream<int> get batteryUpdates;
}
```

This is the single source of truth. Run `flutter pub run build_runner build` to generate:
- Dart implementation
- Kotlin Android handler stubs
- Swift iOS handler stubs

### 2. Android Handler

See `android/app/src/main/kotlin/.../DeviceInfoBridgeHandler.kt`:

```kotlin
class DeviceInfoBridgeHandler(private val context: Context) {
  fun getModel(): String {
    // BEGIN_USER_CODE
    return Build.MODEL
    // END_USER_CODE
  }

  // ... more methods
}
```

Your implementation goes between `BEGIN_USER_CODE` / `END_USER_CODE` markers. These are preserved across regenerations.

### 3. iOS Handler

See `ios/Runner/DeviceInfoBridgeHandler.swift`:

```swift
class DeviceInfoBridgeHandler {
  func getModel() -> String {
    // MARK: - BEGIN USER CODE
    return UIDevice.current.model
    // MARK: - END USER CODE
  }

  // ... more methods
}
```

Same pattern: your code between markers is preserved across regenerations.

### 4. Unit Tests with MockBridgeTransport

See `test/device_info_bridge_test.dart`:

```dart
test('getModel returns expected device name', () async {
  final transport = MockBridgeTransport();
  transport.stubMethodValue('getModel', 'Pixel 6');

  final bridge = DeviceInfoBridgeImpl(transport);
  expect(await bridge.getModel(), 'Pixel 6');
});
```

Tests run with `flutter test` **without requiring native platform**. Perfect for CI/CD.

### 5. Real App

See `lib/main.dart`:

- Fetches device info on startup
- Displays model, manufacturer, battery level
- Listens to battery level stream updates
- Shows loading/error states
- Includes refresh button

## Key Learnings

1. **One contract, three implementations**
   - Dart: Generated from contract
   - Kotlin: Generated stubs you fill in
   - Swift: Generated stubs you fill in

2. **Unit testing is pure Dart**
   - No Android emulator needed
   - No iOS simulator needed
   - Tests run in < 1 second

3. **Handlers are simple**
   - Just fill in the generated stubs
   - Your code survives regenerations
   - Type-safe throughout

4. **Maintenance is low**
   - Change contract → regenerate → update handlers
   - Drift-check validates sync
   - All logic in one place

## Common Tasks

### Add a new method

1. **Update contract** (`lib/native/device_info_bridge.dart`):
   ```dart
   @NativeMethod()
   Future<bool> isEmulator();
   ```

2. **Regenerate**:
   ```bash
   flutter pub run build_runner build
   ```

3. **Implement Android** (`DeviceInfoBridgeHandler.kt`):
   ```kotlin
   fun isEmulator(): Boolean {
     // BEGIN_USER_CODE
     return Build.FINGERPRINT.contains("generic")
     // END_USER_CODE
   }
   ```

4. **Implement iOS** (`DeviceInfoBridgeHandler.swift`):
   ```swift
   func isEmulator() -> Bool {
     // MARK: - BEGIN USER CODE
     return ProcessInfo.processInfo.environment["SIMULATOR_UDID"] != nil
     // MARK: - END USER CODE
   }
   ```

5. **Write test** (`test/device_info_bridge_test.dart`):
   ```dart
   test('isEmulator returns boolean', () async {
     transport.stubMethodValue('isEmulator', false);

     final result = await bridge.isEmulator();
     expect(result, isFalse);
   });
   ```

### Test a method

1. **Write unit test** (runs instantly, no platform):
   ```dart
   flutter test
   ```

2. **Write integration test** (for real platform behavior):
   ```dart
   flutter test integration_test/
   ```

### Check contract-handler sync

```bash
# From project root
dart run native_bridge_kit_cli:drift_check
```

## Troubleshooting

### "Generated file not found"

```bash
flutter pub run build_runner clean
flutter pub run build_runner build
```

### "Android compilation error"

Check `DeviceInfoBridgeHandler.kt` - ensure you only edited between markers.

### "iOS compilation error"

Check `DeviceInfoBridgeHandler.swift` - ensure you only edited between markers.

### "Test fails"

1. Check `test/device_info_bridge_test.dart` for the test case
2. Ensure stubs are set up before calling methods
3. Verify expected vs actual values

---

## Next Steps

- **[Getting Started Guide](../../docs/getting-started.md)** — Build your own bridge
- **[Testing Guide](../../docs/testing-guide.md)** — Advanced testing patterns
- **[Root README](../../README.md)** — Full documentation

---

**Learn by doing!** Copy this example and modify it for your own use cases.
