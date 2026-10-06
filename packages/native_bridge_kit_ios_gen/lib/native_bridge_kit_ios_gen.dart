/// iOS/Swift builder for native bridge contracts.
///
/// Register [swiftBridgeBuilder] with `build_runner` to generate Swift
/// handler scaffolds for iOS.
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'src/swift_bridge_generator.dart';

/// iOS/Swift code generator builder factory.
///
/// Uses a raw [Builder] (not SharedPartBuilder) so the Swift output is written
/// directly to a `.g.swift` file without passing through dart_style formatting.
Builder swiftBridgeBuilder(BuilderOptions options) => _SwiftBridgeBuilder();

class _SwiftBridgeBuilder implements Builder {
  @override
  final buildExtensions = const {
    '.dart': ['.g.swift']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!await buildStep.resolver.isLibrary(buildStep.inputId)) return;
    final library = LibraryReader(await buildStep.inputLibrary);
    final generator = SwiftBridgeGenerator();
    final output = await generator.generate(library, buildStep);
    if (output.trim().isEmpty) return;
    await buildStep.writeAsString(
      buildStep.inputId.changeExtension('.g.swift'),
      output,
    );
  }
}
