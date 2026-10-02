/// Runtime transport layer for the native_bridge_kit system.
///
/// Import this in the file that owns your `@NativeBridge` abstract class *and*
/// wherever you instantiate the bridge — the `part` relationship lets the
/// generated code share these imports automatically.
///
/// ```dart
/// import 'package:native_bridge_kit/native_bridge_kit.dart';
/// import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';
/// part 'my_bridge.g.dart';
///
/// @NativeBridge()
/// abstract class MyBridge {
///   factory MyBridge(BridgeTransport transport) = _$MyBridge;
///   // ...
/// }
///
/// // Usage:
/// final bridge = MyBridge(MethodChannelTransport());
/// ```
library;

export 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';
export 'src/bridge_transport.dart';
export 'src/method_channel_transport.dart';
export 'src/mock_bridge_transport.dart';
export 'src/native_bridge_kit_base.dart';
export 'src/native_bridge_kit_exception.dart';
