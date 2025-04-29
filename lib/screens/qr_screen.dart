import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';
import '../services/user_service.dart';
import '../services/bluetooth_service.dart';
import 'compass_screen.dart';
import 'bluetooth_screen.dart';
import 'dart:convert';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class QRScreen extends StatefulWidget {
  const QRScreen({Key? key}) : super(key: key);

  @override
  _QRScreenState createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  String? _userId;
  bool _isGenerating = false;
  bool _hasCameraPermission = false;
  List<Map<String, dynamic>> _matches = [];
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
    _loadUserData();
    // Start Bluetooth monitoring when the screen is opened
    BluetoothManager.startMonitoring();
  }

  Future<void> _loadUserData() async {
    final userId = await UserService.getOrCreateUserId();
    final matches = await UserService.getMatches();
    setState(() {
      _userId = userId;
      _matches = matches;
    });
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasCameraPermission = status.isGranted;
    });
  }

  void _generateQRCode() {
    setState(() {
      _isGenerating = true;
    });
  }

  void _clearQRCode() {
    setState(() {
      _isGenerating = false;
    });
  }

  Future<void> _handleScannedQR(String scannedData) async {
    try {
      final matchData = json.decode(scannedData) as Map<String, dynamic>;
      await UserService.addMatch(matchData);
      
      // Save the matched device for automatic Bluetooth connection
      if (matchData.containsKey('deviceId') && matchData.containsKey('deviceName')) {
        await BluetoothManager.addMatchedDevice(
          matchData['deviceId'],
          matchData['deviceName']
        );
      }
      
      await _loadUserData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New friend added! Starting Bluetooth monitoring...')),
        );
        // Start monitoring for the matched device
        await BluetoothManager.startMonitoring();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid QR code')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.compass_calibration),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CompassScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bluetooth),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BluetoothScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_userId != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Your QR Code:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: Future.wait([
                      BluetoothManager.getDeviceId(),
                      BluetoothManager.getDeviceName()
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final deviceId = snapshot.data![0];
                        final deviceName = snapshot.data![1];
                        return QrImageView(
                          data: json.encode({
                            'id': _userId,
                            'timestamp': DateTime.now().toIso8601String(),
                            'deviceId': deviceId,
                            'deviceName': deviceName
                          }),
                          version: QrVersions.auto,
                          size: 200.0,
                        );
                      }
                      return const CircularProgressIndicator();
                    },
                  ),
                ],
              ),
            ),
          if (!_hasCameraPermission)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Camera permission is required to scan QR codes',
                textAlign: TextAlign.center,
              ),
            ),
          if (_hasCameraPermission)
            Expanded(
              child: MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    _handleScannedQR(barcode.rawValue ?? '');
                  }
                },
              ),
            ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Your Friends:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
                final match = _matches[index];
                return ListTile(
                  title: Text('Friend ${match['id']}'),
                  subtitle: Text('Added: ${DateTime.parse(match['timestamp']).toLocal()}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await UserService.removeMatch(match['id']);
                      await _loadUserData();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    // Stop monitoring when the screen is closed
    BluetoothManager.stopMonitoring();
    super.dispose();
  }
} 