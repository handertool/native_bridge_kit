import 'package:build/build.dart';
import 'package:native_bridge_kit_android_gen/native_bridge_kit_android_gen.dart';

void main() {
  final builder = kotlinBridgeBuilder(const BuilderOptions({}));
  print('Android Kotlin bridge builder: ${builder.runtimeType}');
  print('The generated output is a .g.kt scaffold for Android handlers.');
}
