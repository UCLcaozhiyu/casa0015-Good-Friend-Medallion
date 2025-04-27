# Good Friend Medallion 🧙‍♂️

> A Bluetooth & WiFi Direct-based peer-to-peer location and direction finder application.

![App Logo](https://vignette.wikia.nocookie.net/witcher/images/0/03/Tw3_medallion.png/revision/latest/scale-to-width-down/2000?cb=20160416054840)

## 📱 Overview

Good Friend Medallion is an innovative mobile application that helps you find your friends in the real world, inspired by the Witcher's medallion concept. The app provides real-time distance and direction information through a combination of Bluetooth and WiFi Direct technologies, all while maintaining complete privacy with its serverless architecture.

## ✨ Key Features

- **🔵 P2P Communication**
  - No cloud servers required
  - Complete privacy protection
  - Works entirely offline

- **📡 Hybrid Connectivity**
  - Bluetooth Low Energy (BLE) for device discovery
  - WiFi Direct for high-speed data exchange
  - Seamless switching between technologies

- **📍 Real-time Location**
  - Accurate distance calculation
  - Direction finding
  - GPS and compass integration

- **🎯 Interactive Feedback**
  - Progressive vibration intensity
  - Visual direction indicators
  - Proximity-based alerts

## 🛠️ Technical Stack

- **Framework**: Flutter 3.0+
- **Bluetooth**: flutter_blue_plus 1.35.3
- **Location**: geolocator 10.1.1
- **Permissions**: permission_handler 11.4.0

## 📋 Requirements

- Flutter 3.0 or higher
- Android 10+ (for WiFi Direct support)
- iOS 13.0+ (for BLE features)
- Bluetooth and Location permissions

## 🚀 Installation

1. Clone the repository:
```bash
git clone https://github.com/UCLcaozhiyu/CASA0015-Mobile-Systems-Interactions.git
cd casa0015-Good-Friend-Medallion
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:
```bash
flutter run
```

## 🎮 How It Works

1. **Discovery Phase**
   - Devices advertise their presence via BLE
   - Basic information exchange (WiFi SSID, unique ID)
   - Initial connection establishment

2. **Data Exchange**
   - Switch to WiFi Direct for high-speed communication
   - Exchange GPS and compass data
   - Calculate relative positions

3. **User Experience**
   - Real-time distance updates
   - Direction guidance
   - Haptic feedback based on proximity

## 📱 Supported Platforms

- Android
- iOS
- Web
- Windows
- Linux
- macOS

## 🔒 Privacy & Security

- No data stored on external servers
- End-to-end encrypted communication
- Local-only data processing
- Minimal required permissions

## 🤝 Contributing

We welcome contributions! Please feel free to submit a Pull Request.

## 📧 Contact

For any questions or suggestions, please open an issue in the repository.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details. 