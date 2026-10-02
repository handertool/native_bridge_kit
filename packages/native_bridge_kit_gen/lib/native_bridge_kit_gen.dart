/// Convenience facade for the native_bridge_kit code generation ecosystem.
///
/// Adding `native_bridge_kit_gen` to your `dev_dependencies` is all you need —
/// it transitively brings in:
/// - `native_bridge_kit_dart_gen`: generates `.g.dart` Dart implementations
/// - `native_bridge_kit_android_gen`: generates `.g.kt` Kotlin handler stubs
/// - `native_bridge_kit_ios_gen`: generates `.g.swift` Swift handler stubs
///
/// **Typical setup:**
/// ```yaml
/// dependencies:
///   native_bridge_kit: ^0.1.0
///
/// dev_dependencies:
///   build_runner: ^2.4.0
///   native_bridge_kit_gen: ^0.1.0
/// ```
///
/// **Power users** who only need a specific platform can import the
/// sub-packages directly instead:
/// ```yaml
/// dev_dependencies:
///   build_runner: ^2.4.0
///   native_bridge_kit_dart_gen: ^0.1.0       # Dart only
///   native_bridge_kit_android_gen: ^0.1.0    # + Kotlin stubs
/// ```
library native_bridge_kit_gen;
