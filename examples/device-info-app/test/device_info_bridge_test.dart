import 'package:flutter_test/flutter_test.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';
import 'package:device_info_app/native/device_info_bridge.dart';

void main() {
  group('DeviceInfoBridge Unit Tests', () {
    late MockBridgeTransport transport;
    late DeviceInfoBridge bridge;

    setUp(() {
      transport = MockBridgeTransport();
      bridge = DeviceInfoBridge(transport);
      transport.captureInvocations();
    });

    // ========== Test 1: getModel ==========
    test('getModel returns expected device name', () async {
      transport.stubMethodValue('device_info', 'get_model', 'Pixel 6');

      final model = await bridge.getModel();

      expect(model, equals('Pixel 6'));
      transport.verifyMethodCalled('device_info', 'get_model');
    });

    // ========== Test 2: getModel error ==========
    test('getModel throws error when unavailable', () async {
      transport.stubMethodError(
        'device_info',
        'get_model',
        code: 'DEVICE_ERROR',
        message: 'Device unavailable',
      );

      expect(
        () => bridge.getModel(),
        throwsA(isA<MockNativeException>()),
      );
    });

    // ========== Test 3: getOsVersion ==========
    test('getOsVersion returns operating-system version', () async {
      transport.stubMethodValue('device_info', 'get_os_version', 'Android 15');

      final osVersion = await bridge.getOsVersion();

      expect(osVersion, equals('Android 15'));
    });

    // ========== Test 4: batteryLevel ==========
    test('batteryLevel emits a valid percentage', () async {
      transport.stubStreamValues('device_info/battery_level', [75.0]);

      final level = await bridge.batteryLevel().first;

      expect(level, equals(75.0));
      expect(level, greaterThanOrEqualTo(0));
      expect(level, lessThanOrEqualTo(100));
    });

    // ========== Test 5: batteryLevel edge cases ==========
    test('batteryLevel handles edge cases', () async {
      transport.stubStreamValues('device_info/battery_level', [0.0, 100.0]);
      final levels = await bridge.batteryLevel().toList();
      expect(levels, equals([0.0, 100.0]));
    });

    // ========== Test 6: batteryLevel stream ==========
    test('batteryLevel emits multiple values', () async {
      transport.stubStreamValues(
        'device_info/battery_level',
        [100.0, 95.0, 90.0, 85.0, 80.0],
      );

      final updates = await bridge.batteryLevel().toList();

      expect(updates.length, 5);
      expect(updates.first, 100);
      expect(updates.last, 80);
    });

    // ========== Test 7: batteryLevel ordering ==========
    test('batteryLevel values are in descending order', () async {
      final values = [100.0, 95.0, 90.0, 85.0, 80.0];
      transport.stubStreamValues('device_info/battery_level', values);

      final updates = await bridge.batteryLevel().toList();

      for (int i = 1; i < updates.length; i++) {
        expect(updates[i], lessThan(updates[i - 1]));
      }
    });

    // ========== Test 8: batteryLevel with take ==========
    test('batteryLevel with take(2) returns first two', () async {
      transport.stubStreamValues(
          'device_info/battery_level', [100.0, 95.0, 90.0, 85.0]);

      final first2 = await bridge.batteryLevel().take(2).toList();

      expect(first2, equals([100.0, 95.0]));
    });

    // ========== Test 9: Multiple calls ==========
    test('calls getModel twice', () async {
      transport.stubMethodValue('device_info', 'get_model', 'Pixel 6');

      await bridge.getModel();
      await bridge.getModel();
      transport.verifyMethodCalledTimes('device_info', 'get_model', 2);
    });

    // ========== Test 10: Invocation inspection ==========
    test('inspect method invocations', () async {
      transport.stubMethodValue('device_info', 'get_model', 'Device');
      await bridge.getModel();

      final invocations =
          transport.getInvocationsFor('device_info', 'get_model');
      expect(invocations.length, 1);
    });

    // ========== Test 11: Battery stream error ==========
    test('batteryLevel emits error', () async {
      transport.stubStreamError(
        'device_info/battery_level',
        code: 'STREAM_ERROR',
        message: 'Stream unavailable',
      );

      expect(
        () => bridge.batteryLevel().first,
        throwsException,
      );
    });

    // ========== Test 12: Multiple methods together ==========
    test('call getModel and getOsVersion together', () async {
      transport.stubMethodValue('device_info', 'get_model', 'Pixel 6');
      transport.stubMethodValue('device_info', 'get_os_version', 'Android 15');

      final model = await bridge.getModel();
      final osVersion = await bridge.getOsVersion();

      expect(model, 'Pixel 6');
      expect(osVersion, 'Android 15');

      transport.verifyMethodCalled('device_info', 'get_model');
      transport.verifyMethodCalled('device_info', 'get_os_version');
    });
  });
}
