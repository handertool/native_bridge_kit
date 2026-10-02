import 'package:native_bridge_kit/native_bridge_kit.dart';

part 'device_info_bridge.g.dart';

/// Bridge contract for device information.
///
/// This is the single source of truth for the Dart↔Native bridge.
@NativeBridge(channelPrefix: 'device_info')
abstract class DeviceInfoBridge {
  factory DeviceInfoBridge(BridgeTransport transport) = _$DeviceInfoBridge;

  /// Get the device model name (e.g., "Pixel 6", "iPhone 13")
  @NativeMethod()
  Future<String?> getModel();

  /// Get the operating-system version (e.g., "Android 15", "18.1.1")
  @NativeMethod()
  Future<String?> getOsVersion();

  /// Stream of battery level updates as a percentage (0-100).
  ///
  /// Emits new battery percentage whenever it changes.
  /// The handler should emit updates, not just initial value.
  @NativeStream()
  Stream<double> batteryLevel();
}
