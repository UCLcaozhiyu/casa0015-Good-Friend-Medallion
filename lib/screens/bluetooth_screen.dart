import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../services/permission_service.dart';
import '../services/bluetooth_service.dart';
import 'dart:async';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  bool _isScanning = false;
  Map<String, BluetoothDevice> _devices = {};
  bool _hasPermissions = false;
  String _statusText = 'Ready to scan';
  double? rssiValue;
  BluetoothDevice? connectedDevice;
  String? connectedDeviceId;
  bool enableRssiHaptic = false;
  Timer? _rssiUpdateTimer;
  Timer? _reconnectTimer;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 3;

  // 可调阈值
  double closeThreshold = -60;
  double midThreshold = -80;
  final double rssiMin = -100;
  final double rssiMax = -30;

  DateTime? _lastRssiUpdate;
  static const Duration rssiUpdateInterval = Duration(milliseconds: 500);
  DateTime? _lastUiUpdate;
  static const Duration uiUpdateInterval = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final hasPermissions = await PermissionService.requestPermissions();
    setState(() {
      _hasPermissions = hasPermissions;
    });
    
    if (!hasPermissions) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'This app needs Bluetooth permissions to function properly. '
          'Please grant the required permissions in the app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void resetThresholds() {
    setState(() {
      closeThreshold = -60;
      midThreshold = -80;
    });
  }

  Future<void> _startScanning() async {
    if (!_hasPermissions) {
      _showPermissionDialog();
      return;
    }

    setState(() {
      _isScanning = true;
      _statusText = 'Scanning...';
      _devices.clear();
    });

    await BluetoothManager.startScanning();
    setState(() {
      // Filter out devices without a name
      _devices = Map.fromEntries(
        BluetoothManager.getDiscoveredDevices().entries.where(
          (entry) => entry.value.name.isNotEmpty,
        ),
      );
      _isScanning = false;
      _statusText = 'Found ${_devices.length} devices';
    });
  }

  void startConnectedRssiListener() {
    _rssiUpdateTimer?.cancel();

    _rssiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (connectedDevice != null) {
        final now = DateTime.now();
        if (_lastRssiUpdate == null || 
            now.difference(_lastRssiUpdate!) >= rssiUpdateInterval) {
          final rssi = await BluetoothManager.getRssi(connectedDevice!);
          if (rssi != null) {
            _lastRssiUpdate = now;
            if (mounted) {
              setState(() {
                rssiValue = rssi;
              });
            }

            if (enableRssiHaptic) {
              if (rssi > closeThreshold) {
                HapticFeedback.heavyImpact();
              } else if (rssi > midThreshold) {
                HapticFeedback.mediumImpact();
              } else {
                HapticFeedback.lightImpact();
              }
            }
          }
        }
      }
    });
  }

  void _updateStatusText(String text) {
    final now = DateTime.now();
    if (_lastUiUpdate == null || 
        now.difference(_lastUiUpdate!) >= uiUpdateInterval) {
      _lastUiUpdate = now;
      if (mounted) {
        setState(() {
          _statusText = text;
        });
      }
    }
  }

  void _startReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (connectedDevice != null && !_isReconnecting && _reconnectAttempts < maxReconnectAttempts) {
        _isReconnecting = true;
        _reconnectAttempts++;
        
        try {
          await connectedDevice!.connect();
          _isReconnecting = false;
          _reconnectAttempts = 0;
          _updateStatusText('✅ Reconnected to ${connectedDevice!.name}');
          HapticFeedback.heavyImpact();
        } catch (e) {
          _isReconnecting = false;
          _updateStatusText('⚠️ Reconnection attempt $_reconnectAttempts failed');
          HapticFeedback.mediumImpact();
        }
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      _updateStatusText('Connecting to ${device.name}...');

      await device.connect();
      connectedDevice = device;
      connectedDeviceId = device.remoteId.str;
      enableRssiHaptic = true;
      _reconnectAttempts = 0;
      
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _updateStatusText('⚠️ Device disconnected, attempting to reconnect...');
          _startReconnectTimer();
        }
      });

      startConnectedRssiListener();
      _startReconnectTimer();

      _updateStatusText('✅ Connected to ${device.name}');
      HapticFeedback.heavyImpact();
    } catch (e) {
      _updateStatusText('❌ Connection failed: $e');
      HapticFeedback.mediumImpact();
    }
  }

  Widget buildRssiMeter() {
    if (rssiValue == null) return const Text("🔍 No device nearby.");

    double normalized = ((rssiValue! - rssiMin) / (rssiMax - rssiMin)).clamp(0.0, 1.0);
    String label;
    TextStyle style = const TextStyle(fontSize: 32);

    if (rssiValue! > closeThreshold) {
      label = "🔥 Very Close!";
    } else if (rssiValue! > midThreshold) {
      label = "🙂 Nearby";
    } else {
      label = "👀 Far";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label (RSSI: ${rssiValue!.toStringAsFixed(1)} dBm)", style: style),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: normalized,
          minHeight: 10,
          backgroundColor: Colors.grey.shade800,
          color: Colors.greenAccent,
        ),
      ],
    );
  }

  Widget buildThresholdSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("📏 RSSI Thresholds (adjust to fine-tune)"),
        Text("🔥 Very Close > $closeThreshold dBm"),
        Slider(
          value: closeThreshold,
          min: -80,
          max: -50,
          divisions: 30,
          label: closeThreshold.toStringAsFixed(0),
          onChanged: (val) {
            setState(() => closeThreshold = val);
          },
        ),
        Text("🙂 Nearby > $midThreshold dBm"),
        Slider(
          value: midThreshold,
          min: -90,
          max: closeThreshold - 1,
          divisions: 40,
          label: midThreshold.toStringAsFixed(0),
          onChanged: (val) {
            setState(() => midThreshold = val);
          },
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: resetThresholds,
            child: const Text("重置默认值"),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _statusText,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          ElevatedButton(
            onPressed: _isScanning ? null : _startScanning,
            child: Text(_isScanning ? 'Scanning...' : 'Scan for Devices'),
          ),
          buildRssiMeter(),
          buildThresholdSlider(),
          Expanded(
            child: ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                final device = _devices.values.elementAt(index);
                return ListTile(
                  title: Text(device.name.isEmpty ? 'Unknown Device' : device.name),
                  subtitle: Text(device.remoteId.toString()),
                  trailing: IconButton(
                    icon: const Icon(Icons.bluetooth_connected),
                    onPressed: () => _connectToDevice(device),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rssiUpdateTimer?.cancel();
    _reconnectTimer?.cancel();
    connectedDevice?.disconnect();
    FlutterBluePlus.stopScan();
    super.dispose();
  }
} 