import 'package:flutter_test/flutter_test.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';
import 'package:native_bridge_kit_example/native/device_info_bridge.dart';

void main() {
  group('DeviceInfoBridge', () {
    test('forwards method calls using wire names', () async {
      final transport = MockBridgeTransport()
        ..stubMethodValue('device_info', 'get_model', 'Pixel 6')
        ..stubMethodValue('device_info', 'get_os_version', 'Android 14')
        ..captureInvocations();
      final bridge = DeviceInfoBridge(transport);

      expect(await bridge.getModel(), 'Pixel 6');
      expect(await bridge.getOsVersion(), 'Android 14');

      transport.verifyMethodCalled('device_info', 'get_model');
      transport.verifyMethodCalled('device_info', 'get_os_version');
    });

    test('forwards battery events using the event channel name', () async {
      final transport = MockBridgeTransport()
        ..stubStreamValues('device_info/battery_level', [75.0, 74.5]);
      final bridge = DeviceInfoBridge(transport);

      expect(await bridge.batteryLevel().toList(), [75.0, 74.5]);
    });
  });
}
