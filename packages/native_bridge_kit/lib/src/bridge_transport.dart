/// Abstract transport contract used by every generated bridge class.
///
/// Swap implementations without changing a single line of hand-written or
/// generated bridge code:
///
/// * v1 (Phase 1) — [MethodChannelTransport]: stable Flutter channels.
/// * v2 (Phase 3) — `NativePortTransport`: direct Dart isolate port,
///   no codec overhead.
abstract interface class BridgeTransport {
  /// Invoke a single-shot native method and return its typed result.
  ///
  /// [channel] – the `MethodChannel` name (e.g. `"device_info"`).
  /// [method]  – the method name sent over the channel (e.g. `"get_model"`).
  /// [args]    – named Dart parameters serialised as a flat
  ///             `Map<String, dynamic>`. `StandardMessageCodec` supports
  ///             `String`, `int`, `double`, `bool`, `List`, and `Map` without
  ///             extra work. Custom types need a `toMap()` adapter.
  Future<T?> invoke<T>(
    String channel,
    String method,
    Map<String, dynamic> args,
  );

  /// Subscribe to a native event stream.
  ///
  /// [channel] – the `EventChannel` name (e.g. `"device_info/battery_level"`).
  /// The channel key is `{channelPrefix}/{wireName}` by generator convention.
  Stream<T> listen<T>(String channel);
}
