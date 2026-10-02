import 'dart:io';

import 'package:native_bridge_kit_cli/src/dart_contract_parser.dart';
import 'package:native_bridge_kit_cli/src/drift_comparator.dart';
import 'package:native_bridge_kit_cli/src/native_handlers_parser.dart';
import 'package:test/test.dart';

void main() {
  final projectRoot = Directory.current.parent.parent.path;
  final contractPath = '$projectRoot/lib/native/device_info_bridge.dart';
  final androidHandlerPath =
      '$projectRoot/android/app/src/main/kotlin/com/example/native_bridge_kit_example/'
      'DeviceInfoBridgeHandler.kt';
  final iosHandlerPath = '$projectRoot/ios/Runner/SceneDelegate.swift';

  test('parses the bridge contract methods', () async {
    final metadata = ContractMetadata.fromMap(
      await DartContractParser(contractPath).parseContract(),
    );

    expect(
      metadata.methods.map((method) => method.name),
      containsAll(<String>['getModel', 'getOsVersion', 'batteryLevel']),
    );
  });

  test('parses direct Kotlin dispatch and event channels', () {
    final metadata = HandlerMetadata.fromMap(
      KotlinHandlerParser(androidHandlerPath).parseHandler(),
    );

    expect(
      metadata.methods,
      containsAll(<String>['get_model', 'get_os_version', 'battery_level']),
    );
  });

  test('parses direct Swift dispatch and event channels', () {
    final metadata = HandlerMetadata.fromMap(
      SwiftHandlerParser(iosHandlerPath).parseHandler(),
    );

    expect(
      metadata.methods,
      containsAll(<String>['get_model', 'get_os_version', 'battery_level']),
    );
  });

  test('reports missing and extra methods', () {
    final issues = DriftComparator().compare(
      contractMethods: ['getModel', 'getOsVersion'],
      handlerMethods: ['get_model', 'getTemperature'],
      platform: 'android',
    );

    expect(issues.map((issue) => issue.type),
        containsAll(<String>['missing_method', 'extra_method']));
  });
}
