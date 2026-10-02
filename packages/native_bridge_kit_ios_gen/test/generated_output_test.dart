import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('generated Swift output contains bridge wiring and scaffold markers',
      () {
    final root = Directory.current.parent.parent.path;
    final output =
        File('$root/lib/native/device_info_bridge.g.swift').readAsStringSync();

    expect(output, contains('FlutterMethodChannel'));
    expect(output, contains('name: "device_info"'));
    expect(output, contains('case "get_model"'));
    expect(output, contains('case "get_os_version"'));
    expect(output, contains('name: "device_info/battery_level"'));
    expect(output, contains('Generated scaffold'));
  });
}
