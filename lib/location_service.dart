import 'dart:async';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'auth_service.dart';

class LocationService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final AuthService _auth = AuthService();
  String? pairedUserId;
  StreamSubscription<Position>? _positionStream;
  StreamSubscription<MagnetometerEvent>? _magnetometerStream;
  Position? currentPosition;
  double? currentHeading;
  final Function(double distance, double bearing) onLocationUpdate;

  LocationService({
    required this.onLocationUpdate,
  });

  Future<void> initialize() async {
    // 确保用户已登录
    await _auth.ensureLoggedIn();
    await _startLocationUpdates();
    await _startCompassUpdates();
  }

  Future<void> _startLocationUpdates() async {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      currentPosition = position;
      _updateLocationInFirebase(position);
      _calculateDistanceAndBearing();
    });
  }

  Future<void> _startCompassUpdates() async {
    _magnetometerStream = magnetometerEvents.listen((MagnetometerEvent event) {
      currentHeading = atan2(event.y, event.x) * (180 / pi);
      if (currentHeading! < 0) {
        currentHeading = 360 + currentHeading!;
      }
      _calculateDistanceAndBearing();
    });
  }

  void _updateLocationInFirebase(Position position) async {
    final userId = _auth.currentUserId;
    if (userId != null) {
      await _database.child('users/$userId/location').set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  void pairWithUser(String otherUserId) {
    pairedUserId = otherUserId;
    _startListeningToPairedUser();
  }

  void _startListeningToPairedUser() {
    if (pairedUserId == null) return;
    
    _database.child('users/$pairedUserId/location').onValue.listen((event) {
      if (event.snapshot.value != null) {
        _calculateDistanceAndBearing();
      }
    });
  }

  void _calculateDistanceAndBearing() async {
    if (currentPosition == null || pairedUserId == null) return;

    final snapshot = await _database.child('users/$pairedUserId/location').once();
    if (snapshot.snapshot.value != null) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      final otherLat = data['latitude'] as double;
      final otherLon = data['longitude'] as double;

      final distance = Geolocator.distanceBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        otherLat,
        otherLon,
      );

      final bearing = Geolocator.bearingBetween(
        currentPosition!.latitude,
        currentPosition!.longitude,
        otherLat,
        otherLon,
      );

      double relativeBearing = bearing - (currentHeading ?? 0);
      if (relativeBearing < 0) relativeBearing += 360;

      onLocationUpdate(distance, relativeBearing);
    }
  }

  void dispose() {
    _positionStream?.cancel();
    _magnetometerStream?.cancel();
  }
} 