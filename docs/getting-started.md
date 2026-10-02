# Getting Started Guide

This guide walks through creating a Dart contract, generating native code, implementing handlers, and writing unit tests.

---

## Step 1: Define Your Bridge Contract

Create a new file `lib/native/device_bridge.dart`:

```dart
import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';

part 'device_bridge.g.dart';

@NativeBridge()
abstract class DeviceBridge {
  /// Get the device model name
  @NativeMethod()
  Future<String> getModel();

  /// Get current battery percentage (0-100)
  @NativeMethod()
  Future<int> getBatteryLevel();

  /// Stream of battery level updates
  @NativeStream()
  Stream<int> get batteryUpdates;
}
```

### ✓ Verification Checkpoint 1

Check that you have:
- [ ] File created at `lib/native/device_bridge.dart`
- [ ] `part 'device_bridge.g.dart';` statement
- [ ] Three methods/streams defined

---

## Step 2: Generate Native Code

Run the code generator:

```bash
flutter pub run build_runner build
```

**What was generated:**

- ✓ `lib/native/device_bridge.g.dart` — Dart implementation (auto-generated, don't edit)
- ✓ `android/app/src/main/kotlin/.../DeviceBridgeHandler.g.kt` — Android Kotlin stubs
- ✓ `ios/Runner/DeviceBridgeHandler.g.swift` — iOS Swift stubs

### ✓ Verification Checkpoint 2

Run:
```bash
ls lib/native/device_bridge.g.dart
```

Should show: `device_bridge.g.dart` exists ✓

---

## Step 3: Implement Android Handler

Create or update `android/app/src/main/kotlin/com/example/app/DeviceBridgeHandler.kt`:

```kotlin
import android.content.Context
import android.os.Build
import android.os.BatteryManager
import android.content.IntentFilter
import android.content.Intent
import kotlin.math.roundToInt

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

  fun onBatteryUpdatesListen(sink: io.flutter.embedding.engine.FlutterEngine.EventChannel.EventSink) {
    // BEGIN_USER_CODE
    // Emit battery level every 5 seconds
    val handler = android.os.Handler(android.os.Looper.getMainLooper())
    val runnable = object : Runnable {
      override fun run() {
        val level = getBatteryLevel()
        sink.success(level)
        handler.postDelayed(this, 5000)
      }
    }
    handler.post(runnable)
    // END_USER_CODE
  }

  fun onBatteryUpdatesCancel() {
    // BEGIN_USER_CODE
    // Cleanup if needed
    // END_USER_CODE
  }
}
```

### ✓ Verification Checkpoint 3

Check:
- [ ] File exists at `android/app/src/main/kotlin/com/example/app/DeviceBridgeHandler.kt`
- [ ] Three methods with `BEGIN_USER_CODE` / `END_USER_CODE` blocks
- [ ] No syntax errors (should compile)

---

## Step 4: Implement iOS Handler

Create or update `ios/Runner/DeviceBridgeHandler.swift`:

```swift
import UIKit

class DeviceBridgeHandler {

  func getModel() -> String {
    // MARK: - BEGIN USER CODE
    return UIDevice.current.model
    // MARK: - END USER CODE
  }

  func getBatteryLevel() -> Int {
    // MARK: - BEGIN USER CODE
    UIDevice.current.isBatteryMonitoringEnabled = true
    let level = max(0, Int(UIDevice.current.batteryLevel * 100))
    return level
    // MARK: - END USER CODE
  }

  func onBatteryUpdatesListen(sink: FlutterEventSink) {
    // MARK: - BEGIN USER CODE
    // Emit battery level updates
    Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
      UIDevice.current.isBatteryMonitoringEnabled = true
      let level = max(0, Int(UIDevice.current.batteryLevel * 100))
      sink(level)
    }
    // MARK: - END USER CODE
  }

  func onBatteryUpdatesCancel() {
    // MARK: - BEGIN USER CODE
    // Cleanup if needed
    // MARK: - END USER CODE
  }
}
```

### ✓ Verification Checkpoint 4

Check:
- [ ] File exists at `ios/Runner/DeviceBridgeHandler.swift`
- [ ] Three methods with `MARK: - BEGIN USER CODE` blocks
- [ ] No syntax errors (should compile)

---

## Step 5: Write Dart Unit Tests

Create `test/device_bridge_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/native/device_bridge.g.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';

void main() {
  group('DeviceBridge', () {
    test('getModel returns expected device model', () async {
      // Setup mock transport
      final transport = MockBridgeTransport();
      transport.stubMethodValue('getModel', 'Pixel 6');

      // Create bridge instance with mock
      final bridge = DeviceBridgeImpl(transport);

      // Test
      final model = await bridge.getModel();

      // Assert
      expect(model, equals('Pixel 6'));
    });

    test('getBatteryLevel returns valid battery percentage', () async {
      final transport = MockBridgeTransport();
      transport.stubMethodValue('getBatteryLevel', 75);

      final bridge = DeviceBridgeImpl(transport);
      final level = await bridge.getBatteryLevel();

      expect(level, equals(75));
      expect(level, greaterThanOrEqualTo(0));
      expect(level, lessThanOrEqualTo(100));
    });

    test('batteryUpdates emits multiple values', () async {
      final transport = MockBridgeTransport();
      transport.stubStreamValues('batteryUpdates', [100, 95, 90, 85]);

      final bridge = DeviceBridgeImpl(transport);
      final updates = await bridge.batteryUpdates.toList();

      expect(updates, equals([100, 95, 90, 85]));
    });

    test('getBatteryLevel handles errors', () async {
      final transport = MockBridgeTransport();
      transport.stubMethodError('getBatteryLevel', 'BATTERY_ERROR');

      final bridge = DeviceBridgeImpl(transport);

      expect(
        bridge.getBatteryLevel(),
        throwsException,
      );
    });
  });
}
```

### ✓ Verification Checkpoint 5

Run tests:
```bash
flutter test
```

Should show:
```
✓ DeviceBridge › getModel returns expected device model
✓ DeviceBridge › getBatteryLevel returns valid battery percentage
✓ DeviceBridge › batteryUpdates emits multiple values
✓ DeviceBridge › getBatteryLevel handles errors

4 tests passed
```

---

## Step 6: Build and Run

Now connect everything in your app:

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';
import 'native/device_bridge.g.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DeviceBridge _bridge;
  String _model = 'Loading...';
  int _battery = 0;

  @override
  void initState() {
    super.initState();
    // Use real MethodChannelTransport on device
    // Use MockBridgeTransport for testing
    _bridge = DeviceBridgeImpl(MethodChannelTransport());
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final model = await _bridge.getModel();
      final battery = await _bridge.getBatteryLevel();
      setState(() {
        _model = model;
        _battery = battery;
      });
    } catch (e) {
      setState(() {
        _model = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'native_bridge_kit Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Device Info')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Device: $_model'),
              Text('Battery: $_battery%'),
              ElevatedButton(
                onPressed: _loadDeviceInfo,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### ✓ Verification Checkpoint 6

Run the app:
```bash
flutter run
```

Should display:
- ✓ Device model name
- ✓ Battery percentage
- ✓ Refresh button works

---

## 🎉 You're Done!

Congratulations! You've successfully:

✓ Created a Dart bridge contract
✓ Generated native code
✓ Implemented Android and iOS handlers
✓ Written unit tests without native platform
✓ Built and ran a working app

## 🚀 Next Steps

### Ready for more?

- **[Installation Guide](installation.md)** — Platform-specific advanced setup
- **[Testing Guide](testing-guide.md)** — Advanced testing patterns and CI/CD
- **[API Reference](api-reference.md)** — Complete API documentation
- **[Troubleshooting](troubleshooting.md)** — Common issues and solutions
- **[Example Project](../examples/device-info-app)** — Full featured sample

### Quick Reference

**Add new methods to your bridge:**
1. Add method to `DeviceBridge` contract
2. Run `flutter pub run build_runner build`
3. Implement in Kotlin handler
4. Implement in Swift handler
5. Write unit tests
6. Done!

**Common patterns:**

```dart
// One-time data fetch
Future<String> getData();

// Streaming events
Stream<int> get updates;

// With parameters
Future<void> doAction(String name, int value);

// Multiple return values
Future<Map<String, dynamic>> getDetails();
```

---

**[← Back to Root README](../README.md)**
