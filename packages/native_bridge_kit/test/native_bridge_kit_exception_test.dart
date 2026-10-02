import 'package:flutter_test/flutter_test.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';

void main() {
  group('NativeBridgeException', () {
    test('carries code, message, and details', () {
      const ex = NativeBridgeException(
        code: 'ERR_001',
        message: 'Something went wrong',
        details: {'hint': 'check_permissions'},
      );
      expect(ex.code, 'ERR_001');
      expect(ex.message, 'Something went wrong');
      expect((ex.details as Map)['hint'], 'check_permissions');
    });

    test('message and details are optional', () {
      const ex = NativeBridgeException(code: 'MINIMAL');
      expect(ex.code, 'MINIMAL');
      expect(ex.message, isNull);
      expect(ex.details, isNull);
    });

    test('toString includes all fields', () {
      const ex = NativeBridgeException(
        code: 'ERR',
        message: 'oops',
        details: 'extra',
      );
      final s = ex.toString();
      expect(s, contains('ERR'));
      expect(s, contains('oops'));
      expect(s, contains('extra'));
    });

    test('implements Exception so it can be caught generically', () {
      expect(
        () => throw const NativeBridgeException(code: 'X'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
