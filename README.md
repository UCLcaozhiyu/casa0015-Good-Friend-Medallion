# Good Friend Medallion

A Flutter app that helps you find your friends using GPS and Bluetooth technology, inspired by the Witcher's medallion.

## Features

- GPS-based location tracking and compass functionality
- Bluetooth Low Energy (BLE) scanning and device discovery
- Distance calculation using both GPS and BLE signal strength
- Real-time compass arrow pointing to target location
- Device list with distance information
- Permission handling for location and Bluetooth access

## Requirements

- Flutter SDK (>=3.0.0)
- Android 10+ (for Bluetooth LE support)
- Location services enabled
- Bluetooth enabled

## Installation

1. Clone the repository:
```bash
git clone https://github.com/UCLcaozhiyu/casa0015-Good-Friend-Medallion.git
cd casa0015-Good-Friend-Medallion
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Usage

1. Launch the app and grant the required permissions (location and Bluetooth)
2. The compass arrow will point to the target location when GPS coordinates are available
3. Use the "Scan for Devices" button to discover nearby Bluetooth devices
4. The app will display the distance to discovered devices
5. The vibration intensity increases as you get closer to the target device

## Technical Details

The app uses:
- `geolocator` for GPS location tracking
- `flutter_compass` for compass functionality
- `flutter_blue` for Bluetooth LE operations
- `permission_handler` for managing permissions

## Contributing

Feel free to submit issues and enhancement requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 