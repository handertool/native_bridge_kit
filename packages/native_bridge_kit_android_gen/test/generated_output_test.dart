import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('generated Kotlin output contains bridge wiring and scaffold markers',
      () {
    final root = Directory.current.parent.parent.path;
    final output =
        File('$root/lib/native/device_info_bridge.g.kt').readAsStringSync();

    expect(output, contains('MethodChannel'));
    expect(output, contains('"device_info"'));
    expect(output, contains('"get_model"'));
    expect(output, contains('"get_os_version"'));
    expect(output, contains('"device_info/battery_level"'));
    expect(output, contains('Generated scaffold'));
  });
}
