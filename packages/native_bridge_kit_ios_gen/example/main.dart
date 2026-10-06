import 'package:build/build.dart';
import 'package:native_bridge_kit_ios_gen/native_bridge_kit_ios_gen.dart';

void main() {
  final builder = swiftBridgeBuilder(const BuilderOptions({}));
  print('iOS Swift bridge builder: ${builder.runtimeType}');
  print('The generated output is a .g.swift scaffold for iOS handlers.');
}
