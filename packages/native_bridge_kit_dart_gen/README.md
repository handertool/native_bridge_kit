# native_bridge_kit_dart_gen

`build_runner` generator for Dart implementations of `@NativeBridge` contracts.

It is part of the Android and iOS bridge workflow. It does not generate Web or
Linux host implementations.

## Installation

```yaml
dev_dependencies:
  build_runner: ^2.4.0
  native_bridge_kit_dart_gen: ^0.1.4
```

Your application also needs `native_bridge_kit` as a runtime dependency.

## Usage

```dart
import 'package:native_bridge_kit/native_bridge_kit.dart';

part 'device_info_bridge.g.dart';

@NativeBridge(channelPrefix: 'device_info')
abstract class DeviceInfoBridge {
  factory DeviceInfoBridge(BridgeTransport transport) = _$DeviceInfoBridge;

  Future<String?> getModel();
}
```

Generate the `.g.dart` implementation:

```bash
dart run build_runner build
```

The generator supports `Future<T>` methods, `Stream<T>` methods, named parameters, and explicit wire names through `@NativeMethod` and `@NativeStream`.

Only named parameters are supported. Native business logic and platform handler registration are outside this package's scope.

## License

MIT. See `LICENSE`.
