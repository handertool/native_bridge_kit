import 'bridge_transport.dart';

/// Mixin injected into every generated `_$ClassName` class.
///
/// Provides the [transport] reference so generated method bodies can call
/// `transport.invoke(...)` and `transport.listen(...)` without boilerplate.
///
/// Generated classes follow this pattern:
/// ```dart
/// class _$MyBridge extends MyBridge with NativeBridgeBase {
///   _$MyBridge(this.transport);
///
///   @override
///   final BridgeTransport transport;
/// }
/// ```
mixin NativeBridgeBase {
  /// The active [BridgeTransport] for this bridge instance.
  BridgeTransport get transport;
}
