import 'package:native_bridge_kit/native_bridge_kit.dart';

part 'device_info_bridge.g.dart';

/// Example native bridge — single source of truth for the device-info API.
///
/// Run `flutter pub run build_runner build` to regenerate
/// `device_info_bridge.g.dart` after changing this contract.
///
/// **Channel convention**
/// * Method channel : `device_info`
/// * Event channel  : `device_info/<method_name>`
///
/// Native side registers:
/// ```swift
/// // Swift (iOS)
/// let channel = FlutterMethodChannel(name: "device_info", ...)
/// channel.setMethodCallHandler { call, result in
///   switch call.method {
///   case "get_model":     result(UIDevice.current.model)
///   case "get_os_version": result(UIDevice.current.systemVersion)
///   default: result(FlutterMethodNotImplemented)
///   }
/// }
/// ```
@NativeBridge(channelPrefix: 'device_info')
abstract class DeviceInfoBridge {
  /// Creates a concrete [DeviceInfoBridge] backed by [transport].
  ///
  /// This factory redirects to the generated [_$DeviceInfoBridge]
  /// implementation. Inject a [MockBridgeTransport] in tests.
  ///
  /// ```dart
  /// final bridge = DeviceInfoBridge(MethodChannelTransport());
  /// ```
  factory DeviceInfoBridge(BridgeTransport transport) = _$DeviceInfoBridge;

  /// Returns the device model string, e.g. `"iPhone 16 Pro"`.
  Future<String?> getModel();

  /// Returns the OS version string, e.g. `"18.1.1"`.
  Future<String?> getOsVersion();

  /// Emits the current battery level (0.0 – 100.0) each time it changes.
  ///
  /// Event channel name: `device_info/battery_level`
  @NativeStream()
  Stream<double> batteryLevel();
}
