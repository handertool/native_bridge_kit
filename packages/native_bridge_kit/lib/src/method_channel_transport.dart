import 'package:flutter/services.dart';

import 'bridge_transport.dart';
import 'native_bridge_kit_exception.dart';

/// A [BridgeTransport] backed by Flutter's [MethodChannel] and [EventChannel].
///
/// This is the stable **v1** transport shipped in Phase 1. Swap it for a
/// `NativePortTransport` in Phase 3 without touching any generated or
/// hand-written bridge code.
///
/// Channels are lazily created and cached — one [MethodChannel] per channel
/// name and one broadcast [Stream] per [EventChannel] name.
class MethodChannelTransport implements BridgeTransport {
  /// Cached [MethodChannel] instances, keyed by channel name.
  final Map<String, MethodChannel> _methodChannels = {};

  /// Cached broadcast streams, keyed by [EventChannel] name.
  final Map<String, Stream<dynamic>> _eventStreams = {};

  MethodChannel _methodChannel(String channel) =>
      _methodChannels.putIfAbsent(channel, () => MethodChannel(channel));

  Stream<dynamic> _eventStream(String channel) => _eventStreams.putIfAbsent(
        channel,
        () => EventChannel(channel).receiveBroadcastStream(),
      );

  @override
  Future<T?> invoke<T>(
    String channel,
    String method,
    Map<String, dynamic> args,
  ) async {
    try {
      return await _methodChannel(channel).invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      throw NativeBridgeException(
        code: e.code,
        message: e.message,
        details: e.details,
      );
    }
  }

  @override
  Stream<T> listen<T>(String channel) => _eventStream(channel).cast<T>();
}
