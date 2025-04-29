import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class BluetoothManager {
  static final Set<String> _connectedDevices = {};
  static const String _pairedDevicesKey = 'paired_devices';
  static const double CLOSE_DISTANCE_THRESHOLD = 5.0;
  static const double MAX_DISTANCE_THRESHOLD = 15.0;

  static Future<bool> checkBluetoothPermission() async {
    try {
      return await FlutterBluePlus.isAvailable;
    } catch (e) {
      return false;
    }
  }

  static Future<double?> getRssi(BluetoothDevice device) async {
    try {
      if (!device.isConnected) {
        await device.connect(timeout: const Duration(seconds: 5));
      }
      final rssi = await device.readRssi();
      return rssi.toDouble();
    } catch (e) {
      print('Error getting RSSI: $e');
      return null;
    }
  }

  static double estimateDistance(double rssi) {
    const txPower = -59;
    const n = 2.0;

    if (rssi == 0) {
      return -1.0;
    }

    double ratio = rssi * 1.0 / txPower;
    if (ratio < 1.0) {
      return pow(ratio, 10).toDouble();
    } else {
      double distance = (0.89976) * pow(ratio, 7.7095) + 0.111;
      return distance;
    }
  }

  static Future<List<Map<String, String>>> getPairedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final String? pairedDevicesJson = prefs.getString(_pairedDevicesKey);
    if (pairedDevicesJson == null) return [];
    
    List<dynamic> decoded = json.decode(pairedDevicesJson);
    return decoded.map((item) => Map<String, String>.from(item)).toList();
  }

  static Future<void> savePairedDevice(String deviceId, String deviceName) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> pairedDevices = await getPairedDevices();
    
    bool deviceExists = pairedDevices.any((device) => device['id'] == deviceId);
    if (!deviceExists) {
      pairedDevices.add({
        'id': deviceId,
        'name': deviceName,
      });
      await prefs.setString(_pairedDevicesKey, json.encode(pairedDevices));
    }
  }

  static Future<void> removePairedDevice(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, String>> pairedDevices = await getPairedDevices();
    pairedDevices.removeWhere((device) => device['id'] == deviceId);
    await prefs.setString(_pairedDevicesKey, json.encode(pairedDevices));
    _connectedDevices.remove(deviceId);
  }

  static Future<bool> isDevicePaired(String deviceId) async {
    List<Map<String, String>> pairedDevices = await getPairedDevices();
    return pairedDevices.any((device) => device['id'] == deviceId);
  }

  static Future<void> startMonitoring() async {
    if (!await FlutterBluePlus.isOn) {
      print('Bluetooth is not on');
      return;
    }

    List<Map<String, String>> pairedDevices = await getPairedDevices();
    
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult result in results) {
        bool isPaired = pairedDevices.any((device) => device['id'] == result.device.id.id);
        if (isPaired && !_connectedDevices.contains(result.device.id.id)) {
          try {
            await result.device.connect();
            _connectedDevices.add(result.device.id.id);
            print('自动连接到配对设备: ${result.device.name}');
          } catch (e) {
            print('连接失败: $e');
          }
        }
      }
    });

    Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (await FlutterBluePlus.isOn) {
        await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      }
    });
  }

  static Future<void> stopMonitoring() async {
    await FlutterBluePlus.stopScan();
  }

  static Future<void> addMatchedDevice(String deviceId, String deviceName) async {
    await savePairedDevice(deviceId, deviceName);
  }

  static Future<String> getDeviceId() async {
    List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      return connectedDevices.first.id.id;
    }
    return '';
  }

  static Future<String> getDeviceName() async {
    List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      return connectedDevices.first.name;
    }
    return '';
  }
}

class BluetoothDeviceService with ChangeNotifier {
  final Set<BluetoothDevice> _connectedDevices = {};
  List<BluetoothDevice> get connectedDevices => _connectedDevices.toList();

  Stream<List<ScanResult>> startScan() {
    FlutterBluePlus.stopScan();
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    return FlutterBluePlus.scanResults;
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  Future<bool> connectToDevice(BluetoothDevice device) async {
    int retryCount = 0;
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);
    const connectionTimeout = Duration(seconds: 10);

    while (retryCount < maxRetries) {
      try {
        // 检查是否已连接
        if (await device.isConnected) {
          print('Device ${device.name} is already connected');
          _connectedDevices.add(device);
          notifyListeners();
          return true;
        }

        // 尝试连接
        await device.connect(timeout: connectionTimeout, autoConnect: false);
        print('Connected to device: ${device.name}');

        // 设置MTU以提高数据传输速率
        try {
          await device.requestMtu(512);
        } catch (e) {
          print('MTU request failed: $e');
          // MTU请求失败不影响连接
        }

        // 再次验证连接状态
        if (await device.isConnected) {
          _connectedDevices.add(device);
          notifyListeners();
          return true;
        } else {
          throw Exception('Connection verification failed');
        }
      } on FlutterBluePlusException catch (e) {
        print('Connection attempt ${retryCount + 1} failed: ${e.toString()}');
        retryCount++;
        
        // 如果设备仍然连接着，尝试断开
        try {
          if (await device.isConnected) {
            await device.disconnect();
          }
        } catch (disconnectError) {
          print('Error during disconnect: $disconnectError');
        }

        if (retryCount < maxRetries) {
          print('Retrying in ${retryDelay.inSeconds} seconds...');
          await Future.delayed(retryDelay);
        }
      }
    }
    
    print('Failed to connect after $maxRetries attempts');
    return false;
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      print('Disconnected from device: ${device.name}');
    } catch (e) {
      print('Error disconnecting from device: $e');
    } finally {
      _connectedDevices.remove(device);
      notifyListeners();
    }
  }

  Future<void> setMtu(BluetoothDevice device, int mtu) async {
    await device.requestMtu(mtu);
  }
} 