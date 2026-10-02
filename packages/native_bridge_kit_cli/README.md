# native_bridge_kit_cli

Command-line tools for native_bridge_kit, including the `drift-check` command for detecting contract-handler drift.

## Overview

`native_bridge_kit_cli` provides command-line utilities for working with native_bridge_kit projects. The primary tool is `drift-check`, which validates that your Dart bridge contracts match your Kotlin and Swift handlers.

The current supported native targets are Android and iOS. Web and Linux native
handlers are outside the scope of the drift checker.

## Installation

Add to your project's `pubspec.yaml` **dev_dependencies**:

```yaml
dev_dependencies:
  native_bridge_kit_cli: ^0.1.3
```

## drift-check Command

The `drift-check` command detects when your Dart bridge contract drifts out of sync with your native handler implementations.

### Usage

```bash
dart run native_bridge_kit_cli:drift_check [options]
```

The command is also available as a subcommand of the package entrypoint:

```bash
dart run native_bridge_kit_cli:native_bridge_kit_cli drift-check [options]
```

### Options

```
--project-root <path>     Project root used for auto-discovery (default: current directory)
--platform <platform>     Platform to check: android, ios, or all (default: all)
--contract <path>         Path to Dart contract file (default: auto-detect)
--handler <path>          Path to Kotlin/Swift handler file (default: auto-detect)
--android-handler <path>  Path to the Android Kotlin handler
--ios-handler <path>      Path to the iOS Swift handler
--json                    Output results as JSON (default: human-readable)
--fail-on-drift           Exit with code 1 if drift is detected (for CI/CD)
--help                    Show command help
```

### Examples

**Check both Android and iOS:**
```bash
dart run native_bridge_kit_cli:drift_check
```

**Check only Android:**
```bash
dart run native_bridge_kit_cli:drift_check --platform android
```

**Check with specific files:**
```bash
dart run native_bridge_kit_cli:drift_check \
  --contract lib/native/device_bridge.dart \
  --android-handler android/app/src/main/kotlin/com/example/app/DeviceHandler.kt \
  --ios-handler ios/Runner/DeviceHandler.swift
```

**Get JSON output for CI integration:**
```bash
dart run native_bridge_kit_cli:drift_check --json --fail-on-drift
```

### Output

**Human-readable format:**
```
✓ Bridge contracts and handlers are in sync

Contract methods:
  - getModel() -> Future<String>
  - getBatteryLevel() -> Future<int>
  - batteryUpdates -> Stream<int>

Android handler: ✓ All methods found
iOS handler: ✓ All methods found
```

**With drift (human-readable):**
```
✗ Drift detected between contract and handlers

Issues:
  - Android: Missing method 'getBatteryLevel'
  - iOS: Extra method 'getTemperature' (not in contract)
```

**JSON format:**
```json
{
  "in_sync": false,
  "issues": [
    {
      "type": "missing_method",
      "platform": "android",
      "method": "getBatteryLevel",
      "message": "Method defined in contract but not found in handler"
    },
    {
      "type": "extra_method",
      "platform": "ios",
      "method": "getTemperature",
      "message": "Method found in handler but not defined in contract"
    }
  ]
}
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Drift Check

on: [pull_request]

jobs:
  drift-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart run native_bridge_kit_cli:drift_check --json --fail-on-drift
```

### Success
- Exit code **0**: Contracts and handlers are in sync
- Exit code **1**: Drift detected (with `--fail-on-drift`)

## How It Works

1. **Parse Dart Contract**: Extracts method signatures from `@NativeBridge` class
2. **Parse Handlers**: Reads Kotlin and/or Swift handler files
3. **Compare Methods**: Checks if all contract methods have corresponding handler methods
4. **Report Results**: Displays in-sync status and any drift issues

## Common Issues

**"Contract file not found"**
- Ensure your contract file is named `*_bridge.dart` or ends with `_bridge.dart`
- Specify the path explicitly with `--contract` flag

**"No handlers found"**
- Check that your handler files are in expected Android/iOS directories
- Specify paths explicitly with `--handler` flag

**False positives on method names**
- The checker normalizes names to snake_case
- Ensure your Kotlin/Swift methods follow naming conventions
- Use exact method names from your contract

## Advanced Usage

### Custom Configuration

Create a `drift_check.yaml` config file in your project root:

```yaml
contract_path: lib/native/services/my_bridge.dart
android_handler_path: android/app/src/main/kotlin/com/example/MyHandler.kt
ios_handler_path: ios/Runner/MyHandler.swift
```

Then run without path arguments:
```bash
dart run native_bridge_kit_cli:drift_check
```

## Troubleshooting

**Check fails but code looks correct?**
- Run with `--json` for detailed error information
- Ensure your contract file has `@NativeBridge()` annotation
- Verify handler method names match (case-sensitive except for case conversion)

**Want to skip drift-check for now?**
- You can still run without the `--fail-on-drift` flag locally
- For CI/CD enforcement, add the flag to your workflows

## API Reference

For complete API details, see [API Reference Guide](../docs/api-reference.md).

## Next Steps

- **Getting Started?** See [Getting Started Guide](../docs/getting-started.md)
- **Testing?** See [Testing Guide](../docs/testing-guide.md)
- **Examples?** See [Example Project](../examples/device-info-app)

---

[← Back to Root README](../README.md)
