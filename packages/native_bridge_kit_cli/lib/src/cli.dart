import 'dart:io';

import 'package:args/args.dart';

import 'drift_check_command.dart';

Future<void> runCli(List<String> arguments) async {
  final driftParser = buildDriftCheckParser();
  final parser = ArgParser()
    ..addCommand('drift-check', driftParser)
    ..addFlag('verbose', abbr: 'v', help: 'Enable verbose output')
    ..addFlag('help', abbr: 'h', help: 'Show this help message');

  try {
    final results = parser.parse(arguments);
    final commandResults = results.command;

    if (results['help'] as bool) {
      stdout.write(parser.usage);
      exit(0);
    }

    if (commandResults?.name == 'drift-check') {
      final driftResults = commandResults!;
      if (driftResults['help'] as bool) {
        stdout.write(driftParser.usage);
        exit(0);
      }
      final projectRoot = driftResults['project-root'] as String?;
      final command = DriftCheckCommand(
        projectRoot: _resolveProjectRoot(projectRoot),
        args: driftResults,
      );
      exit(await command.run());
    }

    stdout.write(parser.usage);
    exit(1);
  } on FormatException catch (error) {
    stderr.writeln('Error: $error');
    stderr.write(parser.usage);
    exit(1);
  } catch (error) {
    stderr.writeln('Error: $error');
    exit(1);
  }
}

String _resolveProjectRoot(String? value) {
  final directory =
      value == null || value.isEmpty ? Directory.current : Directory(value);
  return directory.absolute.resolveSymbolicLinksSync();
}

ArgParser buildDriftCheckParser() {
  return ArgParser()
    ..addOption(
      'project-root',
      help: 'Project root used for auto-discovery (default: current directory)',
    )
    ..addOption(
      'platform',
      abbr: 'p',
      defaultsTo: 'all',
      allowed: ['all', 'android', 'ios'],
      help: 'Platform to check (all, android, or ios)',
    )
    ..addOption('contract', help: 'Path to the Dart bridge contract')
    ..addOption('handler',
        help: 'Path to a handler used for the selected platform')
    ..addOption('android-handler', help: 'Path to the Android Kotlin handler')
    ..addOption('ios-handler', help: 'Path to the iOS Swift handler')
    ..addFlag('json', help: 'Output results as JSON')
    ..addFlag(
      'fail-on-drift',
      help: 'Exit with code 1 if drift is detected (for CI)',
    )
    ..addFlag('verbose', abbr: 'v', help: 'Enable verbose output')
    ..addFlag('help', abbr: 'h', help: 'Show this help message');
}
