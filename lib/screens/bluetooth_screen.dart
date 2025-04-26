import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../services/bluetooth_service.dart';

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
      _devices = BluetoothManager.getDiscoveredDevices();
      _isScanning = false;
      _statusText = 'Found ${_devices.length} devices';
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      setState(() {
        _statusText = 'Connecting to ${device.name}...';
      });

      await device.connect();
      final rssi = await BluetoothManager.getRssi(device);
      
      if (rssi != null) {
        final distance = BluetoothManager.estimateDistance(rssi);
        setState(() {
          _statusText = 'Distance: ${distance.toStringAsFixed(2)}m';
        });
      }

      await device.disconnect();
    } catch (e) {
      setState(() {
        _statusText = 'Error connecting to device';
      });
    }
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
} 