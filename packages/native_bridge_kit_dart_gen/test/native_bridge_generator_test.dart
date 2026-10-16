import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:native_bridge_kit_dart_gen/native_bridge_kit_dart_gen.dart';
import 'package:test/test.dart';

void main() {
  test('generates explicit method and stream wire names', () async {
    await testBuilder(
      nativeBridgeBuilder(const BuilderOptions({})),
      {
        'a|lib/fixture.dart': '''
          import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';
          part 'fixture.g.dart';

          @NativeBridge(channelPrefix: 'fixture')
          abstract class FixtureBridge {
            @NativeMethod(name: 'custom_method')
            Future<String> getModel();

            @NativeStream(name: 'event-feed')
            Stream<int> events();

            Future<String> getDefaultModel();

            Stream<int> defaultEvents();
          }
        ''',
      },
      reader: await PackageAssetReader.currentIsolate(),
      outputs: {
        'a|lib/fixture.native_bridge_kit.g.part': decodedMatches(
          allOf(
            contains("'fixture', 'custom_method'"),
            contains("'fixture/event-feed'"),
            contains("'fixture', 'get_default_model'"),
            contains("'fixture/default_events'"),
          ),
        ),
      },
    );
  });

  test('rejects unsupported return types during generation', () async {
    await expectLater(
      testBuilder(nativeBridgeBuilder(const BuilderOptions({})), {
        'a|lib/fixture.dart': '''
            import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';
            part 'fixture.g.dart';

            @NativeBridge()
            abstract class FixtureBridge {
              String getModel();
            }
          ''',
      }, reader: await PackageAssetReader.currentIsolate()),
      throwsA(
        predicate(
          (error) => error.toString().contains('unsupported return type'),
        ),
      ),
    );
  });

  test('rejects stream parameters during generation', () async {
    await expectLater(
      testBuilder(nativeBridgeBuilder(const BuilderOptions({})), {
        'a|lib/fixture.dart': '''
            import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';
            part 'fixture.g.dart';

            @NativeBridge()
            abstract class FixtureBridge {
              Stream<int> events({required String source});
            }
          ''',
      }, reader: await PackageAssetReader.currentIsolate()),
      throwsA(
        predicate(
          (error) =>
              error.toString().contains('Stream arguments are not supported'),
        ),
      ),
    );
  });
}
