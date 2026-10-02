## 1. Create `native_bridge_kit_dart_gen` Package

- [x] 1.1 Create `packages/native_bridge_kit_dart_gen/` directory with the full package structure (`lib/src/`, `test/`)
- [x] 1.2 Create `packages/native_bridge_kit_dart_gen/pubspec.yaml` (copy from current `native_bridge_kit_gen/pubspec.yaml`, update `name` to `native_bridge_kit_dart_gen` and `description`)
- [x] 1.3 Copy `packages/native_bridge_kit_gen/lib/builder.dart` → `packages/native_bridge_kit_dart_gen/lib/builder.dart`
- [x] 1.4 Copy `packages/native_bridge_kit_gen/lib/src/native_bridge_kit_generator.dart` → `packages/native_bridge_kit_dart_gen/lib/src/native_bridge_kit_generator.dart`
- [x] 1.5 Copy `packages/native_bridge_kit_gen/lib/src/utils.dart` → `packages/native_bridge_kit_dart_gen/lib/src/utils.dart`
- [x] 1.6 Copy `packages/native_bridge_kit_gen/build.yaml` → `packages/native_bridge_kit_dart_gen/build.yaml`
- [x] 1.7 Copy existing tests from `packages/native_bridge_kit_gen/test/` to `packages/native_bridge_kit_dart_gen/test/`
- [x] 1.8 Run `dart pub get` inside `packages/native_bridge_kit_dart_gen/` and verify it resolves cleanly

## 2. Repurpose `native_bridge_kit_gen` as Facade

- [x] 2.1 Delete all source files from `packages/native_bridge_kit_gen/lib/` (generator source is now in `native_bridge_kit_dart_gen`)
- [x] 2.2 Delete `packages/native_bridge_kit_gen/build.yaml` (builders are declared in sub-packages)
- [x] 2.3 Rewrite `packages/native_bridge_kit_gen/pubspec.yaml` as the facade: add `native_bridge_kit_dart_gen`, `native_bridge_kit_android_gen`, `native_bridge_kit_ios_gen` as `dependencies`
- [x] 2.4 Create a minimal `packages/native_bridge_kit_gen/lib/native_bridge_kit_gen.dart` library file with a doc comment explaining it is a convenience facade
- [x] 2.5 Update `packages/native_bridge_kit_gen/README.md` to explain the facade role and list the sub-packages

## 3. Update `native_bridge_kit` Runtime to Absorb Annotation

- [x] 3.1 Add `native_bridge_kit_annotation: ^0.1.0` (path reference for local dev) to `dependencies` in `packages/native_bridge_kit/pubspec.yaml`
- [x] 3.2 Re-export annotations from `packages/native_bridge_kit/lib/native_bridge_kit.dart` (add `export 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';`)
- [x] 3.3 Run `dart pub get` inside `packages/native_bridge_kit/` and verify resolution

## 4. Promote `native_bridge_kit_cli` to Global Tool

- [x] 4.1 Remove `publish_to: none` from `packages/native_bridge_kit_cli/pubspec.yaml`
- [x] 4.2 Add an `executables` section to `packages/native_bridge_kit_cli/pubspec.yaml` mapping `drift_check` to its bin entry point
- [x] 4.3 Verify `packages/native_bridge_kit_cli/bin/` contains the correct entry file referenced by the executable
- [x] 4.4 Run `dart pub get` inside `packages/native_bridge_kit_cli/` and verify it resolves cleanly

## 5. Update Root and Example `pubspec.yaml` Files

- [x] 5.1 Update root `pubspec.yaml`: replace `native_bridge_kit_annotation` direct dep with path reference inside `native_bridge_kit` dep (remove standalone `native_bridge_kit_annotation` entry from `dependencies`)
- [x] 5.2 Update root `pubspec.yaml` dev_dependencies: replace `native_bridge_kit_gen`, `native_bridge_kit_android_gen`, `native_bridge_kit_ios_gen` with single `native_bridge_kit_gen` (facade) path reference; replace `native_bridge_kit_dart_gen` path reference
- [x] 5.3 Update `examples/device-info-app/pubspec.yaml`: apply the same 2-import pattern (`native_bridge_kit` only in deps, `native_bridge_kit_gen` only in dev_deps)
- [x] 5.4 Run `flutter pub get` from the root project and verify clean resolution
- [x] 5.5 Run `flutter pub get` from `examples/device-info-app/` and verify clean resolution

## 6. Verify Code Generation End-to-End

- [x] 6.1 Run `flutter pub run build_runner clean` then `flutter pub run build_runner build` from the root project
- [x] 6.2 Confirm `.g.dart` file is generated correctly for `lib/native/device_info_bridge.dart`
- [x] 6.3 Confirm `.g.kt` Kotlin stub is generated correctly
- [x] 6.4 Confirm `.g.swift` Swift stub is generated correctly
- [x] 6.5 Run `flutter test` from the root project and confirm all tests pass
- [x] 6.6 Run `flutter pub run build_runner build` from `examples/device-info-app/` and confirm all three output files are generated

## 7. Update Documentation

- [x] 7.1 Update `README.md` Installation section to show the 2-import pattern (`native_bridge_kit` + `native_bridge_kit_gen`)
- [x] 7.2 Update `docs/installation.md` setup section to reflect the new imports and remove `native_bridge_kit_annotation`, `native_bridge_kit_android_gen`, `native_bridge_kit_ios_gen` from the standard setup block
- [x] 7.3 Add a "Power Users" section to `docs/installation.md` showing how to import sub-packages individually (Android-only, iOS-only, pure-Dart)
- [x] 7.4 Add a "CLI Tool" section to `docs/installation.md` documenting `dart pub global activate native_bridge_kit_cli` and `drift_check` usage
- [x] 7.5 Update `examples/device-info-app/README.md` setup instructions to reflect the new 2-import pattern
