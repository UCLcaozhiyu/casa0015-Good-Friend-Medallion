// main.dart（Web 适配版）
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'compass_widget.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Good Friend Medallion',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location = "📍 Waiting for location...";
  String bleStatus = "📡 Not scanning";
  double? rssiValue;
  List<ScanResult> foundDevices = [];
  BluetoothDevice? connectedDevice;
  String? connectedDeviceId;
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<List<ScanResult>>? _bleScanSubscription;
  bool enableRssiHaptic = false;
  Timer? _rssiUpdateTimer;
  double _distance = 0;
  double _bearing = 0;
  bool _isBluetoothMode = false;
  Position? _currentPosition;
  Position? _targetPosition;

  // 可调阈值
  double closeThreshold = -60;
  double midThreshold = -80;
  final double rssiMin = -100;
  final double rssiMax = -30;

  void resetThresholds() {
    setState(() {
      closeThreshold = -60;
      midThreshold = -80;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _bleScanSubscription?.cancel();
    _rssiUpdateTimer?.cancel();
    if (!kIsWeb) {
    FlutterBluePlus.stopScan();
    connectedDevice?.disconnect();
    }
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      print('Starting app initialization...');
      await requestPermissions();
      await startLocationStream();
      print('App initialization completed');
    } catch (e) {
      print('Error during app initialization: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) {
      // Web 平台只需要位置权限
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
      ].request();
      
      bool denied = statuses.values.any((status) =>
          status.isDenied || status.isPermanentlyDenied);

      if (denied) {
        setState(() {
          location = "❌ 权限不足，请在设置中手动开启";
        });

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("权限被拒绝"),
              content: const Text("请允许位置访问权限，否则功能无法使用。"),
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
    } else {
      // 移动平台需要位置和蓝牙权限
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    bool denied = statuses.values.any((status) =>
        status.isDenied || status.isPermanentlyDenied);

    if (denied) {
      setState(() {
        location = "❌ 权限不足，请在设置中手动开启";
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("权限被拒绝"),
            content: const Text("请前往系统设置中手动开启位置与蓝牙权限，否则功能无法使用。"),
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
  }

  // 计算两个位置之间的距离（米）
  double calculateDistance(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }

  // 计算方位角（度）
  double calculateBearing(Position pos1, Position pos2) {
    double lat1 = pos1.latitude * math.pi / 180;
    double lon1 = pos1.longitude * math.pi / 180;
    double lat2 = pos2.latitude * math.pi / 180;
    double lon2 = pos2.longitude * math.pi / 180;

    double y = math.sin(lon2 - lon1) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(lon2 - lon1);
    double bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  Future<void> startLocationStream() async {
    try {
      print('Starting location stream...');
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          location = "⚠️ Location service disabled";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        setState(() {
          location = "❌ Location permission denied";
        });
        return;
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).listen((Position position) {
        setState(() {
          _currentPosition = position;
          location = "Lat: ${position.latitude}, Lon: ${position.longitude}";
          
          // 如果有目标位置，计算距离和方位
          if (_targetPosition != null) {
            _distance = calculateDistance(position, _targetPosition!);
            _bearing = calculateBearing(position, _targetPosition!);
          }
        });
      });
      print('Location stream started successfully');
    } catch (e) {
      print('Error starting location stream: $e');
      setState(() {
        location = "❌ Error: $e";
      });
    }
  }

  void startBleScan() {
    if (kIsWeb) {
      setState(() {
        bleStatus = "⚠️ 蓝牙功能在 Web 平台不可用";
      });
      return;
    }

    FlutterBluePlus.stopScan();
    foundDevices.clear();
    setState(() {
      bleStatus = "🔍 Scanning...";
      rssiValue = null;
      enableRssiHaptic = false;
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    _bleScanSubscription?.cancel();
    _bleScanSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        foundDevices = results
            .where((r) => r.device.name.isNotEmpty)
            .toList();
        bleStatus = "📡 Found ${foundDevices.length} device(s)";
      });
    });
  }

  void connectToDevice(ScanResult r) async {
    if (kIsWeb) return;

    await FlutterBluePlus.stopScan();
    setState(() {
      bleStatus = "🔗 Connecting to ${r.device.name}";
    });
    try {
      await r.device.connect();
      FlutterBluePlus.startScan();
      connectedDevice = r.device;
      connectedDeviceId = r.device.remoteId.str;
      enableRssiHaptic = true;
      startConnectedRssiListener();

      // 发送当前位置给连接的设备
      if (_currentPosition != null) {
        // 这里可以添加通过蓝牙发送位置信息的代码
        // 实际实现需要定义蓝牙服务和特征值
        print('Sending location to device: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      }

      setState(() {
        bleStatus = "✅ Connected to ${r.device.name}";
        rssiValue = r.rssi.toDouble();
      });
      HapticFeedback.heavyImpact();
    } catch (e) {
      setState(() {
        bleStatus = "❌ Connection failed: $e";
      });
      HapticFeedback.mediumImpact();
    }
  }

  void startConnectedRssiListener() {
    if (kIsWeb) return;

    _bleScanSubscription?.cancel();
    _rssiUpdateTimer?.cancel();

    _bleScanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        if (result.device.remoteId.str == connectedDeviceId) {
          setState(() {
            rssiValue = result.rssi.toDouble();
          });

          if (enableRssiHaptic) {
            if (rssiValue! > closeThreshold) {
              HapticFeedback.heavyImpact();
            } else if (rssiValue! > midThreshold) {
              HapticFeedback.mediumImpact();
            } else {
              HapticFeedback.lightImpact();
            }
          }
        }
      }
    });
  }

  Widget buildRssiMeter() {
    if (kIsWeb) {
      return const Text("⚠️ 蓝牙功能在 Web 平台不可用");
    }

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

  Widget buildDeviceList() {
    if (kIsWeb) {
      return const Text("⚠️ 蓝牙功能在 Web 平台不可用");
    }

    if (foundDevices.isEmpty) return const Text("🔍 No BLE devices found.");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: foundDevices.map((r) {
        return ListTile(
          title: Text(r.device.name),
          subtitle: Text("RSSI: ${r.rssi}"),
          trailing: ElevatedButton(
            child: const Text("连接"),
            onPressed: () => connectToDevice(r),
          ),
        );
      }).toList(),
    );
  }

  Widget buildThresholdSlider() {
    if (kIsWeb) {
      return const Text("⚠️ 蓝牙功能在 Web 平台不可用");
    }

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
      appBar: AppBar(title: const Text('The Good Friend Medallion')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("📍 Your Location:"),
              Text(location),
              const SizedBox(height: 30),
              if (_targetPosition != null) ...[
                Text("🎯 Target Location:"),
                Text("Lat: ${_targetPosition!.latitude}, Lon: ${_targetPosition!.longitude}"),
                Text("📏 Distance: ${_distance.toStringAsFixed(2)} meters"),
                Text("🧭 Bearing: ${_bearing.toStringAsFixed(1)}°"),
                const SizedBox(height: 30),
              ],
              if (!kIsWeb) ...[
              const Text("📡 BLE Status:"),
              Text(bleStatus),
              const SizedBox(height: 30),
              ],
              // 显示罗盘
              Center(
                child: CompassWidget(
                  bearing: _bearing,
                  distance: _distance,
                  isBluetoothMode: _isBluetoothMode,
                ),
              ),
              const SizedBox(height: 30),
              if (!kIsWeb) ...[
              if (!_isBluetoothMode) buildRssiMeter(),
              const SizedBox(height: 30),
              buildThresholdSlider(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: startBleScan,
                child: const Text("🔍 Scan for Friend"),
              ),
              const SizedBox(height: 30),
              buildDeviceList(),
              ] else ...[
                const Text(
                  "⚠️ 注意：这是一个蓝牙应用，在 Web 平台上只能使用位置功能。",
                  style: TextStyle(color: Colors.orange),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
