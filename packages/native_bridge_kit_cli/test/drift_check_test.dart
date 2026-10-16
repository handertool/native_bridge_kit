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
    expect(
      metadata.methods.map((method) => method.wireName),
      containsAll(<String>['get_model', 'get_os_version', 'battery_level']),
    );
    expect(
      metadata.methods.map((method) => method.kind),
      containsAll(<String>['method', 'stream']),
    );
  });

  test('parses explicit wire names and operation kinds', () async {
    final metadata = ContractMetadata.fromMap(
      await DartContractParser(
        '${Directory.current.path}/test/fixtures/wire_name_contract.dart',
      ).parseContract(),
    );

    expect(
      metadata.methods.map((method) => (method.wireName, method.kind)),
      containsAll(<(String, String)>[
        ('renamed_method', 'method'),
        ('custom-events', 'stream'),
      ]),
    );
  });

  test('parses direct Kotlin dispatch and event channels', () {
    final metadata = HandlerMetadata.fromMap(
      KotlinHandlerParser(androidHandlerPath).parseHandler(),
    );

    expect(
      metadata.operations.map((operation) => operation.name),
      containsAll(<String>['get_model', 'get_os_version', 'battery_level']),
    );
    expect(
      metadata.operations
          .firstWhere((operation) => operation.name == 'battery_level')
          .kind,
      'stream',
    );
  });

  test('parses direct Swift dispatch and event channels', () {
    final metadata = HandlerMetadata.fromMap(
      SwiftHandlerParser(iosHandlerPath).parseHandler(),
    );

    expect(
      metadata.operations.map((operation) => operation.name),
      containsAll(<String>['get_model', 'get_os_version', 'battery_level']),
    );
    expect(
      metadata.operations
          .firstWhere((operation) => operation.name == 'battery_level')
          .kind,
      'stream',
    );
  });

  test('parses explicit native wire names without normalizing them', () {
    final kotlin = HandlerMetadata.fromMap(
      KotlinHandlerParser(
        '${Directory.current.path}/test/fixtures/overridden_handler.kt',
      ).parseHandler(),
    );
    final swift = HandlerMetadata.fromMap(
      SwiftHandlerParser(
        '${Directory.current.path}/test/fixtures/overridden_handler.swift',
      ).parseHandler(),
    );

    for (final metadata in [kotlin, swift]) {
      expect(
        metadata.operations
            .map((operation) => (operation.name, operation.kind)),
        containsAll(<(String, String)>[
          ('custom_method', 'method'),
          ('custom-events', 'stream'),
        ]),
      );
    }
  });

  test('reports missing and extra methods', () {
    final issues = DriftComparator().compare(
      contractOperations: const [
        BridgeOperation(name: 'get_model', kind: 'method'),
        BridgeOperation(name: 'get_os_version', kind: 'method'),
      ],
      handlerOperations: const [
        BridgeOperation(name: 'get_model', kind: 'method'),
        BridgeOperation(name: 'get_temperature', kind: 'method'),
      ],
      platform: 'android',
    );

    expect(
      issues.map((issue) => issue.type),
      containsAll(<String>['missing_operation', 'extra_operation']),
    );
  });

  test('reports an operation-kind mismatch', () {
    final issues = DriftComparator().compare(
      contractOperations: const [
        BridgeOperation(name: 'battery_level', kind: 'stream'),
      ],
      handlerOperations: const [
        BridgeOperation(name: 'battery_level', kind: 'method'),
      ],
      platform: 'ios',
    );

    expect(issues, hasLength(1));
    expect(issues.single.type, 'operation_kind_mismatch');
    expect(issues.single.message, contains('stream'));
    expect(issues.single.message, contains('method'));
  });
}
