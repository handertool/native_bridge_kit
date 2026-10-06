/// Android/Kotlin builder for native bridge contracts.
///
/// Register [kotlinBridgeBuilder] with `build_runner` to generate Kotlin
/// handler scaffolds for Android.
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/kotlin_bridge_generator.dart';

/// Android/Kotlin code generator builder factory.
///
/// Uses a raw [Builder] (not SharedPartBuilder) so the Kotlin output is written
/// directly to a `.g.kt` file without passing through dart_style formatting.
Builder kotlinBridgeBuilder(BuilderOptions options) => _KotlinBridgeBuilder();

class _KotlinBridgeBuilder implements Builder {
  @override
  final buildExtensions = const {
    '.dart': ['.g.kt']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) return;
    final library = LibraryReader(await buildStep.inputLibrary);
    final generator = KotlinBridgeGenerator();
    final output = await generator.generate(library, buildStep);
    if (output.trim().isEmpty) return;
    await buildStep.writeAsString(
      buildStep.inputId.changeExtension('.g.kt'),
      output,
    );
  }
}
