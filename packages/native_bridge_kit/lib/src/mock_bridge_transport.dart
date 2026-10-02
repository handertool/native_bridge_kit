import 'bridge_transport.dart';
import 'native_bridge_kit_exception.dart';

/// Callback type for a stubbed method handler.
typedef MethodHandler = dynamic Function(Map<String, dynamic> args);

/// Exception that can be used to simulate a native-side error in tests.
class MockNativeException implements Exception {
  MockNativeException({
    required this.code,
    required this.message,
    this.details,
  });

  final String code;
  final String message;
  final dynamic details;

  @override
  String toString() => 'MockNativeException($code: $message)';
}

/// A captured method invocation.
class CapturedInvocation {
  CapturedInvocation({
    required this.channel,
    required this.method,
    required this.args,
    required this.timestamp,
  });

  final String channel;
  final String method;
  final Map<String, dynamic> args;
  final DateTime timestamp;

  @override
  String toString() => '$channel/$method($args)';
}

/// A [BridgeTransport] implementation for Dart unit tests.
class MockBridgeTransport implements BridgeTransport {
  final Map<String, MethodHandler> _methodStubs = {};
  final Map<String, Stream<dynamic>> _streamStubs = {};
  final List<CapturedInvocation> _invocations = [];
  bool _captureInvocations = false;

  /// Registers a handler for a `channel` and wire-level `method`.
  MockBridgeTransport stubMethod(
    String channel,
    String method,
    MethodHandler handler,
  ) {
    _methodStubs['$channel/$method'] = handler;
    return this;
  }

  /// Registers a stream for an event-channel name.
  MockBridgeTransport stubStream(String channel, Stream<dynamic> stream) {
    _streamStubs[channel] = stream;
    return this;
  }

  /// Registers a method that returns [value].
  MockBridgeTransport stubMethodValue<T>(
    String channel,
    String method,
    T value,
  ) => stubMethod(channel, method, (_) => value);

  /// Registers a method that throws a simulated native error.
  MockBridgeTransport stubMethodError(
    String channel,
    String method, {
    required String code,
    required String message,
    dynamic details,
  }) => stubMethod(
    channel,
    method,
    (_) => throw MockNativeException(
      code: code,
      message: message,
      details: details,
    ),
  );

  /// Registers a stream that emits one value.
  MockBridgeTransport stubStreamValue<T>(String channel, T value) =>
      stubStream(channel, Stream.value(value));

  /// Registers a stream that emits [values].
  MockBridgeTransport stubStreamValues<T>(String channel, List<T> values) =>
      stubStream(channel, Stream.fromIterable(values));

  /// Registers a stream that emits a simulated native error.
  MockBridgeTransport stubStreamError(
    String channel, {
    required String code,
    required String message,
    dynamic details,
  }) {
    final exception = MockNativeException(
      code: code,
      message: message,
      details: details,
    );
    return stubStream(channel, Stream.error(exception));
  }

  /// Enables recording of method calls.
  MockBridgeTransport captureInvocations() {
    _captureInvocations = true;
    return this;
  }

  /// Returns an immutable view of recorded method calls.
  List<CapturedInvocation> getInvocations() => List.unmodifiable(_invocations);

  /// Returns recorded calls for a specific channel and method.
  List<CapturedInvocation> getInvocationsFor(String channel, String method) =>
      _invocations
          .where(
            (invocation) =>
                invocation.channel == channel && invocation.method == method,
          )
          .toList();

  /// Clears recorded method calls.
  void clearInvocations() => _invocations.clear();

  /// Asserts that a method was called, optionally with [args].
  void verifyMethodCalled(
    String channel,
    String method, {
    Map<String, dynamic>? args,
  }) {
    final invocations = getInvocationsFor(channel, method);
    if (invocations.isEmpty) {
      throw AssertionError(
        'Expected call to $channel/$method, but it was never called',
      );
    }
    if (args != null &&
        !invocations.any((invocation) => _mapsEqual(invocation.args, args))) {
      throw AssertionError(
        'Expected call to $channel/$method with args $args, '
        'but actual invocations were: ${invocations.map((invocation) => invocation.args)}',
      );
    }
  }

  /// Asserts that a method was called exactly [count] times.
  void verifyMethodCalledTimes(String channel, String method, int count) {
    final invocations = getInvocationsFor(channel, method);
    if (invocations.length != count) {
      throw AssertionError(
        'Expected $channel/$method to be called $count times, '
        'but was called ${invocations.length} times',
      );
    }
  }

  @override
  Future<T?> invoke<T>(
    String channel,
    String method,
    Map<String, dynamic> args,
  ) async {
    final key = '$channel/$method';
    final handler = _methodStubs[key];
    if (handler == null) {
      throw StateError(
        'MockBridgeTransport: no stub registered for "$key". '
        'Call stubMethod("$channel", "$method", handler) in your test setUp.',
      );
    }

    if (_captureInvocations) {
      _invocations.add(
        CapturedInvocation(
          channel: channel,
          method: method,
          args: Map<String, dynamic>.unmodifiable(args),
          timestamp: DateTime.now(),
        ),
      );
    }

    final value = handler(args);
    if (value is NativeBridgeException) throw value;
    return value as T?;
  }

  @override
  Stream<T> listen<T>(String channel) {
    final stream = _streamStubs[channel];
    if (stream == null) {
      throw StateError(
        'MockBridgeTransport: no stream stub registered for "$channel". '
        'Call stubStream("$channel", stream) in your test setUp.',
      );
    }
    return stream.cast<T>();
  }

  bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}
