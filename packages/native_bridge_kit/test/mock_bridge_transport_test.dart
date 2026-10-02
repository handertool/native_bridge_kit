import 'package:flutter_test/flutter_test.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';

void main() {
  late MockBridgeTransport transport;

  setUp(() => transport = MockBridgeTransport());

  group('MockBridgeTransport.invoke', () {
    test('returns stubbed value', () async {
      transport.stubMethod('device_info', 'get_model', (_) => 'iPhone 99');

      final result = await transport.invoke<String>(
        'device_info',
        'get_model',
        {},
      );

      expect(result, 'iPhone 99');
    });

    test('passes named args map to the stub', () async {
      transport.stubMethod('sensor', 'read_at', (args) => args['index']);

      final result = await transport.invoke<int>('sensor', 'read_at', {
        'index': 42,
      });

      expect(result, 42);
    });

    test('returns null when stub returns null', () async {
      transport.stubMethod('device_info', 'get_model', (_) => null);

      final result = await transport.invoke<String>(
        'device_info',
        'get_model',
        {},
      );

      expect(result, isNull);
    });

    test('throws StateError for unregistered method', () {
      expect(() => transport.invoke<String>('x', 'y', {}), throwsStateError);
    });

    test('propagates NativeBridgeException thrown inside stub', () {
      transport.stubMethod('payments', 'charge', (_) {
        throw const NativeBridgeException(
          code: 'DECLINED',
          message: 'Card declined',
        );
      });

      expect(
        () => transport.invoke<void>('payments', 'charge', {'amount': 100}),
        throwsA(isA<NativeBridgeException>()),
      );
    });

    test('propagates generic exception thrown inside stub', () {
      transport.stubMethod('crash', 'boom', (_) => throw Exception('boom'));

      expect(
        () => transport.invoke<void>('crash', 'boom', {}),
        throwsException,
      );
    });
  });

  group('MockBridgeTransport.listen', () {
    test('returns stubbed stream values', () async {
      final values = [10.0, 20.0, 30.0];
      transport.stubStream(
        'device_info/battery_level',
        Stream.fromIterable(values),
      );

      final received = await transport
          .listen<double>('device_info/battery_level')
          .toList();

      expect(received, values);
    });

    test('throws StateError for unregistered stream channel', () {
      expect(
        () => transport.listen<double>('unregistered/channel'),
        throwsStateError,
      );
    });

    test('handles empty stream', () async {
      transport.stubStream('empty/channel', const Stream.empty());

      final received = await transport.listen<int>('empty/channel').toList();

      expect(received, isEmpty);
    });

    test('cast propagates stream errors', () async {
      final errorStream = Stream<dynamic>.error(
        const NativeBridgeException(code: 'STREAM_ERR'),
      );
      transport.stubStream('failing/events', errorStream);

      await expectLater(
        transport.listen<int>('failing/events'),
        emitsError(isA<NativeBridgeException>()),
      );
    });
  });
}
