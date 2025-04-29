import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/permission_service.dart';
import '../services/bluetooth_service.dart';
import '../config/api_keys.dart';
import 'bluetooth_screen.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  double? _direction;
  Position? _currentPosition;
  final LatLng _defaultLocation = const LatLng(51.5336, -0.0147); // One Pool Street
  MapController _mapController = MapController();
  bool _isMapReady = false;
  StreamSubscription<CompassEvent>? _compassSubscription;
  StreamSubscription<Position>? _positionSubscription;
  
  // 天气相关变量
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = false;
  String get _apiKey => ApiKeys.openWeatherMap;

  @override
  void initState() {
    super.initState();
    _setupCompass();
    _setupLocation();
    _requestPermissions();
    _fetchWeather(_defaultLocation.latitude, _defaultLocation.longitude);
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _positionSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _setupLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _fetchWeather(_defaultLocation.latitude, _defaultLocation.longitude);
        _mapController.move(_defaultLocation, 15.0);
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          _fetchWeather(_defaultLocation.latitude, _defaultLocation.longitude);
          _mapController.move(_defaultLocation, 15.0);
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _fetchWeather(_defaultLocation.latitude, _defaultLocation.longitude);
        _mapController.move(_defaultLocation, 15.0);
      }
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        _fetchWeather(position.latitude, position.longitude);
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          15.0,
        );
      }

      _positionSubscription = Geolocator.getPositionStream().listen((Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
          _fetchWeather(position.latitude, position.longitude);
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            15.0,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        _fetchWeather(_defaultLocation.latitude, _defaultLocation.longitude);
        _mapController.move(_defaultLocation, 15.0);
      }
    }
  }

  void _setupCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted) {
        setState(() {
          _direction = event.heading;
        });
      }
    });
  }

  Future<void> _requestPermissions() async {
    final hasPermissions = await PermissionService.requestPermissions();
    if (mounted) {
      if (!hasPermissions) {
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

  Future<void> _fetchWeather(double lat, double lon) async {
    if (_isLoadingWeather) return;
    
    setState(() {
      _isLoadingWeather = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'
        ),
      );

      if (response.statusCode == 200 && mounted) {
        setState(() {
          _weatherData = json.decode(response.body);
          _isLoadingWeather = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }

  Widget _buildWeatherWidget() {
    if (_isLoadingWeather) {
      return const CircularProgressIndicator();
    }

    if (_weatherData == null) {
      return const SizedBox.shrink();
    }

    final weather = _weatherData!['weather'][0];
    final main = _weatherData!['main'];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${main['temp'].round()}°C',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            weather['description'],
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 4),
          Image.network(
            'https://openweathermap.org/img/wn/${weather['icon']}@2x.png',
            width: 50,
            height: 50,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () => Navigator.pop(context),
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
      body: Stack(
        children: [
          // 半透明地图背景
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _currentPosition != null
                      ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                      : _defaultLocation,
                  zoom: 15.0,
                  onMapReady: () {
                    setState(() {
                      _isMapReady = true;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.good_friend_medallion',
                  ),
                  MarkerLayer(
                    markers: [
                      if (_currentPosition != null)
                        Marker(
                          point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                          width: 30,
                          height: 30,
                          child: const Icon(Icons.person_pin, color: Colors.blue, size: 30),
                        ),
                      Marker(
                        point: _defaultLocation,
                        width: 5,
                        height: 5,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 中心指南针
          Center(
            child: Transform.rotate(
              angle: ((_direction ?? 0) * (math.pi / 180) * -1),
              child: Image.network(
                'https://raw.githubusercontent.com/CASA0015/casa0015.github.io/main/_images/GoodFriendMedallion/compass_arrow.png',
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.navigation,
                    size: 200,
                    color: Colors.red,
                  );
                },
              ),
            ),
          ),
          // 天气显示
          Positioned(
            top: 20,
            right: 20,
            child: _buildWeatherWidget(),
          ),
        ],
      ),
    );
  }
} 