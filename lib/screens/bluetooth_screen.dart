import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import '../services/permission_service.dart';
import '../services/bluetooth_service.dart';
import '../services/user_service.dart';
import 'qr_screen.dart';
import 'dart:async';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  State<BluetoothScreen> createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final BluetoothDeviceService _bluetoothService = BluetoothDeviceService();
  final UserService _userService = UserService();
  List<ScanResult> _foundDevices = [];
  bool _isScanning = false;
  String _scanStatus = "Not scanning";
  String _connectionStatus = "Not connected";
  String? _connectedDeviceName;
  double? _rssiValue;
  Timer? _scanTimer;
  Timer? _rssiUpdateTimer;
  Timer? _vibrationTimer;
  bool _showRssi = false;
  bool _hasPermissions = false;
  String _statusText = 'Ready to scan';
  double? rssiValue;
  BluetoothDevice? connectedDevice;
  String? connectedDeviceId;
  bool enableRssiHaptic = false;
  Timer? _reconnectTimer;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 3;

  // 可调阈值
  double closeThreshold = -50;  // 非常近
  double midThreshold = -70;    // 中等距离
  double farThreshold = -85;    // 较远
  final double rssiMin = -100;  // 最小RSSI值
  final double rssiMax = -30;   // 最大RSSI值

  DateTime? _lastRssiUpdate;
  static const Duration rssiUpdateInterval = Duration(milliseconds: 500);
  DateTime? _lastUiUpdate;
  static const Duration uiUpdateInterval = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _rssiUpdateTimer?.cancel();
    _vibrationTimer?.cancel();
    _bluetoothService.stopScan();
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool denied = statuses.values.any((status) =>
        status.isDenied || status.isPermanentlyDenied);

    if (denied) {
      if (mounted) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("权限被拒绝"),
            content: const Text("请前往系统设置中手动开启蓝牙和位置权限，否则功能无法使用。"),
        actions: [
          TextButton(
            onPressed: () {
                  openAppSettings();
              Navigator.of(context).pop();
            },
                child: const Text("打开设置"),
          ),
        ],
      ),
    );
  }
    }
  }

  void _startScan() {
    if (!mounted) return;

    setState(() {
      _isScanning = true;
      _scanStatus = "Scanning...";
      _foundDevices.clear();
      _showRssi = false;
    });

    _bluetoothService.startScan().listen((results) {
      if (!mounted) return;
      setState(() {
        // 只保留有名字的设备
        _foundDevices = results.where((r) => 
          r.device.platformName.isNotEmpty || 
          r.device.localName.isNotEmpty || 
          r.advertisementData.advName.isNotEmpty
        ).toList();
        _scanStatus = "Found ${_foundDevices.length} device(s)";
      });
    });

    _scanTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
    setState(() {
      _isScanning = false;
        _scanStatus = "Scan completed";
        _showRssi = true;
      });
      _bluetoothService.stopScan();
    });
  }

  void _startRssiMonitoring(BluetoothDevice device) {
    _rssiUpdateTimer?.cancel();
    _rssiUpdateTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      try {
        // 检查设备是否仍然连接
        if (!device.isConnected) {
          print("Device disconnected, attempting to reconnect...");
          await _bluetoothService.connectToDevice(device);
        }
        
        int rssi = await device.readRssi();
        if (!mounted) return;
        
        setState(() {
          _rssiValue = rssi.toDouble();
        });
        
        // 只有在RSSI值有效时才更新震动
        if (_rssiValue != null && _rssiValue! > rssiMin) {
          _startVibrationFeedback(_rssiValue!);
        }
        
      } catch (e) {
        print("Error reading RSSI: $e");
        _vibrationTimer?.cancel();  // 停止震动
        
        // 如果发生错误，尝试重新连接
        try {
          await _bluetoothService.connectToDevice(device);
        } catch (reconnectError) {
          print("Reconnection failed: $reconnectError");
        }
      }
    });
  }

  void _startVibrationFeedback(double rssi) {
    _vibrationTimer?.cancel();
    
    // 只在RSSI值在有效范围内时触发震动
    if (rssi <= rssiMin || rssi >= rssiMax) {
      return;
    }
    
    int vibrationInterval = _calculateVibrationInterval(rssi);
    
    _vibrationTimer = Timer.periodic(Duration(milliseconds: vibrationInterval), (timer) {
      HapticFeedback.mediumImpact();
    });
  }

  int _calculateVibrationInterval(double rssi) {
    // 使用线性插值计算震动间隔
    if (rssi >= closeThreshold) {
      return 200;  // 非常近 - 快速震动
    } else if (rssi >= midThreshold) {
      // 在closeThreshold和midThreshold之间进行线性插值
      double ratio = (rssi - midThreshold) / (closeThreshold - midThreshold);
      return 200 + ((1 - ratio) * 300).round();  // 200-500ms
    } else if (rssi >= farThreshold) {
      // 在midThreshold和farThreshold之间进行线性插值
      double ratio = (rssi - farThreshold) / (midThreshold - farThreshold);
      return 500 + ((1 - ratio) * 500).round();  // 500-1000ms
    } else {
      return 1000;  // 较远 - 慢速震动
    }
  }

  Future<void> _connectToDevice(ScanResult result) async {
    if (!mounted) return;
    
    setState(() {
      _connectionStatus = "Connecting...";
    });

    try {
      await _bluetoothService.connectToDevice(result.device);
      
      if (!mounted) return;
      setState(() {
        _connectionStatus = "Connected";
        _connectedDeviceName = result.device.name;
        _rssiValue = result.rssi.toDouble();
      });

      _startRssiMonitoring(result.device);
      _startVibrationFeedback(result.rssi.toDouble());
      
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _connectionStatus = "Connection failed: $e";
      });
      _vibrationTimer?.cancel();
    }
  }

  String _getDeviceName(ScanResult result) {
    if (result.advertisementData.advName.isNotEmpty) {
      return result.advertisementData.advName;
    }
    
    if (result.device.localName.isNotEmpty) {
      return result.device.localName;
        }
    
    if (result.device.platformName.isNotEmpty) {
      return result.device.platformName;
    }

    return result.device.remoteId.toString();
  }

  String _getDistanceCategory(double rssi) {
    if (rssi >= closeThreshold) {
      return "Very Close";
    } else if (rssi >= midThreshold) {
      return "Near";
    } else if (rssi > rssiMin) {
      return "Moderate";
    } else {
      return "Far";
    }
  }

  Widget _buildDeviceList() {
    if (_foundDevices.isEmpty) {
      return Center(
        child: Text(_isScanning ? "Scanning..." : "No devices found"),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _foundDevices.length,
      itemBuilder: (context, index) {
        final device = _foundDevices[index];
        final deviceName = _getDeviceName(device);
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(deviceName),
            subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                Text("MAC: ${device.device.remoteId}"),
                if (_showRssi) Text("RSSI: ${device.rssi} dBm"),
              ],
            ),
            trailing: ElevatedButton(
              onPressed: _isScanning ? null : () => _connectToDevice(device),
              child: const Text("Connect"),
          ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScreen()),
              );
            },
        ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text("Status: $_scanStatus"),
            const SizedBox(height: 8),
            Text("Connection: $_connectionStatus"),
            if (_connectedDeviceName != null) ...[
              const SizedBox(height: 8),
              Text("Connected to: $_connectedDeviceName"),
            ],
            if (_rssiValue != null) ...[
              const SizedBox(height: 8),
              Text("Signal Strength: ${_rssiValue!.toStringAsFixed(1)} dBm"),
              const SizedBox(height: 4),
              Text("Distance: ${_getDistanceCategory(_rssiValue!)}"),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_rssiValue! - rssiMin) / (rssiMax - rssiMin),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _rssiValue! >= closeThreshold
                      ? Colors.green
                      : _rssiValue! >= midThreshold
                          ? Colors.blue
                          : _rssiValue! >= farThreshold
                              ? Colors.orange
                              : Colors.red,
            ),
          ),
            ],
            const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _isScanning ? null : _startScan,
              child: Text(_isScanning ? "Scanning..." : "Scan"),
          ),
            const SizedBox(height: 16),
          Expanded(
              child: _buildDeviceList(),
            ),
          ],
          ),
      ),
    );
  }
} 