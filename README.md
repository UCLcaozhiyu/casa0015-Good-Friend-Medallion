# Good Friend Medallion 🧙‍♂️

A Flutter app that helps you find your friends using GPS and Bluetooth technology, inspired by the Witcher's medallion.

![App Preview](docs/assets/app-preview.jpg)

## 📱 Installation Options

### Option 1: Direct APK Installation (Recommended for most users)

1. **Download the APK File** 📥
   - Visit our [Releases Page](https://github.com/UCLcaozhiyu/casa0015-Good-Friend-Medallion/releases)
   - Download the latest APK file

2. **Enable Installation from Unknown Sources** 🔓
   - Go to `Settings` > `Security` or `Privacy`
   - Enable "Install from Unknown Sources" or "Install Unknown Apps"

3. **Install and Run** 🚀
   - Open the downloaded APK file
   - Follow the installation prompts
   - Launch the app from your device's home screen

### Option 2: Build from Source (For developers)

1. **Prerequisites** ⚙️
   - Flutter SDK (>=3.0.0)
   - Android Studio / VS Code
   - Android 10+ (for Bluetooth LE support)
   - Git

2. **Clone and Setup** 💻
   ```bash
   git clone https://github.com/UCLcaozhiyu/casa0015-Good-Friend-Medallion.git
   cd casa0015-Good-Friend-Medallion
   flutter pub get
   ```

3. **Run the App** 🏃‍♂️
   ```bash
   flutter run
   ```

## ✨ Features

- GPS-based location tracking and compass functionality
- Bluetooth Low Energy (BLE) scanning and device discovery
- Distance calculation using both GPS and BLE signal strength
- Real-time compass arrow pointing to target location
- Device list with distance information
- Permission handling for location and Bluetooth access

## 🛠️ Technical Details

The app uses:
- `geolocator` for GPS location tracking
- `flutter_compass` for compass functionality
- `flutter_blue` for Bluetooth LE operations
- `permission_handler` for managing permissions

## 📖 Usage Guide

1. Launch the app and grant required permissions
2. The compass arrow will point to target location
3. Use "Scan for Devices" to discover nearby friends
4. Watch the distance indicator and feel vibration feedback
5. Get closer to your target following the compass

## 🤝 Contributing

We welcome contributions! Please feel free to:
- Submit issues
- Fork the repository
- Send pull requests
- Suggest new features

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌐 Links

- [Project Website](https://uclcaozhiyu.github.io/casa0015-Good-Friend-Medallion/)
- [Documentation](docs/index.html)
- [Release Notes](CHANGELOG.md)

## 📧 Contact

For questions or suggestions, please:
- Open an issue on GitHub
- Contact the development team through the project page 