import 'package:native_bridge_kit/native_bridge_kit.dart';

Future<void> main() async {
  final transport = MockBridgeTransport()
    ..stubMethodValue('device_info', 'get_model', 'Example device')
    ..stubStreamValues('device_info/battery_level', [80, 79, 78]);

  final model = await transport.invoke<String>(
    'device_info',
    'get_model',
    const {},
  );
  final batteryLevels = await transport
      .listen<int>('device_info/battery_level')
      .toList();

  print('Model: $model');
  print('Battery levels: $batteryLevels');
}
