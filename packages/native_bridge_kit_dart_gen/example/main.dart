import 'package:build/build.dart';
import 'package:native_bridge_kit_dart_gen/native_bridge_kit_dart_gen.dart';

void main() {
  final builder = nativeBridgeBuilder(const BuilderOptions({}));
  print('Dart bridge builder: ${builder.runtimeType}');
  print(
    'Run `dart run build_runner build` in an application to generate .g.dart files.',
  );
}
