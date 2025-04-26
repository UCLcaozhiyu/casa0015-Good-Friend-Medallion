import 'package:flutter/material.dart';
import 'qr_screen.dart';
import 'compass_screen.dart';
import 'bluetooth_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Good Friend Medallion'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Good Friend Medallion',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            _buildNavigationButton(
              context,
              'QR Code Matching',
              Icons.qr_code,
              const QRScreen(),
            ),
            const SizedBox(height: 20),
            _buildNavigationButton(
              context,
              'Compass',
              Icons.explore,
              const CompassScreen(),
            ),
            const SizedBox(height: 20),
            _buildNavigationButton(
              context,
              'Bluetooth Matching',
              Icons.bluetooth,
              const BluetoothScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      icon: Icon(icon, size: 30),
      label: Text(
        title,
        style: const TextStyle(fontSize: 18),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        minimumSize: const Size(250, 60),
      ),
    );
  }
} 