## ADDED Requirements

### Requirement: Casual user imports only `native_bridge_kit` runtime package
A user who wants the full native_bridge_kit runtime experience (annotations + transport + mock) SHALL only need to add `native_bridge_kit: ^x.y.z` to their `dependencies`. The `native_bridge_kit_annotation` package SHALL be available as a transitive dependency without a direct `pubspec.yaml` entry.

#### Scenario: Runtime import resolves annotations transitively
- **WHEN** a user adds only `native_bridge_kit: ^0.1.0` to their `dependencies`
- **THEN** `@NativeBridge`, `@NativeMethod`, and `@NativeStream` annotations are importable via `package:native_bridge_kit/native_bridge_kit.dart` without adding `native_bridge_kit_annotation` explicitly

#### Scenario: Power user can still import annotation package directly
- **WHEN** a pure-Dart (non-Flutter) consumer adds `native_bridge_kit_annotation: ^0.1.0` to their `dependencies` without `native_bridge_kit`
- **THEN** all three annotation classes compile and function correctly with no Flutter dependency in the resolution graph

### Requirement: Casual user imports only `native_bridge_kit_gen` to get all code generators
A user who wants Dart + Kotlin + Swift code generation SHALL only need to add `native_bridge_kit_gen: ^x.y.z` to their `dev_dependencies`. All three generators (`.g.dart`, `.g.kt`, `.g.swift`) SHALL be produced on the next `build_runner build` invocation.

#### Scenario: Single gen package triggers all three output types
- **WHEN** a user adds `native_bridge_kit_gen: ^0.1.0` and runs `flutter pub run build_runner build`
- **THEN** a `.g.dart` Dart implementation file is generated
- **THEN** a `.g.kt` Kotlin handler stub is generated
- **THEN** a `.g.swift` Swift handler stub is generated

#### Scenario: Power user adds only Android generator
- **WHEN** a user adds `native_bridge_kit_dart_gen: ^0.1.0` and `native_bridge_kit_android_gen: ^0.1.0` (without `native_bridge_kit_gen`)
- **THEN** only `.g.dart` and `.g.kt` files are generated; no `.g.swift` is produced

#### Scenario: Power user adds only iOS generator
- **WHEN** a user adds `native_bridge_kit_dart_gen: ^0.1.0` and `native_bridge_kit_ios_gen: ^0.1.0` (without `native_bridge_kit_gen`)
- **THEN** only `.g.dart` and `.g.swift` files are generated; no `.g.kt` is produced

### Requirement: `native_bridge_kit_dart_gen` package exists as the Dart-only generator
A package named `native_bridge_kit_dart_gen` SHALL be published on pub.dev and SHALL contain the code generator that produces `.g.dart` implementation files from `@NativeBridge`-annotated Dart classes.

#### Scenario: Dart gen package produces correct output independently
- **WHEN** a project depends only on `native_bridge_kit_dart_gen` (no android/ios gen)
- **THEN** `build_runner build` produces `.g.dart` files with correct `_$ClassName` implementations
- **THEN** no Kotlin or Swift files are generated

### Requirement: `native_bridge_kit_gen` facade package aggregates all generators
The `native_bridge_kit_gen` package on pub.dev SHALL be a facade that declares `native_bridge_kit_dart_gen`, `native_bridge_kit_android_gen`, and `native_bridge_kit_ios_gen` as its `dependencies` (not `dev_dependencies`) so that all three are transitively resolved when a user adds `native_bridge_kit_gen` to their `dev_dependencies`.

#### Scenario: Facade has no source code of its own
- **WHEN** a developer inspects the `native_bridge_kit_gen` package
- **THEN** it contains no generator source files of its own — only a `pubspec.yaml` with the three sub-generator dependencies

#### Scenario: build_runner discovers all builders through facade
- **WHEN** `native_bridge_kit_gen` is the only generator package listed in `dev_dependencies`
- **THEN** `build_runner` resolves and applies all three `build.yaml` builder definitions from the sub-packages automatically
