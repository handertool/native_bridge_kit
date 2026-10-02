# native_bridge_kit_gen

One development dependency that provides the Native Bridge Kit generators.

This package is kept private for the initial release and will be published later.

## Overview

`native_bridge_kit_gen` is a facade package that aggregates:
- [`native_bridge_kit_dart_gen`](../native_bridge_kit_dart_gen/): Generates `.g.dart` Dart implementation files
- [`native_bridge_kit_android_gen`](../native_bridge_kit_android_gen/): Generates `.g.kt` Kotlin handler stubs
- [`native_bridge_kit_ios_gen`](../native_bridge_kit_ios_gen/): Generates `.g.swift` Swift handler stubs

It contains no generator source of its own. When `build_runner` resolves this package's dependencies, all three generators' `build.yaml` files are discovered and applied automatically.

## Installation

```yaml
dependencies:
  native_bridge_kit: ^0.1.0          # runtime + annotations

dev_dependencies:
  build_runner: ^2.4.0
  native_bridge_kit_gen: ^0.1.0      # all generators in one line
```

### Use individual generators

If you only target one platform:

```yaml
# Android only
dev_dependencies:
  build_runner: ^2.4.0
  native_bridge_kit_dart_gen: ^0.1.0
  native_bridge_kit_android_gen: ^0.1.0

# iOS only
dev_dependencies:
  build_runner: ^2.4.0
  native_bridge_kit_dart_gen: ^0.1.0
  native_bridge_kit_ios_gen: ^0.1.0
```

## Usage

After setup, run code generation:

```bash
flutter pub run build_runner build
```

This generates:
- `*.g.dart` — Dart bridge implementation
- `*.g.kt` — Kotlin Android handler stubs
- `*.g.swift` — Swift iOS handler stubs

For usage details, see the [Getting Started Guide](../../docs/getting-started.md) and the [Example Project](../../examples/device-info-app).

## Sub-packages

| Package | Output | Use directly when... |
|---|---|---|
| [`native_bridge_kit_dart_gen`](../native_bridge_kit_dart_gen/) | `.g.dart` | You need Dart gen only |
| [`native_bridge_kit_android_gen`](../native_bridge_kit_android_gen/) | `.g.kt` | Android-only project |
| [`native_bridge_kit_ios_gen`](../native_bridge_kit_ios_gen/) | `.g.swift` | iOS-only project |

## Need Help?

- **[Getting Started Guide](../../docs/getting-started.md)** — contract and generation walkthrough
- **[Troubleshooting](../../docs/troubleshooting.md)** — Common issues and solutions
- **[Example Project](../../examples/device-info-app)** — Complete working example

---

[← Back to Root README](../../README.md)
