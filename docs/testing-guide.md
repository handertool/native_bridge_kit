# Testing Guide

Comprehensive guide to testing native_bridge_kit code. Learn unit testing patterns with `MockBridgeTransport`, integration testing on real platforms, and CI/CD integration.

## Unit Testing with MockBridgeTransport

Test your bridge logic without requiring native platform compilation. All tests run pure Dart with `flutter test`.

### Basic Unit Test Pattern

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';
import 'package:my_app/native/device_bridge.g.dart';

void main() {
  group('DeviceBridge', () {
    late MockBridgeTransport transport;
    late DeviceBridge bridge;

    setUp(() {
      transport = MockBridgeTransport();
      bridge = DeviceBridgeImpl(transport);
    });

    test('getModel returns device model', () async {
      transport.stubMethodValue('getModel', 'Pixel 6');

      final model = await bridge.getModel();

      expect(model, equals('Pixel 6'));
    });
  });
}
```

---

## Testing Future Methods

### Successful Response

```dart
test('successful future method call', () async {
  transport.stubMethodValue('getUserName', 'John Doe');

  final name = await bridge.getUserName();

  expect(name, equals('John Doe'));
});
```

### Error Handling

```dart
test('future method throws error', () async {
  transport.stubMethodError('getUserName', 'USER_NOT_FOUND');

  expect(
    () => bridge.getUserName(),
    throwsA(isA<PlatformException>().having(
      (e) => e.code,
      'error code',
      'USER_NOT_FOUND',
    )),
  );
});
```

### Multiple Parameters

```dart
test('method with parameters', () async {
  transport.stubMethodValue('saveUser', null);

  await bridge.saveUser('John', 30);

  transport.verifyMethodCalled('saveUser');
});
```

### Complex Return Types

```dart
test('returns complex object', () async {
  final userData = {
    'id': '123',
    'name': 'John',
    'email': 'john@example.com',
    'age': 30,
  };
  transport.stubMethodValue('getUser', userData);

  final user = await bridge.getUser();

  expect(user['id'], '123');
  expect(user['name'], 'John');
});
```

---

## Testing Stream Methods

### Single Event

```dart
test('stream emits single value', () async {
  transport.stubStreamValue('statusUpdates', 'connected');

  final events = await bridge.statusUpdates.toList();

  expect(events, equals(['connected']));
});
```

### Multiple Events

```dart
test('stream emits multiple events', () async {
  transport.stubStreamValues('batteryUpdates', [100, 95, 90, 85]);

  final levels = await bridge.batteryUpdates.toList();

  expect(levels, equals([100, 95, 90, 85]));
});
```

### Stream Takes/Skips

```dart
test('stream with take operator', () async {
  transport.stubStreamValues('events', [1, 2, 3, 4, 5]);

  final first3 = await bridge.events.take(3).toList();

  expect(first3, equals([1, 2, 3]));
});
```

### Stream Error

```dart
test('stream emits error', () async {
  transport.stubStreamError('events', 'STREAM_ERROR');

  expect(
    () => bridge.events.first,
    throwsException,
  );
});
```

---

## Testing DeviceInfoBridge Complete Example

Full working example with 10+ test cases:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';
import 'package:my_app/native/device_bridge.g.dart';

void main() {
  group('DeviceInfoBridge - Complete Examples', () {
    late MockBridgeTransport transport;
    late DeviceInfoBridge bridge;

    setUp(() {
      transport = MockBridgeTransport();
      bridge = DeviceInfoBridgeImpl(transport);
      transport.captureInvocations();
    });

    // Test 1: Successful model retrieval
    test('getModel returns expected device name', () async {
      transport.stubMethodValue('getModel', 'Pixel 6');

      final model = await bridge.getModel();

      expect(model, equals('Pixel 6'));
      transport.verifyMethodCalled('getModel');
    });

    // Test 2: Model error handling
    test('getModel throws error when unavailable', () async {
      transport.stubMethodError('getModel', 'DEVICE_ERROR');

      expect(
        () => bridge.getModel(),
        throwsA(isA<PlatformException>()),
      );
    });

    // Test 3: Battery level retrieval
    test('getBatteryLevel returns valid percentage', () async {
      transport.stubMethodValue('getBatteryLevel', 75);

      final level = await bridge.getBatteryLevel();

      expect(level, equals(75));
      expect(level, greaterThanOrEqualTo(0));
      expect(level, lessThanOrEqualTo(100));
    });

    // Test 4: Battery boundary values
    test('getBatteryLevel handles edge cases', () async {
      transport.stubMethodValue('getBatteryLevel', 0);
      expect(await bridge.getBatteryLevel(), 0);

      transport.clearInvocations();
      transport.stubMethodValue('getBatteryLevel', 100);
      expect(await bridge.getBatteryLevel(), 100);
    });

    // Test 5: Stream emits multiple battery events
    test('batteryUpdates emits multiple values', () async {
      transport.stubStreamValues('batteryUpdates', [100, 95, 90, 85, 80]);

      final updates = await bridge.batteryUpdates.toList();

      expect(updates.length, 5);
      expect(updates.first, 100);
      expect(updates.last, 80);
    });

    // Test 6: Stream descending order
    test('batteryUpdates values are in descending order', () async {
      final values = [100, 95, 90, 85, 80];
      transport.stubStreamValues('batteryUpdates', values);

      final updates = await bridge.batteryUpdates.toList();

      for (int i = 1; i < updates.length; i++) {
        expect(updates[i], lessThan(updates[i - 1]));
      }
    });

    // Test 7: Stream takes only first N events
    test('batteryUpdates with take(2)', () async {
      transport.stubStreamValues('batteryUpdates', [100, 95, 90, 85]);

      final first2 = await bridge.batteryUpdates.take(2).toList();

      expect(first2, equals([100, 95]));
    });

    // Test 8: Multiple method calls
    test('calls getModel twice', () async {
      transport.stubMethodValue('getModel', 'Pixel 6');

      await bridge.getModel();
      await bridge.getModel();

      transport.verifyMethodCalledTimes('getModel', 2);
    });

    // Test 9: Invocation inspection
    test('inspect method arguments', () async {
      transport.stubMethodValue('getModel', 'Device');

      await bridge.getModel();

      final invocations = transport.getInvocationsFor('getModel');
      expect(invocations.length, 1);
    });

    // Test 10: Error code inspection
    test('error details available', () async {
      transport.stubMethodError('getModel', 'DEVICE_ERROR', 'Not available');

      try {
        await bridge.getModel();
      } catch (e) {
        if (e is PlatformException) {
          expect(e.code, equals('DEVICE_ERROR'));
        }
      }
    });

    // Test 11: Reset between tests
    test('tearDown clears state', () async {
      transport.stubMethodValue('getModel', 'Device1');

      transport.clearInvocations();
      transport.stubMethodValue('getModel', 'Device2');

      final model = await bridge.getModel();
      expect(model, 'Device2');
      expect(transport.getInvocationsFor('getModel').length, 1);
    });
  });
}
```

---

## Unit vs. Integration Testing

### Unit Tests (MockBridgeTransport)

**Pros:**
- ✓ Fast (< 1 second)
- ✓ No native platform needed
- ✓ Easy to set up
- ✓ Deterministic
- ✓ Great for CI/CD

**Cons:**
- ✗ Doesn't test real platform behavior
- ✗ Platform-specific bugs won't surface

**When to use:**
- Business logic testing
- Error handling
- Contract validation
- Fast feedback loop

### Integration Tests (Real Native)

**Pros:**
- ✓ Tests real behavior
- ✓ Catches platform-specific bugs
- ✓ Full end-to-end validation

**Cons:**
- ✗ Requires device/simulator
- ✗ Slower (> 10 seconds)
- ✗ More flaky
- ✗ Hard to debug

**When to use:**
- Platform-specific behavior
- Real permission handling
- Hardware interaction
- Final validation before release

### Shared Test Logic

Write tests that work with both transports:

```dart
Future<void> runBridgeTests(BridgeTransport transport) async {
  final bridge = DeviceInfoBridgeImpl(transport);

  // This test works with both MockBridgeTransport and real MethodChannelTransport
  test('getModel works', () async {
    final model = await bridge.getModel();
    expect(model.isNotEmpty, true);
  });
}

void main() {
  // Unit tests with mock
  group('Unit Tests', () {
    setUp(() {
      final transport = MockBridgeTransport();
      transport.stubMethodValue('getModel', 'TestDevice');
      runBridgeTests(transport);
    });
  });

  // Integration tests with real transport
  group('Integration Tests', () {
    setUp(() {
      // Create on device/simulator
      final transport = MethodChannelTransport();
      runBridgeTests(transport);
    });
  });
}
```

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.0.0'

      - name: Get dependencies
        run: flutter pub get

      - name: Run unit tests
        run: flutter test

      - name: Run drift-check
        run: dart run native_bridge_kit_cli:drift_check --json --fail-on-drift

      - name: Generate coverage
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### Coverage Requirements

```dart
// Generate coverage report
flutter test --coverage

// Set minimum coverage (80%)
// In CI, enforce with tools like:
// - codecov
// - coveralls
// - codeclimate
```

---

## Best Practices

1. **Test behavior, not implementation** — Focus on what the bridge does, not how
2. **Use descriptive test names** — Test names should explain the scenario
3. **One assertion per test** — Easier to debug failures
4. **Use setUp/tearDown** — Keep tests isolated
5. **Mock external dependencies** — Don't test platform, test your logic
6. **Write integration tests too** — But not for every case
7. **Keep tests fast** — Aim for < 1 second per test

---

## Next Steps

- **[API Reference](api-reference.md)** — MockBridgeTransport complete API
- **[Troubleshooting](troubleshooting.md)** — Common testing issues
- **[Getting Started](getting-started.md)** — Build your first bridge

---

**[← Back to Root README](../README.md)**
