## ADDED Requirements

### Requirement: `native_bridge_kit_cli` is published as a standalone global Dart tool
The `native_bridge_kit_cli` package SHALL be published to pub.dev with an `executables` entry so that it can be activated globally via `dart pub global activate native_bridge_kit_cli`. It SHALL NOT be required as a `dev_dependency` in application `pubspec.yaml` files.

#### Scenario: User activates drift-check globally
- **WHEN** a user runs `dart pub global activate native_bridge_kit_cli`
- **THEN** the `drift_check` executable becomes available on their PATH
- **THEN** running `drift_check` (or `dart pub global run native_bridge_kit_cli:drift_check`) validates the Dart contract against native handler stubs

#### Scenario: CLI tool is not required in pubspec.yaml
- **WHEN** a project uses `native_bridge_kit` with only `native_bridge_kit: ^0.1.0` and `native_bridge_kit_gen: ^0.1.0`
- **THEN** all build and test workflows function correctly without `native_bridge_kit_cli` in `pubspec.yaml`
- **THEN** `native_bridge_kit_cli` absence does NOT cause any build or runtime errors

#### Scenario: CI pipeline integrates drift-check via global activation
- **WHEN** a CI pipeline includes `dart pub global activate native_bridge_kit_cli` as a setup step
- **THEN** `drift_check` can be run as part of the pipeline without pinning a version in `pubspec.yaml`

### Requirement: `native_bridge_kit_cli` package declares its executable entry point
The `native_bridge_kit_cli` `pubspec.yaml` SHALL declare an `executables` section mapping the `drift_check` script name to its entry point in `bin/`.

#### Scenario: Executable metadata is present in pubspec
- **WHEN** the package is inspected on pub.dev
- **THEN** it shows a declared executable named `drift_check`
- **THEN** `dart pub global activate native_bridge_kit_cli` adds `drift_check` to the activated executables list
