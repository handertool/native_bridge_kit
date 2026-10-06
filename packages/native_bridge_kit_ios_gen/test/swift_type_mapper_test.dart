import 'package:native_bridge_kit_ios_gen/src/swift_type_mapper.dart';
import 'package:test/test.dart';

void main() {
  group('dartTypeToSwift', () {
    test('maps nullable primitives', () {
      expect(dartTypeToSwift('String?'), 'String?');
      expect(dartTypeToSwift('int?'), 'Int?');
    });

    test('maps parameterized collections', () {
      expect(dartTypeToSwift('List<String>'), '[String]');
      expect(dartTypeToSwift('List<int?>'), '[Int?]');
      expect(
          dartTypeToSwift('Map<String, List<double>>'), '[String: [Double]]');
    });

    test('unwraps asynchronous types', () {
      expect(dartTypeToSwift('Future<String?>'), 'String?');
      expect(dartTypeToSwift('Stream<int>'), 'Any');
    });

    test('falls back safely for unsupported types', () {
      expect(dartTypeToSwift('CustomType'), 'Any');
      expect(dartTypeToSwift('CustomType?'), 'Any?');
    });
  });
}
