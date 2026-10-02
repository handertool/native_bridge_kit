## Why

Consuming the `native_bridge_kit` ecosystem currently requires adding 6 separate entries to `pubspec.yaml` — a poor developer experience that creates unnecessary friction for new adopters. The package split was driven by separation-of-concerns principles, but those concerns can be preserved *internally* while presenting a much simpler surface to users, exactly as the `in_app_purchase` ecosystem does with its facade pattern.

## What Changes

- **NEW** `native_bridge_kit_dart_gen` package: rename/split the current `native_bridge_kit_gen` to own only the Dart `.g.dart` generation, freeing `native_bridge_kit_gen` to become the facade.
- **NEW** `native_bridge_kit_gen` (facade): a new package whose sole job is to depend on `native_bridge_kit_dart_gen`, `native_bridge_kit_android_gen`, and `native_bridge_kit_ios_gen`, so that one `dev_dependency` entry pulls in all three generators.
- **UPDATED** `native_bridge_kit` (runtime): add `native_bridge_kit_annotation` as a transitive `dependency` so users only need to import `native_bridge_kit` to get both the runtime and the annotations.
- **UPDATED** `native_bridge_kit_cli`: remove `publish_to: none`, publish to pub.dev as a standalone global tool. Users activate via `dart pub global activate native_bridge_kit_cli` instead of adding it to `dev_dependencies`.
- **UPDATED** `native_bridge_kit_annotation`: remains a separate published package for power users (pure-Dart consumers, custom tooling) who need annotations without the Flutter runtime.
- **UPDATED** `native_bridge_kit_android_gen` and `native_bridge_kit_ios_gen`: remain separate published packages for power users who target a single platform.
- **UPDATED** documentation and example `pubspec.yaml` files to reflect the new 2-import experience.

## Capabilities

### New Capabilities

- `package-facade`: A new `native_bridge_kit_gen` facade package that aggregates all three code generators behind a single `dev_dependency`, plus the `native_bridge_kit` runtime absorbing `native_bridge_kit_annotation` as a transitive dep — enabling the 2-import casual-user experience.
- `cli-global-tool`: Promotion of `native_bridge_kit_cli` from a `dev_dependency` to a published global Dart tool activated via `dart pub global activate`.

### Modified Capabilities

<!-- No existing spec-level behavior changes — this is purely a packaging restructure. -->

## Impact

- **packages/native_bridge_kit/pubspec.yaml**: add `native_bridge_kit_annotation` to `dependencies`.
- **packages/native_bridge_kit_gen/**: repurposed as the facade; its current generator source moves to a new `packages/native_bridge_kit_dart_gen/` package.
- **packages/native_bridge_kit_dart_gen/**: new package containing the Dart `.g.dart` generator (moved from current `native_bridge_kit_gen`).
- **packages/native_bridge_kit_android_gen/pubspec.yaml** and **native_bridge_kit_ios_gen/pubspec.yaml**: no logic changes; updated to reference `native_bridge_kit` instead of `native_bridge_kit_annotation` for their annotation dep.
- **packages/native_bridge_kit_cli/pubspec.yaml**: `publish_to: none` removed; executables section added.
- **Root and example `pubspec.yaml`**: updated to use the new 2-import pattern.
- **docs/installation.md** and **README.md**: updated setup instructions.
- No breaking changes to the public Dart API or generated code — purely a packaging restructure.
