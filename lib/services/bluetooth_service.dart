import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'dart:math';

class BluetoothManager {
  static StreamSubscription<List<ScanResult>>? _scanSubscription;
  static final Map<String, BluetoothDevice> _discoveredDevices = {};

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
      await device.connect();
      final rssi = await device.readRssi();
      await device.disconnect();
      return rssi.toDouble();
    } catch (e) {
      print('Error getting RSSI: $e');
      return null;
    }
  }

  static Map<String, BluetoothDevice> getDiscoveredDevices() {
    return Map.from(_discoveredDevices);
  }

  static double estimateDistance(double rssi) {
    // This is a simplified distance estimation based on RSSI
    // You might want to calibrate these values for your specific use case
    const txPower = -59; // RSSI at 1 meter
    const n = 2.0; // Path loss exponent
    return pow(10, (txPower - rssi) / (10 * n)).toDouble();
  }
} 