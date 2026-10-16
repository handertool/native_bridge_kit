import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:native_bridge_kit_android_gen/native_bridge_kit_android_gen.dart';
import 'package:test/test.dart';

void main() {
  test('generates explicit method and stream wire names', () async {
    await testBuilder(
      kotlinBridgeBuilder(const BuilderOptions({})),
      {
        'a|lib/fixture.dart': '''
          import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';

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
        'a|lib/fixture.g.kt': decodedMatches(
          allOf(
            contains('"custom_method" -> handleGet_model'),
            contains('"fixture/event-feed"'),
            contains('"get_default_model" -> handleGet_default_model'),
            contains('"fixture/default_events"'),
          ),
        ),
      },
    );
  });

  test('rejects unsupported return types during generation', () async {
    await expectLater(
      testBuilder(
        kotlinBridgeBuilder(const BuilderOptions({})),
        {
          'a|lib/fixture.dart': '''
            import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';

            @NativeBridge()
            abstract class FixtureBridge {
              String getModel();
            }
          ''',
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(
        predicate(
          (error) => error.toString().contains('unsupported return type'),
        ),
      ),
    );
  });

  test('rejects stream parameters during generation', () async {
    await expectLater(
      testBuilder(
        kotlinBridgeBuilder(const BuilderOptions({})),
        {
          'a|lib/fixture.dart': '''
            import 'package:native_bridge_kit_annotation/native_bridge_kit_annotation.dart';

            @NativeBridge()
            abstract class FixtureBridge {
              Stream<int> events({required String source});
            }
          ''',
        },
        reader: await PackageAssetReader.currentIsolate(),
      ),
      throwsA(
        predicate(
          (error) =>
              error.toString().contains('Stream arguments are not supported'),
        ),
      ),
    );
  });
}
