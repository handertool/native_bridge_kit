# Contributing

## Development setup

1. Install the Flutter version declared in `.tool-versions`.
2. Run `flutter pub get` at the repository root.
3. Run `flutter pub run build_runner build --delete-conflicting-outputs` when changing a bridge contract or generator.

## Validation

Before opening a change, run:

```bash
flutter analyze
flutter test
cd packages/native_bridge_kit_cli && dart test
cd ../..
dart run packages/native_bridge_kit_cli/bin/drift_check.dart \
  --project-root . --fail-on-drift
```

Platform runtime behavior should also be checked on an Android device/emulator
and an iOS simulator/device when the change affects native handlers.

## Generated files

Dart `.g.dart`, Kotlin `.g.kt`, and Swift `.g.swift` files are generated
artifacts. Kotlin and Swift outputs are scaffolds: platform-specific behavior
and host registration belong in the Android/iOS application sources. Regenerate
them after changing a contract and review the resulting diff.
