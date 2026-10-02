# Migrate from Manual MethodChannel

Step-by-step guide to migrating from manual MethodChannel implementation to native_bridge_kit.

## Before and After Comparison

### ❌ Manual MethodChannel Approach

**Dart code:**
```dart
const platform = MethodChannel('com.example.app/device');

class DeviceInfo {
  Future<String> getModel() async {
    try {
      final result = await platform.invokeMethod('getModel');
      return result as String;
    } catch (e) {
      throw Exception('Failed to get model: $e');
    }
  }

  Future<int> getBatteryLevel() async {
    try {
      final result = await platform.invokeMethod('getBatteryLevel');
      return result as int;
    } catch (e) {
      throw Exception('Failed to get battery: $e');
    }
  }
}
```

**Android Kotlin:**
```kotlin
class MainActivity: FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.example.app/device")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getModel" -> result.success(Build.MODEL)
          "getBatteryLevel" -> result.success(getBatteryLevel())
          else -> result.notImplemented()
        }
      }
  }

  private fun getBatteryLevel(): Int {
    // Implementation
    return 50
  }
}
```

### ✅ native_bridge_kit Approach

**Dart contract (single source of truth):**
```dart
@NativeBridge()
abstract class DeviceBridge {
  Future<String> getModel();
  Future<int> getBatteryLevel();
}
```

**Generate:** `flutter pub run build_runner build`

**Android Kotlin:** Fill in generated stubs
```kotlin
class DeviceBridgeHandler(private val context: Context) {
  fun getModel(): String {
    // BEGIN_USER_CODE
    return Build.MODEL
    // END_USER_CODE
  }

  fun getBatteryLevel(): Int {
    // BEGIN_USER_CODE
    return 50
    // END_USER_CODE
  }
}
```

## Migration Steps

### Step 1: Add native_bridge_kit Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  native_bridge_kit_annotation: ^0.1.0
  native_bridge_kit: ^0.1.0

dev_dependencies:
  build_runner: ^2.4.0
  native_bridge_kit_gen: ^0.1.0
  native_bridge_kit_android_gen: ^0.1.0
  native_bridge_kit_ios_gen: ^0.1.0
```

```bash
flutter pub get
```

### Step 2: Create Dart Contract

Create `lib/native/device_bridge.dart`:

```dart
import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';

part 'device_bridge.g.dart';

@NativeBridge()
abstract class DeviceBridge {
  Future<String> getModel();
  Future<int> getBatteryLevel();
}
```

### Step 3: Generate Code

```bash
flutter pub run build_runner build
```

Creates:
- `device_bridge.g.dart` — Dart implementation
- `DeviceBridgeHandler.g.kt` — Android Kotlin stubs
- `DeviceBridgeHandler.g.swift` — iOS Swift stubs

### Step 4: Replace Dart Code

Remove manual `DeviceInfo` class and use generated:

```dart
// OLD: const platform = MethodChannel(...);
// OLD: class DeviceInfo { ... }

// NEW: Use generated implementation
import 'package:my_app/native/device_bridge.g.dart';

// In your widget
final bridge = DeviceBridgeImpl(MethodChannelTransport());
final model = await bridge.getModel();
```

### Step 5: Replace Android Handler

Update `MainActivity.kt`:

```kotlin
// OLD: MethodChannel setup with string method names
// NEW: Use generated handler

class MainActivity: FlutterActivity() {
  private val handler = DeviceBridgeHandler(this)

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    // Handler is auto-registered by generated code
  }
}
```

Fill in `DeviceBridgeHandler.kt` between markers:

```kotlin
class DeviceBridgeHandler(private val context: Context) {
  fun getModel(): String {
    // BEGIN_USER_CODE
    return Build.MODEL
    // END_USER_CODE
  }

  fun getBatteryLevel(): Int {
    // BEGIN_USER_CODE
    val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
    return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CHARGE_COUNTER)
    // END_USER_CODE
  }
}
```

### Step 6: Replace iOS Handler

Update `ios/Runner/DeviceBridgeHandler.swift`:

```swift
class DeviceBridgeHandler {
  func getModel() -> String {
    // MARK: - BEGIN USER CODE
    return UIDevice.current.model
    // MARK: - END USER CODE
  }

  func getBatteryLevel() -> Int {
    // MARK: - BEGIN USER CODE
    UIDevice.current.isBatteryMonitoringEnabled = true
    return max(0, Int(UIDevice.current.batteryLevel * 100))
    // MARK: - END USER CODE
  }
}
```

### Step 7: Update Tests

Convert tests from integration to unit tests:

**OLD (Integration only):**
```dart
// Had to test on device/simulator
testWidgets('get model', (WidgetTester tester) async {
  // Required emulator running
});
```

**NEW (Pure unit test):**
```dart
test('get model', () async {
  final transport = MockBridgeTransport();
  transport.stubMethodValue('getModel', 'Pixel 6');

  final bridge = DeviceBridgeImpl(transport);
  expect(await bridge.getModel(), 'Pixel 6');
});
```

Run tests without native platform:
```bash
flutter test  # Works! No emulator needed
```

### Step 8: Verify Migration

```bash
# Ensure code compiles
flutter pub run build_runner build

# Run tests
flutter test

# Check drift
dart run native_bridge_kit_cli:drift_check

# Build and test on device
flutter run
```

---

## Benefits of Migration

| Aspect | Manual | native_bridge_kit |
|--------|--------|---------------|
| Code Duplication | ❌ High | ✅ None |
| Type Safety | ❌ Strings | ✅ Full Types |
| Unit Testing | ❌ Integration only | ✅ Pure Dart |
| Maintenance | ❌ High (3 places) | ✅ Low (1 place) |
| Sync Validation | ❌ Manual | ✅ Automated (drift-check) |
| Learning Curve | ❌ High | ✅ Low |

---

## Common Gotchas

### 1. Method Names Must Match

```dart
// Contract
@NativeMethod()
Future<String> getModel();

// Kotlin handler must be named 'getModel'
// NOT 'model()' or 'get_model()'
fun getModel(): String { ... }
```

### 2. Type Mapping Matters

```dart
// If parameters don't align, use type mapping
@NativeBridge(typeMapping: {'DateTime': 'Long'})
abstract class MyBridge {
  Future<void> save(DateTime date);
}

// Kotlin handler receives Long (milliseconds)
fun save(dateMs: Long) { ... }
```

### 3. Error Codes Must Match

Ensure error handling is consistent:

```kotlin
// Kotlin
result.error("DEVICE_ERROR", "Failed", null)

// Dart
try {
  await bridge.getModel();
} catch (e) {
  if (e is PlatformException && e.code == 'DEVICE_ERROR') {
    // Handle
  }
}
```

### 4. USER CODE Blocks Are Sacred

Don't modify the markers:

```kotlin
// ✅ CORRECT
// BEGIN_USER_CODE
return Build.MODEL
// END_USER_CODE

// ❌ WRONG - markers removed
return Build.MODEL
```

---

## Gradual Migration

You don't have to migrate everything at once:

```dart
class MyApp {
  late DeviceBridge _deviceBridge;  // NEW: native_bridge_kit
  late MethodChannel _platform;      // OLD: manual

  Future<void> init() async {
    _deviceBridge = DeviceBridgeImpl(MethodChannelTransport());
    _platform = MethodChannel('com.example.app/sensor');
  }

  // NEW: Use native_bridge_kit
  Future<String> getModel() => _deviceBridge.getModel();

  // OLD: Use manual
  Future<int> getSensorData() => _platform.invokeMethod('getSensor');
}
```

Migrate piece-by-piece and verify each step works.

---

## Next Steps

- **[Getting Started](getting-started.md)** — New to native_bridge_kit?
- **[Testing Guide](testing-guide.md)** — Unit testing with MockBridgeTransport
- **[Troubleshooting](troubleshooting.md)** — Common issues

---

**[← Back to Root README](../README.md)**
