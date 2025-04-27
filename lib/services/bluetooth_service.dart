import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';

class BluetoothManager {
  static StreamSubscription<List<ScanResult>>? _scanSubscription;
  static final Map<String, BluetoothDevice> _discoveredDevices = {};
  static final Map<String, BluetoothDevice> _matchedDevices = {};
  static Timer? _monitoringTimer;
  static bool _isMonitoring = false;
  
  // 定义距离阈值（米）
  static const double CLOSE_DISTANCE_THRESHOLD = 5.0; // 5米以内自动连接
  static const double MAX_DISTANCE_THRESHOLD = 15.0; // 超过15米自动断开

  static Future<bool> checkBluetoothPermission() async {
    try {
      return await FlutterBluePlus.isAvailable;
    } catch (e) {
      return false;
    }
  }

  static Future<void> startScanning() async {
    try {
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
      _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult result in results) {
          _discoveredDevices[result.device.remoteId.toString()] = result.device;
        }
      });
    } catch (e) {
      print('Error starting scan: $e');
    }
  }

  static Future<void> stopScanning() async {
    try {
      await FlutterBluePlus.stopScan();
      await _scanSubscription?.cancel();
    } catch (e) {
      print('Error stopping scan: $e');
    }
  }

  static Future<double?> getRssi(BluetoothDevice device) async {
    try {
      if (!device.isConnected) {
      await device.connect();
      }
      final rssi = await device.readRssi();
      return rssi.toDouble();
    } catch (e) {
      print('Error getting RSSI: $e');
      return null;
    }
  }

  static double estimateDistance(double rssi) {
    // 使用改进的距离估算公式
    // 参考: https://iotandelectronics.wordpress.com/2016/10/07/how-to-calculate-distance-from-the-rssi-value-of-the-ble-beacon/
    const txPower = -59; // 在1米处的RSSI值（需要根据实际设备校准）
    const n = 2.0; // 路径损耗指数（2.0-4.0，开放空间约为2，室内约为3）

    if (rssi == 0) {
      return -1.0; // 如果RSSI为0，表示无法测量
    }

    double ratio = rssi * 1.0 / txPower;
    if (ratio < 1.0) {
      return pow(ratio, 10).toDouble();
    } else {
      double distance = (0.89976) * pow(ratio, 7.7095) + 0.111;
      return distance;
    }
  }

  static Map<String, BluetoothDevice> getDiscoveredDevices() {
    return Map.from(_discoveredDevices);
  }

  static Future<void> addMatchedDevice(String deviceId, String deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    final matchedDevices = prefs.getStringList('matched_devices') ?? [];
    if (!matchedDevices.contains(deviceId)) {
      matchedDevices.add(deviceId);
      await prefs.setStringList('matched_devices', matchedDevices);
    }
  }

  static Future<List<String>> getMatchedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('matched_devices') ?? [];
  }

  static Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    _isMonitoring = true;
    
    _monitoringTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await startScanning();
      final matchedDevices = await getMatchedDevices();
      
      for (var device in _discoveredDevices.values) {
        if (matchedDevices.contains(device.remoteId.toString())) {
          try {
            // 获取RSSI并计算距离
            final rssi = await getRssi(device);
            if (rssi != null) {
              final distance = estimateDistance(rssi);
              print('Device ${device.remoteId} distance: ${distance.toStringAsFixed(2)} meters');

              // 根据距离决定是否连接
              if (distance <= CLOSE_DISTANCE_THRESHOLD) {
                // 设备非常近，尝试连接
                if (!device.isConnected) {
                  await device.connect();
                  print('Automatically connected to ${device.remoteId} (distance: ${distance.toStringAsFixed(2)}m)');
                }
              } else if (distance > MAX_DISTANCE_THRESHOLD) {
                // 设备太远，如果已连接则断开
                if (device.isConnected) {
                  await device.disconnect();
                  print('Disconnected from ${device.remoteId} due to distance (${distance.toStringAsFixed(2)}m)');
                }
              }
            }
          } catch (e) {
            print('Error handling device ${device.remoteId}: $e');
          }
        }
      }
      
      await stopScanning();
    });
  }

  static Future<void> stopMonitoring() async {
    _monitoringTimer?.cancel();
    _isMonitoring = false;
  }

  static Future<String> getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'Unknown_Device';
      }
      return 'Unknown_Device';
    } catch (e) {
      return 'Unknown_Device';
    }
  }

  static Future<String> getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      }
      return 'Unknown_Device';
    } catch (e) {
      return 'Unknown_Device';
    }
  }
}

class BluetoothDeviceService {
  Stream<List<ScanResult>> startScan() {
    FlutterBluePlus.stopScan();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    return FlutterBluePlus.scanResults;
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect();
  }

  Future<void> setMtu(BluetoothDevice device, int mtu) async {
    await device.requestMtu(mtu);
  }
} 