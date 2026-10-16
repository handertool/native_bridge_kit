import 'dart:async';

class NativeBridge {
  const NativeBridge();
}

class NativeMethod {
  const NativeMethod({this.name});
  final String? name;
}

class NativeStream {
  const NativeStream({this.name});
  final String? name;
}

const methodWireName = 'renamed_method';

@NativeBridge()
abstract class WireNameContract {
  @NativeMethod(name: methodWireName)
  Future<String> originalMethod();

  @NativeStream(name: 'custom-events')
  Stream<int> updates();
}
