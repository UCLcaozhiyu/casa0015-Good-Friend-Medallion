import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Good Friend Medallion',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location = "Unknown";
  String bleStatus = "Not Scanning";
  double? rssiValue;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    getLocation();
  }

  Future<void> requestPermissions() async {
    await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      location = "Lat: ${position.latitude}, Lon: ${position.longitude}";
    });
  }

  void startBleScan() {
    FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
    setState(() {
      bleStatus = "Scanning...";
    });

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name.isNotEmpty) {
          setState(() {
            rssiValue = r.rssi.toDouble();
            bleStatus = "Found: ${r.device.name} | RSSI: ${rssiValue}";
          });

          // 按 RSSI 震动
          if (rssiValue != null) {
            if (rssiValue! > -60) {
              Vibration.vibrate(duration: 300, amplitude: 255);
            } else if (rssiValue! > -80) {
              Vibration.vibrate(duration: 200, amplitude: 150);
            }
          }
          break;
        }
      }
    });
  }

  Widget buildRssiIndicator() {
    if (rssiValue == null) return Text("No device nearby.");
    if (rssiValue! > -60) return Text("🔥 Very Close!");
    if (rssiValue! > -80) return Text("🙂 Nearby");
    return Text("👀 Far");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('The Good Friend Medallion')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📍 Your Location:"),
            Text(location),
            SizedBox(height: 30),
            Text("📡 BLE Status:"),
            Text(bleStatus),
            SizedBox(height: 30),
            buildRssiIndicator(),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: startBleScan,
              child: Text("🔍 Scan for Friend"),
            ),
          ],
        ),
      ),
    );
  }
}
