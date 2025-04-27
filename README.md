# Good Friend Medallion 🧙‍♂️

> "When danger is near, it trembles..." - Inspired by the Witcher's medallion, this app helps you sense your friends in the real world.

![App Interface](docs/assets/gfm3.0/b0ae231ef1bb6dbf41cb21c37790aa5.jpg)

## 🌟 Overview

Good Friend Medallion is an innovative P2P direction finder that combines Bluetooth Low Energy (BLE) and WiFi Direct technology to help you find your friends in the real world. Just like the Witcher's medallion vibrates when magic is near, this app provides haptic feedback as you get closer to your friends.

**"Find your target, no server required."**

![Location Tracking](docs/assets/gfm3.0/d9ea1f52dcced32691b50368b3a048a.jpg)

## ✨ Key Features

### 🔍 Core Functionality
- **P2P Communication** – No cloud, no server, full privacy
- **Hybrid Technology** – BLE for discovery, WiFi Direct for fast data exchange
- **Real-time Updates** – Instant distance and direction information
- **Works Offline** – Ideal for rescue, social encounters, or real-world games

### 📱 Smart Interface
- **Dynamic Compass** – Points directly to your friend's location
- **Signal Strength Meter** – Visual representation of connection strength
- **Threshold Controls** – Adjustable proximity settings
- **Authentication Screens** – Secure user authentication interface

![Compass Interface](docs/assets/gfm3.0/cf814fcd22faa8d7e066ec00b018860.jpg)

## 🛠️ How It Works

### 1️⃣ Discovery Phase (BLE)
- One device **advertises** itself via BLE
- Another device **scans** and finds the target
- BLE sends **basic info** (WiFi SSID, unique ID)
- **RSSI-based** distance estimation

### 2️⃣ Data Exchange (WiFi Direct)
- Devices switch to **WiFi Direct** after discovery
- High-speed **GPS and compass data** exchange
- Real-time position updates
- Secure peer-to-peer connection

### 3️⃣ User Feedback
- **Bearing & distance** calculation
- **Progressive vibration** intensity
- Visual direction indicators
- Connection status updates

![Settings Screen](docs/assets/gfm3.0/589960efe12dd7ad952a19a9459bd36.jpg)

## 🚀 Technical Implementation

### Core Stack
- **Flutter Framework** (>=3.0.0)
- **Firebase** – Authentication and data storage
- **Flutter Blue Plus** (^1.35.3) – BLE implementation
- **Geolocator** (^10.1.0) – Location services
- **Permission Handler** (^11.0.1) – Device permissions

### Configuration Options
- Adjustable signal strength thresholds
- Customizable vibration feedback intensity
- User authentication preferences
- Location update frequency

## 📱 Installation

### Option 1: Direct APK Installation (For Users)

1. **Download the APK** 📥
   - Visit our [Releases Page](https://github.com/UCLcaozhiyu/casa0015-Good-Friend-Medallion/releases)
   - Download the latest version

2. **Enable Installation** 🔓
   - Navigate to `Settings` > `Security`
   - Enable "Install from Unknown Sources"

3. **Install & Launch** 🚀
   - Open the APK file
   - Follow installation prompts
   - Launch from your home screen

### Option 2: Build from Source (For Developers)

1. **Prerequisites** ⚙️
   - Flutter SDK (>=3.0.0)
   - Android Studio / VS Code
   - Android 10+ (for WiFi Direct)
   - Git

2. **Clone and Setup** 💻
   ```bash
   git clone https://github.com/UCLcaozhiyu/casa0015-Good-Friend-Medallion.git
   cd casa0015-Good-Friend-Medallion
   flutter pub get
   ```

3. **Firebase Configuration** 🔥
   - Create a new Firebase project
   - Add `google-services.json` to `android/app`
   - Enable Authentication and Firestore

4. **Run the App** 🏃‍♂️
   ```bash
   flutter run
   ```

## 🔄 Future Roadmap

### Planned Features
- **Enhanced WiFi Direct Integration** – Faster data exchange
- **Advanced Location Features** – Improved accuracy and tracking
- **Signal Strength Optimization** – Better distance estimation
- **Additional Authentication Methods** – More login options
- **Offline Mode Enhancements** – Improved standalone operation
- **Group Finding Mode** – Find multiple friends simultaneously
- **Custom Vibration Patterns** – User-defined feedback patterns
- **Energy Optimization** – Extended battery life
- **Cross-Platform Support** – iOS, Web, Desktop versions

### Research Areas
- Machine learning for better distance estimation
- Advanced signal processing algorithms
- Battery consumption optimization
- Enhanced security protocols

## 🔒 Privacy & Security

- No external server dependency
- End-to-end encrypted communication
- Local data processing
- Minimal permission requirements
- Firebase security rules implementation

## 📚 Documentation

- [Project Website](https://uclcaozhiyu.github.io/casa0015-Good-Friend-Medallion/)
- [API Documentation](docs/api.md)
- [Development Guide](docs/development.md)
- [Privacy Policy](docs/privacy.md)

## 🤝 Contributing

We welcome contributions! Here's how you can help:
- Report bugs and suggest features
- Submit pull requests
- Improve documentation
- Share your experience

## 📧 Contact & Support

For questions or contributions, please:
- Open an issue on GitHub
- Email: [Your Email]
- Visit our [Discussion Board](https://github.com/UCLcaozhiyu/casa0015-Good-Friend-Medallion/discussions)

## 📓 Development Log

### Latest Update (April 27, 2025)

#### 🔧 BLE Device Name Display Fix
- **Issue**: Some devices were showing as "Unknown Device"
- **Solution**: Implemented improved device filtering and name resolution
```dart
_foundDevices = results.where((r) => 
  r.device.platformName.isNotEmpty || 
  r.device.localName.isNotEmpty || 
  r.advertisementData.advName.isNotEmpty
).toList();
```
- **Improvements**:
  - Better device name display
  - MAC address fallback for identification
  - Cleaner UI without debug information

### Development Timeline

#### 📅 Initial Setup
- Initialized Flutter project
- Configured core dependencies:
  - flutter_blue_plus: ^1.35.3
  - geolocator: ^10.0.1
  - vibration: ^1.7.4
  - permission_handler: ^11.0.1

#### 📅 Core Features Implementation
1. **Location Services**
   - GPS coordinates tracking
   - Permission handling
   - UI display integration

2. **BLE Integration**
   - Device scanning
   - Signal strength monitoring
   - Name filtering implementation

3. **User Feedback**
   - Vibration patterns
   - Visual indicators
   - Distance calculation

#### 📅 Technical Challenges Resolved

1. **Build System Issues**
   - Fixed JDK configuration
   - Resolved NDK setup problems
   - Optimized Gradle build process

2. **BLE Optimization**
   - Implemented RSSI smoothing
   - Added dynamic feedback adjustment
   - Enhanced UI responsiveness

3. **GPS Integration**
   - Added friend discovery logic
   - Implemented distance calculation
   - Optimized battery usage

### 🔄 Recent Improvements

1. **BLE RSSI Smoothing**
   - Continuous sampling implementation
   - Sliding average calculation
   - Stable distance feedback

2. **UI Enhancements**
   - Added progress indicators
   - Improved status icons
   - Enhanced visual feedback

3. **System Architecture**
```
[User Interface (UI)]
    ↓
[Location Module (GPS)] + [Bluetooth Module (BLE)]
    ↓
[Backend Server (Friend Location Database)]
    ↓
[Feedback Mechanism (Vibration / Icons / Sounds)]
```

### 📈 Upcoming Features

1. **Enhanced Friend Discovery**
   - GPS position upload module
   - Friend list management
   - Nearby friend notifications

2. **Advanced BLE Features**
   - Identity broadcasting
   - Selective device scanning
   - Connection state persistence

3. **UI/UX Improvements**
   - Animated direction indicators
   - Custom vibration patterns
   - Power efficiency optimizations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*This project is part of the CASA0015 Mobile Systems Interactions course at UCL.* 