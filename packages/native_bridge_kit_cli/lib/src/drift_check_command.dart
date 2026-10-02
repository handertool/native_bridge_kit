import 'dart:io';
import 'dart:async';
import 'package:args/args.dart';
import 'dart_contract_parser.dart';
import 'native_handlers_parser.dart';
import 'drift_comparator.dart';
import 'drift_output_formatter.dart';

/// Main drift-check command implementation
class DriftCheckCommand {
  final String projectRoot;
  final ArgResults args;

  DriftCheckCommand({
    required this.projectRoot,
    required this.args,
  });

  /// Run the drift-check command
  Future<int> run() async {
    try {
      // Get configuration from arguments
      final contractPath = _pathOption('contract') ?? _findContractFile();
      final sharedHandlerPath = _pathOption('handler');
      final androidHandlerPath = _pathOption('android-handler') ??
          sharedHandlerPath ??
          _findAndroidHandler();
      final iosHandlerPath =
          _pathOption('ios-handler') ?? sharedHandlerPath ?? _findIosHandler();
      final platform = args['platform'] as String? ?? 'all';
      final outputFormat = args['json'] as bool? ?? false;
      final failOnDrift = args['fail-on-drift'] as bool? ?? false;

      if (contractPath == null) {
        print('Error: Could not find Dart contract file');
        return 1;
      }

      // Parse contract
      final contractParser = DartContractParser(contractPath);
      final contractData = await contractParser.parseContract();
      final contractMetadata = ContractMetadata.fromMap(contractData);
      final contractMethodNames =
          contractMetadata.methods.map((m) => m.name).toList();

      // Parse handlers and compare
      final comparator = DriftComparator();
      final allIssues = <DriftIssue>[];

      // Check Android
      if (platform == 'all' || platform == 'android') {
        if (androidHandlerPath != null) {
          final kotlinParser = KotlinHandlerParser(androidHandlerPath);
          final handlerData = kotlinParser.parseHandler();
          final handlerMetadata = HandlerMetadata.fromMap(handlerData);
          final androidIssues = comparator.compare(
            contractMethods: contractMethodNames,
            handlerMethods: handlerMetadata.methods,
            platform: 'android',
          );
          allIssues.addAll(androidIssues);
        }
      }

      // Check iOS
      if (platform == 'all' || platform == 'ios') {
        if (iosHandlerPath != null) {
          final swiftParser = SwiftHandlerParser(iosHandlerPath);
          final handlerData = swiftParser.parseHandler();
          final handlerMetadata = HandlerMetadata.fromMap(handlerData);
          final iosIssues = comparator.compare(
            contractMethods: contractMethodNames,
            handlerMethods: handlerMetadata.methods,
            platform: 'ios',
          );
          allIssues.addAll(iosIssues);
        }
      }

      // Output results
      final inSync = allIssues.isEmpty;
      if (outputFormat) {
        print(DriftOutputFormatter.formatJson(allIssues, inSync: inSync));
      } else {
        print(DriftOutputFormatter.formatHuman(allIssues));
      }

      // Exit with appropriate code
      if (!inSync && failOnDrift) {
        return 1; // Fail the build
      }
      return 0; // Success
    } catch (e, stackTrace) {
      print('Error running drift-check: $e');
      if (args['verbose'] as bool? ?? false) {
        print(stackTrace);
      }
      return 1;
    }
  }

  String? _pathOption(String name) {
    final value = args[name] as String?;
    if (value == null || value.isEmpty) {
      return null;
    }
    return File(
      value.startsWith('/') ? value : '$projectRoot/$value',
    ).absolute.path;
  }

  /// Find the Dart contract file
  String? _findContractFile() {
    // Look for lib/native/*_bridge.dart
    final libDir = Directory('$projectRoot/lib');
    if (libDir.existsSync()) {
      final nativeDir = Directory('${libDir.path}/native');
      if (nativeDir.existsSync()) {
        for (final entity in nativeDir.listSync()) {
          if (entity is File && entity.path.endsWith('_bridge.dart')) {
            return entity.path;
          }
        }
      }
    }
    return null;
  }

  /// Find Android Kotlin handler
  String? _findAndroidHandler() {
    // Look for android/app/src/main/kotlin/*/*Handler.kt
    final androidDir = Directory('$projectRoot/android');
    if (androidDir.existsSync()) {
      try {
        for (final entity
            in androidDir.listSync(recursive: true, followLinks: false)) {
          if (entity is File && entity.path.endsWith('Handler.kt')) {
            return entity.path;
          }
        }
      } catch (e) {
        // Ignore errors during recursive search
      }
    }
    return null;
  }

  /// Find iOS Swift handler
  String? _findIosHandler() {
    // Look for ios/Runner/**Handler.swift
    final iosDir = Directory('$projectRoot/ios');
    if (iosDir.existsSync()) {
      try {
        for (final entity
            in iosDir.listSync(recursive: true, followLinks: false)) {
          if (entity is File && entity.path.endsWith('Handler.swift')) {
            return entity.path;
          }
        }
      } catch (e) {
        // Ignore errors during recursive search
      }
    }
    return null;
  }
}
