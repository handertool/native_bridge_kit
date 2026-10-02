/// Marks an abstract Dart class as a native platform bridge.
///
/// The `native_bridge_kit_gen` code generator reads this annotation and generates
/// a concrete `_$ClassName` implementation that wires each method to the
/// appropriate [MethodChannel] or [EventChannel].
///
/// ```dart
/// @NativeBridge()
/// abstract class DeviceInfoBridge {
///   Future<String?> getModel();
///   Stream<double> batteryLevel();
/// }
/// ```
class NativeBridge {
  /// Optional prefix used as the base name for all channel strings derived
  /// from this class. Defaults to the class name converted to `snake_case`
  /// (e.g. `DeviceInfoBridge` → `device_info_bridge`).
  final String? channelPrefix;

  const NativeBridge({this.channelPrefix});
}

/// Optionally overrides the wire method name used on the [MethodChannel].
///
/// Without this annotation the generator uses the Dart method name converted
/// to `snake_case`. Apply this when the native implementation already has a
/// fixed name that differs from the Dart convention.
///
/// ```dart
/// @NativeMethod(name: 'getDeviceModel')
/// Future<String?> getModel();
/// ```
class NativeMethod {
  /// The method name sent over the channel. Defaults to the Dart method name
  /// in `snake_case`.
  final String? name;

  const NativeMethod({this.name});
}

/// Marks a `Stream<T>` returning method as a native event stream.
///
/// The generator wires this to a dedicated [EventChannel] named
/// `{channelPrefix}/{wireName}`. Omitting this annotation on a `Stream<T>`
/// method still works — the annotation is only needed when you want to
/// override the default event-channel name suffix.
///
/// ```dart
/// @NativeStream(name: 'battery')
/// Stream<double> batteryLevel();
/// ```
class NativeStream {
  /// The event channel name suffix. Defaults to the Dart method name in
  /// `snake_case`.
  final String? name;

  const NativeStream({this.name});
}
