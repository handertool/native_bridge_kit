#!/usr/bin/env dart

import 'package:native_bridge_kit_cli/src/cli.dart';

Future<void> main(List<String> arguments) async {
  await runCli(['drift-check', ...arguments]);
}
