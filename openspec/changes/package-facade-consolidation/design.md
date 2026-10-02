## Context

The `native_bridge_kit` ecosystem currently ships as 6 separate pub packages. A consumer must add 6 lines to `pubspec.yaml` (2 runtime deps + 3 generator dev_deps + 1 CLI dev_dep). This was a reasonable initial separation-of-concerns split, but it produces unnecessary friction for the majority of users who just want "the whole thing".

The `in_app_purchase` package demonstrates the right pattern: internal packages keep clean separation, but a thin facade exposes a one-liner experience to casual users while power users retain the ability to depend on sub-packages directly.

A hard pub constraint shapes this design: **`dev_dependencies` do not propagate transitively**. A facade package can only bundle generator packages through its own `dependencies` (not `dev_dependencies`) — and that works because pub resolves transitive `dependencies` of a package even when that package is itself listed under `dev_dependencies`.

Current package graph:
```
native_bridge_kit_annotation  (zero deps)
native_bridge_kit             (Flutter only)
native_bridge_kit_gen         (Dart codegen → .g.dart)
native_bridge_kit_android_gen (Kotlin codegen → .g.kt)
native_bridge_kit_ios_gen     (Swift codegen → .g.swift)
native_bridge_kit_cli         (drift-check binary tool)
```

## Goals / Non-Goals

**Goals:**
- Casual users need exactly 2 `pubspec.yaml` entries: `native_bridge_kit` + `native_bridge_kit_gen`
- Power users retain the ability to import any sub-package independently (e.g., Android-only gen, annotations-only for pure-Dart consumers)
- `native_bridge_kit_cli` becomes a proper global Dart tool, not a dev_dependency
- Zero breaking changes to the public Dart API or any generated code output
- All packages remain individually published on pub.dev
- Internal code organisation (separation of concerns) is preserved

**Non-Goals:**
- Merging source code of generators (they stay in separate packages, the facade just aggregates)
- Changing generated code format or output paths
- Modifying the runtime transport API

## Decisions

### Decision 1: Rename `native_bridge_kit_gen` → `native_bridge_kit_dart_gen`, repurpose `native_bridge_kit_gen` as facade

**Rationale**: The name `native_bridge_kit_gen` is already the most natural name for "the one generator package you add". Repurposing it as the facade means existing documentation and muscle memory (`native_bridge_kit_gen`) just works. The Dart-specific generator gets a more precise name (`native_bridge_kit_dart_gen`) that is consistent with `native_bridge_kit_android_gen` and `native_bridge_kit_ios_gen`.

**Alternative considered**: Keep current `native_bridge_kit_gen` and introduce `native_bridge_kit_gen_all` as the facade. Rejected — the `_all` suffix is awkward and violates the principle that the default name should be the simple experience.

**Facade pubspec structure**:
```yaml
# packages/native_bridge_kit_gen/pubspec.yaml
name: native_bridge_kit_gen
dependencies:
  native_bridge_kit_dart_gen: ^0.1.0
  native_bridge_kit_android_gen: ^0.1.0
  native_bridge_kit_ios_gen: ^0.1.0
```

The facade itself has **no `build.yaml`** — each sub-package already declares its own builders with `auto_apply`. When pub resolves the facade's dependencies, all three `build.yaml` files are discovered automatically by `build_runner`.

### Decision 2: `native_bridge_kit` absorbs `native_bridge_kit_annotation` as a transitive dependency

**Rationale**: `native_bridge_kit_annotation` has zero dependencies and 3 tiny const classes. Adding it as a `dependency` of `native_bridge_kit` costs nothing in binary size and eliminates 1 import for 100% of Flutter users. Power users (pure-Dart, server-side) who need annotations but NOT the Flutter runtime can still import `native_bridge_kit_annotation` directly.

**Alternative considered**: Physically merge the annotation source into `native_bridge_kit`. Rejected — keeping `native_bridge_kit_annotation` as a separate published package preserves the power-user path and is cleaner to maintain.

### Decision 3: `native_bridge_kit_cli` promoted to global Dart tool

**Rationale**: `drift_check` is a project-level validation tool, conceptually identical to `melos`, `dart_code_metrics`, or `puro`. These are always activated globally, not listed in `pubspec.yaml`. Adding it as a `dev_dependency` pollutes the project's dependency graph for a tool that doesn't participate in `build_runner`.

**Activation**:
```bash
dart pub global activate native_bridge_kit_cli
drift_check  # or: dart pub global run native_bridge_kit_cli:drift_check
```

**Alternative considered**: Keep as `dev_dependency`, optionally alongside the global path. Rejected for v0.1 — clean break is better; if teams want it pinned in pubspec, that's a future opt-in.

### Decision 4: Generator sub-packages update their annotation dependency to `native_bridge_kit`

**Rationale**: `native_bridge_kit_android_gen` and `native_bridge_kit_ios_gen` currently depend on `native_bridge_kit_annotation` directly. After this change, `native_bridge_kit_annotation` remains published, so no dependency change is strictly required. However, to reduce the number of distinct packages these generators reference, they can be updated to depend on `native_bridge_kit_annotation` (unchanged) — no action needed.

Actually: generators are Dart-only tools; they must NOT depend on `native_bridge_kit` (Flutter). They keep their `native_bridge_kit_annotation` dependency as-is.

## Risks / Trade-offs

- **Rename churn**: `native_bridge_kit_gen` → `native_bridge_kit_dart_gen` is a rename of a published package. Existing users of `native_bridge_kit_gen` at `^0.1.0` will get no more updates under that name. Mitigation: publish `native_bridge_kit_gen@0.1.x` with a deprecation notice pointing to `native_bridge_kit_dart_gen`.
- **Build.yaml discovery**: relying on sub-package `build.yaml` auto-discovery means the facade has no `build.yaml` of its own. This is exactly how `build_runner` is designed to work, but it should be verified with an integration test against the example app.
- **CLI global activation in CI**: teams must add `dart pub global activate native_bridge_kit_cli` as a CI step. Mitigation: document this clearly in the CI setup guide.
- **Power user confusion**: A user who previously added `native_bridge_kit_android_gen` alone (without the facade) will see no change — that still works. But they may be confused if searching for `native_bridge_kit_gen` and finding a package with no builders. Mitigation: clear README on the facade package explaining it's an aggregator.

## Migration Plan

1. Create `packages/native_bridge_kit_dart_gen/` (copy from current `native_bridge_kit_gen/`)
2. Repurpose `packages/native_bridge_kit_gen/` as the facade (new `pubspec.yaml`, no `build.yaml`, no source)
3. Add `native_bridge_kit_annotation: ^0.1.0` to `native_bridge_kit`'s `dependencies`
4. Update `native_bridge_kit_cli/pubspec.yaml` to remove `publish_to: none`, add `executables` section
5. Update root `pubspec.yaml` and `examples/device-info-app/pubspec.yaml` to use 2-import pattern
6. Update `docs/installation.md` and root `README.md`
7. Verify with `flutter pub get` + `flutter pub run build_runner build` in the example app
8. Publish packages in order: `native_bridge_kit_annotation` → `native_bridge_kit_dart_gen` → `native_bridge_kit_android_gen` → `native_bridge_kit_ios_gen` → `native_bridge_kit` → `native_bridge_kit_gen` → `native_bridge_kit_cli`

No rollback required — old package names remain valid on pub.dev; users are not forced to migrate immediately.

## Open Questions

- Should `native_bridge_kit_gen` (facade) emit a `dart fix` deprecation hint so IDEs suggest swapping `native_bridge_kit_gen` → `native_bridge_kit_gen` (the new facade name is the same, so no action needed for existing users who were already using the right name — but `native_bridge_kit_dart_gen` is new)?
- Should CI add a step to run `dart pub global activate native_bridge_kit_cli && drift_check` automatically? Worth adding to the example app's README.
