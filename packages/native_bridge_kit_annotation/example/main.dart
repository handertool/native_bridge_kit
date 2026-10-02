import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';

@NativeBridge(channelPrefix: 'device_info')
abstract class DeviceInfoBridge {
  @NativeMethod(name: 'get_model')
  Future<String?> getModel();

  @NativeStream(name: 'battery_level')
  Stream<int> watchBatteryLevel();
}

void main() {
  print('Defined bridge contract: ${DeviceInfoBridge}');
}
