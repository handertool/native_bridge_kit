import 'dart:async';

import 'package:flutter/material.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';

import 'native/device_info_bridge.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.transport});

  final BridgeTransport? transport;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'native_bridge_kit Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: DeviceInfoPage(transport: transport),
    );
  }
}

/// Demo page that calls [DeviceInfoBridge] methods via the generated
/// [_$DeviceInfoBridge] implementation and a [MethodChannelTransport].
///
/// On a real device the native handler returns live data; in this demo the
/// [NativeBridgeException] is caught gracefully so the app still runs in the
/// simulator / hot-reload without any native implementation wired up yet.
class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key, this.transport});

  final BridgeTransport? transport;

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  // ── Bridge instance ─────────────────────────────────────────────────────────
  // Swap MethodChannelTransport() for any other BridgeTransport without
  // touching this class — or inject MockBridgeTransport in tests.
  late final DeviceInfoBridge _bridge = DeviceInfoBridge(
    widget.transport ?? MethodChannelTransport(),
  );
  StreamSubscription<double>? _batterySubscription;

  String _model = '—';
  String _osVersion = '—';
  String _batteryStatus = '—';

  @override
  void initState() {
    super.initState();
    _fetchInfo();
    _subscribeBattery();
  }

  Future<void> _fetchInfo() async {
    try {
      final model = await _bridge.getModel();
      final os = await _bridge.getOsVersion();
      if (mounted) {
        setState(() {
          _model = model ?? 'null';
          _osVersion = os ?? 'null';
        });
      }
    } on NativeBridgeException catch (e) {
      // Native handler not registered yet — surface the error code in the UI.
      if (mounted) {
        setState(() {
          _model = 'NativeBridgeException: ${e.code}';
          _osVersion = e.message ?? '—';
        });
      }
    }
  }

  void _subscribeBattery() {
    _batterySubscription = _bridge.batteryLevel().listen(
      (level) {
        if (mounted) {
          setState(() => _batteryStatus = '${level.toStringAsFixed(1)}%');
        }
      },
      onError: (Object err) {
        if (mounted) {
          setState(
            () => _batteryStatus = err is NativeBridgeException
                ? 'err: ${err.code}'
                : '$err',
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _batterySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('native_bridge_kit Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _InfoTile(label: 'Model', value: _model),
            const SizedBox(height: 16),
            _InfoTile(label: 'OS Version', value: _osVersion),
            const SizedBox(height: 16),
            _InfoTile(label: 'Battery Level', value: _batteryStatus),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchInfo,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}
