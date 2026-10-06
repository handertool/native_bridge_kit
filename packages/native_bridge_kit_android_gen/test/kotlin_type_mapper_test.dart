import 'package:native_bridge_kit_android_gen/src/kotlin_type_mapper.dart';
import 'package:test/test.dart';

void main() {
  group('dartTypeToKotlin', () {
    test('maps nullable primitives', () {
      expect(dartTypeToKotlin('String?'), 'String?');
      expect(dartTypeToKotlin('int?'), 'Int?');
    });

    test('maps parameterized collections', () {
      expect(dartTypeToKotlin('List<String>'), 'List<String>');
      expect(dartTypeToKotlin('List<int?>'), 'List<Int?>');
      expect(dartTypeToKotlin('Map<String, List<double>>'),
          'Map<String, List<Double>>');
    });

    test('unwraps asynchronous types', () {
      expect(dartTypeToKotlin('Future<String?>'), 'String?');
      expect(dartTypeToKotlin('Stream<int>'), 'Any');
    });

    test('falls back safely for unsupported types', () {
      expect(dartTypeToKotlin('CustomType'), 'Any');
      expect(dartTypeToKotlin('CustomType?'), 'Any?');
    });
  });
}
