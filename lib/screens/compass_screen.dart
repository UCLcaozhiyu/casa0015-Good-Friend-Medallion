import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'dart:async';
import '../services/permission_service.dart';
import '../services/bluetooth_service.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({Key? key}) : super(key: key);

  @override
  _CompassScreenState createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  double? _direction;
  double? _distance;
  String _distanceText = 'Searching...';
  bool _isScanning = false;
  Map<String, BluetoothDevice> _devices = {};
  bool _hasPermissions = false;
  StreamSubscription<CompassEvent>? _compassSubscription;
  Position? _currentPosition;
  Position? _targetPosition;
  StreamSubscription<Position>? _positionStream;
  double _maxDistance = 100.0; // 最大距离（米）
  double _currentDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _initCompass();
    _requestPermissions();
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      print('Checking location services...');
      // 首先检查位置服务是否启用
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Location service enabled: $serviceEnabled');
      
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enable location services')),
          );
        }
        return;
      }

      print('Checking location permissions...');
      // 检查位置权限
      LocationPermission permission = await Geolocator.checkPermission();
      print('Current permission status: $permission');
      
      if (permission == LocationPermission.denied) {
        print('Requesting location permission...');
        permission = await Geolocator.requestPermission();
        print('Permission request result: $permission');
        
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are permanently denied')),
          );
        }
        return;
      }

      print('Getting current position...');
      // 获取当前位置
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Got position: ${position.latitude}, ${position.longitude}');

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }

      print('Starting position stream...');
      // 开始监听位置更新
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // 每移动10米更新一次
        ),
      ).listen((Position position) {
        print('Position updated: ${position.latitude}, ${position.longitude}');
        if (mounted) {
          setState(() {
            _currentPosition = position;
            if (_targetPosition != null) {
              _currentDistance = Geolocator.distanceBetween(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                _targetPosition!.latitude,
                _targetPosition!.longitude,
              );
            }
          });
        }
      });
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    final hasPermissions = await PermissionService.requestPermissions();
    if (mounted) {
      setState(() {
        _hasPermissions = hasPermissions;
      });
      
      if (hasPermissions) {
        _getCurrentLocation();
      } else {
        _showPermissionDialog();
      }
    }
  }

  void _showPermissionDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'This app needs location and Bluetooth permissions to function properly. '
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

  void _initCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _direction = event.heading;
        });
      }
    });
  }

  Future<void> _startScanning() async {
    if (!_hasPermissions) {
      _showPermissionDialog();
      return;
    }

    if (!mounted) return;
    setState(() {
      _isScanning = true;
      _distanceText = 'Scanning...';
    });

    await BluetoothManager.startScanning();
    if (!mounted) return;
    setState(() {
      _devices = BluetoothManager.getDiscoveredDevices();
      _isScanning = false;
      _distanceText = 'Found ${_devices.length} devices';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 坐标显示区域
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Your Location:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _currentPosition != null
                        ? 'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\nLon: ${_currentPosition!.longitude.toStringAsFixed(6)}'
                        : 'Getting location...',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Target Location:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _targetPosition != null
                        ? 'Lat: ${_targetPosition!.latitude.toStringAsFixed(6)}\nLon: ${_targetPosition!.longitude.toStringAsFixed(6)}'
                        : 'No target set',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Divider(),
            // 指南针
            if (_direction != null)
              Transform.rotate(
                angle: (_direction ?? 0) * (pi / 180) * -1,
                child: const Icon(
                  Icons.arrow_upward,
                  size: 100,
                  color: Colors.blue,
                ),
              ),
            const SizedBox(height: 20),
            // 距离进度条
            if (_currentDistance > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: _currentDistance / _maxDistance,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _currentDistance < _maxDistance / 2
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Distance: ${_currentDistance.toStringAsFixed(2)}m',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Text(
              _distanceText,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isScanning ? null : _startScanning,
              child: Text(_isScanning ? 'Scanning...' : 'Scan for Devices'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices.values.elementAt(index);
                  return ListTile(
                    title: Text(device.name.isEmpty ? 'Unknown Device' : device.name),
                    subtitle: Text(device.remoteId.toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                        final rssi = await BluetoothManager.getRssi(device);
                        if (rssi != null) {
                          final distance = BluetoothManager.estimateDistance(rssi);
                          setState(() {
                            _distanceText = 'Distance: ${distance.toStringAsFixed(2)}m';
                            _targetPosition = _currentPosition; // 临时设置目标位置为当前位置
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 