# native_bridge_kit_annotation

Annotations for defining Dart-first Flutter native bridge contracts.

## Installation

```yaml
dependencies:
  native_bridge_kit_annotation: ^0.1.0
```

Most applications should depend on [`native_bridge_kit`](https://pub.dev/packages/native_bridge_kit), which re-exports these annotations.

## Usage

```dart
import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';

@NativeBridge(channelPrefix: 'device_info')
abstract class DeviceInfoBridge {
  Future<String?> getModel();

  @NativeStream()
  Stream<double> batteryLevel();
}
```

Available annotations:

- `@NativeBridge` marks a contract and optionally sets its channel prefix.
- `@NativeMethod` overrides a method's wire name.
- `@NativeStream` marks a stream contract and optionally overrides its event-channel suffix.

This package contains annotations only. The code-generation packages are kept in the repository and will be published in a later release.

## License

MIT. See `LICENSE`.
