# native_bridge_kit

Dart-first runtime support for Flutter native bridge contracts.

## Platform support

This release supports Android and iOS native integrations. The runtime transport
does not provide Web or Linux host implementations, and the generators produce
Kotlin and Swift scaffolds only.

## Installation

```yaml
dependencies:
  native_bridge_kit: ^0.1.4
```

## Define a contract

```dart
import 'package:native_bridge_kit/native_bridge_kit.dart';

part 'device_info_bridge.g.dart';

@NativeBridge(channelPrefix: 'device_info')
abstract class DeviceInfoBridge {
  factory DeviceInfoBridge(BridgeTransport transport) = _$DeviceInfoBridge;

  Future<String?> getModel();

  @NativeStream()
  Stream<double> batteryLevel();
}
```

Generate the implementation with the published generator packages:

```bash
dart run build_runner build
```

## Use the bridge

```dart
final bridge = DeviceInfoBridge(MethodChannelTransport());
final model = await bridge.getModel();
```

`MethodChannelTransport` uses Flutter `MethodChannel` for `Future<T>` methods and `EventChannel` for `Stream<T>` methods. Native handlers and host registration remain platform-specific application code.

## Unit testing

Use `MockBridgeTransport` to test without a device:

```dart
final transport = MockBridgeTransport()
  ..stubMethodValue('device_info', 'get_model', 'Pixel 6');

final bridge = DeviceInfoBridge(transport);
expect(await bridge.getModel(), 'Pixel 6');
```

The mock also supports stream values, simulated errors, invocation capture, and call-count verification.

## Errors

`MethodChannelTransport` converts Flutter `PlatformException` values into `NativeBridgeException`, exposing `code`, `message`, and `details`.

## Scope

This package provides runtime transport and testing utilities. It does not implement native business logic, permissions, native SDK setup, or automatic host registration.

## License

MIT. See `LICENSE`.
