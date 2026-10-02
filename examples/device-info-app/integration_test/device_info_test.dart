import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:integration_test/integration_test.dart';
import 'package:device_info_app/main.dart' as app;
import 'package:device_info_app/native/device_info_bridge.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceInfoBridge Integration Tests', () {
    test('get device model from real native', () async {
      final bridge = DeviceInfoBridge(MethodChannelTransport());

      final model = await bridge.getModel();

      // Should return a non-empty string on real device
      expect(model?.isNotEmpty, true);
    });

    test('get OS version from real native', () async {
      final bridge = DeviceInfoBridge(MethodChannelTransport());

      final osVersion = await bridge.getOsVersion();

      expect(osVersion?.isNotEmpty, true);
    });

    test('battery level stream from real native', () async {
      final bridge = DeviceInfoBridge(MethodChannelTransport());

      // Take first 3 updates
      final updates = await bridge.batteryLevel().take(3).toList();

      expect(updates.length, 3);
      for (final level in updates) {
        expect(level, greaterThanOrEqualTo(0));
        expect(level, lessThanOrEqualTo(100));
      }
    });
  });

  testWidgets('DeviceInfoScreen displays device info',
      (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Look for expected UI elements
    expect(find.text('Device Info - native_bridge_kit Example'), findsOneWidget);

    // Wait for loading to complete
    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Should see device info displayed
    expect(find.byType(Card), findsWidgets);
  });
}
