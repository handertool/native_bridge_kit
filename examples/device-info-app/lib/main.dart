import 'package:flutter/material.dart';
import 'package:native_bridge_kit/native_bridge_kit.dart';
import 'native/device_info_bridge.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'native_bridge_kit Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const DeviceInfoScreen(),
    );
  }
}

class DeviceInfoScreen extends StatefulWidget {
  const DeviceInfoScreen({Key? key}) : super(key: key);

  @override
  State<DeviceInfoScreen> createState() => _DeviceInfoScreenState();
}

class _DeviceInfoScreenState extends State<DeviceInfoScreen> {
  late DeviceInfoBridge _bridge;

  String _model = 'Loading...';
  String _osVersion = 'Loading...';
  double _batteryLevel = 0;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<double>? _batterySubscription;

  @override
  void initState() {
    super.initState();
    // Use real MethodChannelTransport for device/simulator
    // Use MockBridgeTransport for testing (see test files)
    _bridge = DeviceInfoBridge(MethodChannelTransport());
    _loadDeviceInfo();
    _setupBatteryUpdates();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final model = await _bridge.getModel();
      final osVersion = await _bridge.getOsVersion();

      setState(() {
        _model = model ?? 'Unavailable';
        _osVersion = osVersion ?? 'Unavailable';
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading device info: $e';
        _isLoading = false;
      });
    }
  }

  void _setupBatteryUpdates() {
    _batterySubscription = _bridge.batteryLevel().listen(
      (level) {
        setState(() {
          _batteryLevel = level;
        });
      },
      onError: (e) {
        setState(() {
          _error = 'Error listening to battery updates: $e';
        });
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
        title: const Text('Device Info - native_bridge_kit Example'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadDeviceInfo,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.smartphone,
                        size: 64,
                        color: Colors.blue[300],
                      ),
                      const SizedBox(height: 24),
                      InfoCard(title: 'Model', value: _model),
                      InfoCard(title: 'OS version', value: _osVersion),
                      BatteryCard(level: _batteryLevel),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: _loadDeviceInfo,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                      const SizedBox(height: 48),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'This app demonstrates native_bridge_kit.\n'
                          'Device info is fetched via platform channels.\n'
                          'Battery level updates stream from the native side.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class BatteryCard extends StatelessWidget {
  final double level;

  const BatteryCard({Key? key, required this.level}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = level > 50
        ? Colors.green
        : level > 20
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Battery',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: level / 100,
                      minHeight: 12,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$level%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
