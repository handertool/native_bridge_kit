# Troubleshooting Guide

Solutions for common issues and frequently asked questions when working with native_bridge_kit.

## Installation & Setup

### build_runner doesn't generate code

**Error:** Generated `.g.dart` files don't appear after running `flutter pub run build_runner build`

**Causes:**
1. Missing dependencies in `dev_dependencies`
2. Generator packages not properly configured
3. Stale build cache

**Solutions:**

```bash
# 1. Ensure all dependencies are present
flutter pub get

# 2. Clean build cache
flutter pub run build_runner clean

# 3. Run build_runner again
flutter pub run build_runner build

# 4. If still not working, check pubspec.yaml has:
# dev_dependencies:
#   build_runner: ^2.4.0
#   native_bridge_kit_gen: ^0.1.0
#   native_bridge_kit_android_gen: ^0.1.0
#   native_bridge_kit_ios_gen: ^0.1.0
```

### "Generator for annotation NativeBridge not found"

**Error:** Build runner can't find the `@NativeBridge()` annotation

**Cause:** Generator package not in dev_dependencies

**Solution:**

```yaml
dev_dependencies:
  native_bridge_kit_gen: ^0.1.0
```

Then:
```bash
flutter pub get
flutter pub run build_runner build
```

### "part directive not found"

**Error:** Compiler says `part 'file.g.dart'` doesn't exist

**Cause:** Generated file hasn't been created yet

**Solution:**

```bash
# First: Create your contract file
# lib/native/my_bridge.dart
import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';

part 'my_bridge.g.dart';  # ← This file doesn't exist yet

@NativeBridge()
abstract class MyBridge {
  // ...
}

# Then: Generate it
flutter pub run build_runner build
```

---

## Android Compilation

### "Kotlin compiler error" in generated code

**Error:** Android build fails with Kotlin syntax errors

**Cause:** Type mismatch or version incompatibility

**Solution:**

```bash
# 1. Check your Dart contract types are valid
# 2. Verify type mapping matches handler signatures
# 3. Update Kotlin version in android/build.gradle.kts

android {
  kotlinOptions {
    jvmTarget = "17"
  }
}

# 4. Clean and rebuild
./gradlew clean
flutter pub run build_runner build
flutter build apk --debug
```

### "MethodChannel not found" error

**Error:** Generated handler can't access MethodChannel

**Cause:** Missing Flutter/platform channel imports

**Solution:** Generated code includes imports automatically. Verify:

```kotlin
// Should be present in generated DeviceBridgeHandler.g.kt
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
```

### "Handler method signature mismatch"

**Error:** Generated method signature doesn't match implementation

**Cause:** Edited the generated code outside USER CODE blocks

**Solution:** Don't edit generated code. Only modify between markers:

```kotlin
// ✅ CORRECT
// BEGIN_USER_CODE
return Build.MODEL
// END_USER_CODE

// ❌ WRONG - editing generated code
private fun getModel(): String {  // ← Don't edit this line
  return Build.MODEL
}
```

---

## iOS Compilation

### "Swift compiler error" in generated code

**Error:** Xcode build fails with Swift syntax errors

**Cause:** Type mismatch or Swift version incompatibility

**Solution:**

```bash
# 1. Update Xcode to latest version
softwareupdate -i -a

# 2. Verify Swift version
xcrun swift --version

# 3. Update deployment target in Xcode
# iOS 12.0+

# 4. Clean and rebuild
flutter clean
flutter pub run build_runner build
flutter build ios --debug
```

### "FlutterMethodChannel not found"

**Error:** Swift can't find FlutterMethodChannel

**Cause:** Missing Flutter framework import

**Solution:** Generated code includes imports. Verify pod dependencies:

```bash
cd ios
pod install
cd ..
```

### "Bridging header issues"

**Error:** Can't access Kotlin/Swift from Flutter

**Solution:** Run a clean build:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build
flutter build ios
```

---

## Code Generation

### "drift-check: contract file not found"

**Error:** drift-check can't locate your Dart contract

**Cause:** Non-standard file naming or location

**Solution:**

```bash
# Option 1: Use default naming (best)
# File: lib/native/*_bridge.dart
flutter pub run build_runner build
dart run native_bridge_kit_cli:drift_check

# Option 2: Specify path explicitly
dart run native_bridge_kit_cli:drift_check \
  --contract lib/native/device_bridge.dart

# Option 3: Update handler paths
dart run native_bridge_kit_cli:drift_check \
  --contract lib/native/device_bridge.dart \
  --handler android/app/src/main/kotlin/.../DeviceBridgeHandler.kt
```

### "drift-check: no handlers found"

**Error:** drift-check can't locate native handlers

**Cause:** Non-standard directory structure

**Solution:**

```bash
# Ensure handlers are in expected paths:
# Android: android/app/src/main/kotlin/com/example/app/DeviceHandler.kt
# iOS: ios/Runner/DeviceHandler.swift

# Or specify custom paths:
dart run native_bridge_kit_cli:drift_check \
  --handler android/app/.../MyHandler.kt
```

### "drift-check: method mismatch"

**Error:** Contract and handlers are out of sync

**Cause:** Added method to contract but didn't implement in handlers

**Solution:**

```bash
# 1. Check what's missing
dart run native_bridge_kit_cli:drift_check --json

# 2. Add missing methods to handlers
# 3. Or revert contract changes
# 4. Verify sync
dart run native_bridge_kit_cli:drift_check
```

---

## Testing

### "MockBridgeTransport not found"

**Error:** Can't import MockBridgeTransport

**Cause:** Missing dependency

**Solution:**

```yaml
dependencies:
  native_bridge_kit: ^0.1.0
```

```dart
import 'package:native_bridge_kit/native_bridge_kit.dart';

final transport = MockBridgeTransport();
```

### "Test fails: no stub registered"

**Error:** `NoSuchMethodError: no stub registered for method getModel`

**Cause:** Didn't set up mock before calling method

**Solution:**

```dart
test('example', () async {
  final transport = MockBridgeTransport();

  // ✅ CORRECT - set up stub before use
  transport.stubMethodValue('getModel', 'Pixel 6');

  final bridge = DeviceBridgeImpl(transport);
  final model = await bridge.getModel();

  expect(model, 'Pixel 6');
});
```

### "Test flakes intermittently"

**Error:** Test passes sometimes, fails other times

**Cause:** Stream ordering or timing issues

**Solution:**

```dart
// Use deterministic stubs
test('deterministic stream', () async {
  final transport = MockBridgeTransport();

  // Provide exact sequence, not random
  transport.stubStreamValues('events', [1, 2, 3]);

  final bridge = MyBridgeImpl(transport);
  final events = await bridge.events.toList();

  expect(events, equals([1, 2, 3]));
});
```

---

## Type Mismatches

### "Type mismatch: expected String, got int"

**Error:** Parameter type doesn't match between contract and handler

**Cause:** Wrong type in contract or handler

**Solution:**

```dart
// Contract
@NativeBridge()
abstract class MyBridge {
  Future<void> save(String filePath);  // ← Expects String
}

// Handler
fun save(filePath: String) {  // ← Must be String
  // ...
}
```

### "List/Map type mismatch"

**Error:** Collection types don't align

**Cause:** Incompatible generic parameters

**Solution:**

```dart
// Contract
Future<Map<String, int>> getData();

// Handler (Kotlin)
fun getData(): Map<String, Int> {
  return mapOf("count" to 42)
}

// Handler (Swift)
func getData() -> [String: Int] {
  return ["count": 42]
}
```

### "Custom type not mapped"

**Error:** Can't convert between Dart and platform type

**Cause:** No type mapping provided

**Solution:**

```dart
// Add type mapping to contract
@NativeBridge(
  typeMapping: {
    'DateTime': 'Long',
    'Uri': 'String',
    'File': 'String',
  }
)
abstract class MyBridge {
  Future<void> save(File file, DateTime date);
}

// Handler receives mapped types
fun save(filePath: String, dateMs: Long) {
  val file = java.io.File(filePath)
  val date = java.util.Date(dateMs)
}
```

---

## Common Questions (FAQ)

### Q: Can I unit test without MockBridgeTransport?

**A:** Yes, but not recommended. Integration tests are slower and harder to debug. Use MockBridgeTransport for unit tests, integration tests for platform-specific behavior.

### Q: How do I test real platform behavior?

**A:** Use integration tests:

```dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('real device test', (WidgetTester tester) async {
    final bridge = DeviceBridgeImpl(MethodChannelTransport());
    final model = await bridge.getModel();
    expect(model.isNotEmpty, true);
  });
}
```

### Q: When should I use custom type mapping?

**A:** When your Dart types don't directly map to platform types:
- `DateTime` → Unix timestamp (long)
- `Uri` → String path
- Custom classes → JSON strings

### Q: Can I have both manual MethodChannel and native_bridge_kit?

**A:** Yes. Use both during migration. Each handles different bridges.

### Q: How do I debug generated code?

**A:** Look at the `.g.dart` files:
- `lib/native/my_bridge.g.dart` — Dart implementation
- `DeviceHandler.g.kt` — Android implementation
- `DeviceHandler.g.swift` — iOS implementation

### Q: Should I commit generated files?

**A:** Yes. They're part of your project.

### Q: How do I update a bridge contract?

**A:**
1. Edit contract in Dart
2. Run `flutter pub run build_runner build`
3. Update handlers to match new methods
4. Run tests and drift-check

### Q: Can I make methods optional?

**A:** Yes, but implement in all handlers:

```dart
@NativeMethod()
Future<String?>? getOptionalValue();  // Can return null
```

### Q: How do I handle platform-specific features?

**A:** Use `@NativeMethod()` only on contract, implement differently in handlers:

```dart
@NativeBridge()
abstract class PlatformBridge {
  Future<void> openFile(String path);
}

// Android: Use Intent
// iOS: Use UIDocumentPickerViewController
```

### Q: Performance: MockBridgeTransport vs real transport?

**A:** MockBridgeTransport is much faster (microseconds). Use for unit tests. Real MethodChannelTransport incurs platform call overhead (milliseconds).

---

## Getting Help

1. **Check this troubleshooting guide** first
2. **Review [Getting Started](getting-started.md)** for basic setup
3. **See [API Reference](api-reference.md)** for API details
4. **Check [Example Project](../examples/device-info-app)** for working code
5. **File an issue** on GitHub with:
   - Error message
   - Minimal reproducible example
   - Platform and versions

---

**[← Back to Root README](../README.md)**
