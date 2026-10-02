import 'package:flutter_test/flutter_test.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';
import 'package:native_bridge_kit_example/main.dart';

void main() {
  testWidgets('renders the device information page', (tester) async {
    final transport = MockBridgeTransport()
      ..stubMethodValue('device_info', 'get_model', 'Pixel 6')
      ..stubMethodValue('device_info', 'get_os_version', 'Android 14')
      ..stubStreamValue('device_info/battery_level', 75.0);

    await tester.pumpWidget(MyApp(transport: transport));
    await tester.pump();

    expect(find.text('native_bridge_kit Demo'), findsOneWidget);
    expect(find.text('Model'), findsOneWidget);
    expect(find.text('OS Version'), findsOneWidget);
    expect(find.text('Battery Level'), findsOneWidget);
    expect(find.byTooltip('Refresh'), findsOneWidget);
  });
}
