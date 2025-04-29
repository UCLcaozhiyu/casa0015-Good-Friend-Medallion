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
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final BluetoothDeviceService _bluetoothService = BluetoothDeviceService();
  final UserService _userService = UserService();
  List<ScanResult> _scanResults = [];
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
  bool _isAutoScanning = false;

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

  List<Map<String, String>> _pairedDevices = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadPairedDevices();
    _startScan();
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

  Future<void> _loadPairedDevices() async {
    final devices = await BluetoothManager.getPairedDevices();
    setState(() {
      _pairedDevices = devices;
    });
  }

  Future<void> _startScan() async {
    if (!mounted) return;

    // 检查蓝牙状态
    try {
      if (!await FlutterBluePlus.isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bluetooth is not available on this device')),
        );
        return;
      }

      if (!await FlutterBluePlus.isOn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please turn on Bluetooth')),
        );
        return;
      }
    } catch (e) {
      print('Error checking Bluetooth status: $e');
      return;
    }

    setState(() {
      _isScanning = true;
      _scanStatus = "Scanning...";
      if (!_isAutoScanning) {
        _scanResults.clear();
      }
      _showRssi = false;
    });

    try {
      FlutterBluePlus.scanResults.listen((results) {
        if (!mounted) return;
        setState(() {
          if (_isAutoScanning) {
            for (var result in results) {
              if (result.device.platformName.isNotEmpty || 
                  result.device.localName.isNotEmpty || 
                  result.advertisementData.advName.isNotEmpty) {
                int existingIndex = _scanResults.indexWhere(
                  (d) => d.device.remoteId == result.device.remoteId
                );
                if (existingIndex != -1) {
                  _scanResults[existingIndex] = result;
                } else {
                  _scanResults.add(result);
                }
              }
            }
          } else {
            _scanResults = results.where((r) => 
              r.device.platformName.isNotEmpty || 
              r.device.localName.isNotEmpty || 
              r.advertisementData.advName.isNotEmpty
            ).toList();
          }
          _scanStatus = "Found ${_scanResults.length} device(s)";
        });
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    } catch (e) {
      print('Error starting scan: $e');
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanStatus = "Scan failed: $e";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start scan: $e')),
        );
      }
    }

    setState(() {
      _isScanning = false;
      _scanStatus = "Scan completed";
      _showRssi = true;
    });
  }

  void _startAutoScan() {
    _isAutoScanning = true;
    BluetoothManager.startMonitoring();
    Timer.periodic(Duration(seconds: 15), (timer) {
      if (mounted && _connectedDeviceName == null) {  // 只在未连接设备时进行扫描
        _startScan();
      }
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
        // 检查设备连接状态
        bool isConnected = await device.isConnected;
        if (!isConnected) {
          print("Device disconnected, attempting to reconnect...");
          try {
            await _bluetoothService.connectToDevice(device);
            await Future.delayed(const Duration(milliseconds: 500));
            isConnected = await device.isConnected;
            if (!isConnected) {
              throw Exception("Failed to reconnect");
            }
          } catch (e) {
            print("Reconnection failed: $e");
            timer.cancel();
            if (mounted) {
              setState(() {
                _connectionStatus = "Disconnected";
                _connectedDeviceName = null;
                _rssiValue = null;
              });
              _isAutoScanning = true;
            }
            return;
          }
        }
        
        // 读取RSSI值，设置5秒超时
        int rssi = await device.readRssi().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print("RSSI read timed out, retrying...");
            throw TimeoutException("RSSI read timed out");
          },
        );
        
        if (!mounted) return;
        
        setState(() {
          _rssiValue = rssi.toDouble();
          _lastRssiUpdate = DateTime.now();
        });
        
        if (_rssiValue != null && _rssiValue! > rssiMin) {
          _startVibrationFeedback(_rssiValue!);
        }
      } catch (e) {
        if (e is TimeoutException) {
          print("RSSI read timed out, will retry on next interval");
        } else {
          print("Error reading RSSI: $e");
          _vibrationTimer?.cancel();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error reading RSSI: ${e.toString()}'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
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

  Future<void> _connectToDevice(BluetoothDevice device) async {
    if (!mounted) return;
    
    setState(() {
      _connectionStatus = "Connecting...";
    });

    // 停止自动扫描
    _isAutoScanning = false;
    _bluetoothService.stopScan();

    try {
      // 先检查是否已连接
      if (await device.isConnected) {
        print("Device is already connected");
        setState(() {
          _connectionStatus = "Connected";
          _connectedDeviceName = device.name;
          _rssiValue = _scanResults.firstWhere((r) => r.device.remoteId == device.remoteId).rssi.toDouble();
        });
        _startRssiMonitoring(device);
        return;
      }

      // 尝试连接
      bool connected = await _bluetoothService.connectToDevice(device);
      if (!connected) {
        throw Exception("Failed to connect to device");
      }

      // 等待连接稳定
      await Future.delayed(const Duration(seconds: 2));
      
      // 验证连接状态
      bool isConnected = await device.isConnected;
      if (!isConnected) {
        throw Exception("Connection verification failed");
      }
      
      if (!mounted) return;

      // 更新UI状态
      setState(() {
        _connectionStatus = "Connected";
        _connectedDeviceName = device.name;
        _rssiValue = _scanResults.firstWhere((r) => r.device.remoteId == device.remoteId).rssi.toDouble();
      });

      // 启动RSSI监控和震动反馈
      _startRssiMonitoring(device);
      if (_rssiValue != null) {
        _startVibrationFeedback(_rssiValue!);
      }

      // 保存配对设备
      await BluetoothManager.savePairedDevice(device.id.id, device.name);
      await _loadPairedDevices();
      
    } catch (e) {
      print("Connection error: $e");
      if (!mounted) return;
      
      setState(() {
        _connectionStatus = "Connection failed: $e";
        _connectedDeviceName = null;
      });
      
      _vibrationTimer?.cancel();
      _isAutoScanning = true;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _disconnectDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      await BluetoothManager.removePairedDevice(device.id.id);
      await _loadPairedDevices();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Disconnected from ${device.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to disconnect: ${e.toString()}')),
        );
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _startScan,
          ),
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
      body: RefreshIndicator(
        onRefresh: _startScan,
        child: ListView(
          children: [
            if (_pairedDevices.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Paired Devices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._pairedDevices.map((device) => ListTile(
                title: Text(device['name'] ?? 'Unknown Device'),
                subtitle: Text(device['id'] ?? ''),
                trailing: TextButton(
                  child: const Text('Disconnect'),
                  onPressed: () async {
                    final scanResult = _scanResults.firstWhere(
                      (result) => result.device.id.id == device['id'],
                      orElse: () => _scanResults.first,
                    );
                    await _disconnectDevice(scanResult.device);
                  },
                ),
              )).toList(),
              const Divider(),
            ],
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Available Devices',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_isScanning)
              const Center(child: CircularProgressIndicator())
            else
              ..._scanResults.map(
                (result) => ListTile(
                  title: Text(_getDeviceName(result)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.device.id.id),
                      if (result.rssi != 0)
                        Text(
                          'RSSI: ${result.rssi} dBm (${_getDistanceCategory(result.rssi.toDouble())})',
                          style: TextStyle(
                            color: result.rssi > -70 ? Colors.green : 
                                   result.rssi > -90 ? Colors.orange : Colors.red,
                          ),
                        ),
                    ],
                  ),
                  trailing: TextButton(
                    child: const Text('Connect'),
                    onPressed: () => _connectToDevice(result.device),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 