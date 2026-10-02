// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info_bridge.dart';

// **************************************************************************
// NativeBridgeGenerator
// **************************************************************************

class _$DeviceInfoBridge with NativeBridgeBase implements DeviceInfoBridge {
  _$DeviceInfoBridge(this.transport);

  @override
  final BridgeTransport transport;

  @override
  Future<String?> getModel() =>
      transport.invoke<String>('device_info', 'get_model', const {});

  @override
  Future<String?> getOsVersion() =>
      transport.invoke<String>('device_info', 'get_os_version', const {});

  @override
  Stream<double> batteryLevel() =>
      transport.listen<double>('device_info/battery_level');
}
