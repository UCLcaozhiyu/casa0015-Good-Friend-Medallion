// main.dart（连接后图标动态变化 + 可调节阈值 + 信号强度仪表 + 重置按钮 + 实时更新优化）
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
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
    requestPermissions();
    startLocationStream();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _bleScanSubscription?.cancel();
    _rssiUpdateTimer?.cancel();
    FlutterBluePlus.stopScan();
    connectedDevice?.disconnect();
    super.dispose();
  }

  Future<void> requestPermissions() async {
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

  void startLocationStream() async {
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
        location = "Lat: ${position.latitude}, Lon: ${position.longitude}";
      });
    });
  }

  void startBleScan() {
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
              const Text("📡 BLE Status:"),
              Text(bleStatus),
              const SizedBox(height: 30),
              buildRssiMeter(),
              const SizedBox(height: 30),
              buildThresholdSlider(),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: startBleScan,
                child: const Text("🔍 Scan for Friend"),
              ),
              const SizedBox(height: 30),
              buildDeviceList(),
            ],
          ),
        ),
      ),
    );
  }
}
