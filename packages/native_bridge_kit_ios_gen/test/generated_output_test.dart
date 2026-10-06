import 'dart:io';

import 'package:test/test.dart';

void main() {
  test('generated Swift output contains bridge wiring and scaffold markers',
      () {
    final output =
        File(_generatedFilePath('lib/native/device_info_bridge.g.swift'))
            .readAsStringSync();

    expect(output, contains('FlutterMethodChannel'));
    expect(output, contains('name: "device_info"'));
    expect(output, contains('case "get_model"'));
    expect(output, contains('case "get_os_version"'));
    expect(output, contains('name: "device_info/battery_level"'));
    expect(output, contains('Generated scaffold'));
  });

  test('generated Swift output has balanced declarations and blocks', () {
    final output =
        File(_generatedFilePath('lib/native/device_info_bridge.g.swift'))
            .readAsStringSync();

    expect(output, contains('class DeviceInfoBridgeHandler'));
    expect(_count(output, '{'), _count(output, '}'));
    expect(_count(output, '('), _count(output, ')'));
    expect(output, isNot(contains('TODO: fix generated syntax')));
  });
}

String _generatedFilePath(String relativePath) {
  var directory = Directory.current;
  while (directory.path != directory.parent.path) {
    final candidate = File('${directory.path}/$relativePath');
    if (candidate.existsSync()) return candidate.path;
    directory = directory.parent;
  }
  throw StateError('Could not locate $relativePath');
}

int _count(String value, String character) =>
    character.allMatches(value).length;
