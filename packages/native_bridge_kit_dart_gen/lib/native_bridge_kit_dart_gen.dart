/// Dart builder for Android and iOS native bridge contracts.
///
/// Register [nativeBridgeBuilder] with `build_runner` to generate Dart bridge
/// implementations from annotated contracts.
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/native_bridge_kit_generator.dart';

/// The [Builder] factory registered in `build.yaml`.
///
/// Uses [SharedPartBuilder] so multiple generators can contribute to the same
/// `.g.dart` part file (ready for Phase 2 additions without breaking changes).
Builder nativeBridgeBuilder(BuilderOptions options) =>
    SharedPartBuilder([NativeBridgeGenerator()], 'native_bridge_kit');
