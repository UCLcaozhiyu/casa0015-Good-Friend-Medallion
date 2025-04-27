# **🔵 Good Friend Medallion - P2P Direction Finder**

**"Find your target, no server required."**
> "When danger is near, it trembles..." - Inspired by the Witcher's medallion
> 📌 **A Bluetooth-based peer-to-peer location and direction finder.**  
> Inspired by the **Witcher's medallion**, this app vibrates when you are close to another user running the app. The closer you get, the stronger the vibration.

![Witcher Medallion](https://vignette.wikia.nocookie.net/witcher/images/0/03/Tw3_medallion.png/revision/latest/scale-to-width-down/2000?cb=20160416054840)  
**"The Witcher Medallion – When danger is near, it trembles..."**
<sub>*Inspired by the Witcher's Medallion, this app helps you sense your target in the real world.*</sub>

---

## 🎯 Project Design Idea

### Core Concept
Just like the Witcher's medallion vibrates in the presence of magic, this app helps you sense your friends in the real world. The closer you get to your target, the stronger the vibration feedback becomes.

### Key Design Features
✅ **P2P Communication** – No cloud, no server, full privacy  
✅ **Real-time Distance & Direction** – Uses GPS & device sensors to calculate target location  
✅ **Vibration Feedback** – The closer you get, the stronger the vibration  
✅ **Works Offline** – Ideal for rescue, social encounters, or real-world games  

### How It Works
1. **Discovery via Bluetooth (BLE)**
   - One device advertises itself via BLE
   - Another device scans and finds the target
   - BLE exchanges basic identification info

2. **Real-time Feedback**
   - The app calculates bearing & distance
   - Vibration intensity increases as you get closer
   - No internet required! Fully offline, private, secure

![App Interface](docs/assets/gfm3.0/b0ae231ef1bb6dbf41cb21c37790aa5.jpg)

![App Interface](docs/assets/gfm3.0/b0ae231ef1bb6dbf41cb21c37790aa5.jpg)

## 🌟 Overview

Good Friend Medallion is an innovative mobile application that combines Bluetooth Low Energy (BLE) and GPS technology to help you find your friends in the real world. Just like the Witcher's medallion vibrates when magic is near, this app provides haptic feedback as you get closer to your friends.

**"Find your target, no server required."**

![Location Tracking](docs/assets/gfm3.0/d9ea1f52dcced32691b50368b3a048a.jpg)

## ✨ Key Features

### 🔍 Core Functionality
- **P2P Communication** – No cloud, no server, full privacy
- **Hybrid Technology** – BLE for close-range discovery, GPS for longer distances
- **Real-time Updates** – Instant distance and direction information
- **Works Offline** – Ideal for rescue, social encounters, or real-world games

### 📱 Smart Interface
- **Dynamic Compass** – Points directly to your friend's location
- **Signal Strength Meter** – Visual representation of connection strength
- **Distance Indicator** – Visual and haptic feedback
- **Device Scanner** – Discover nearby friends automatically

![Compass Interface](docs/assets/gfm3.0/cf814fcd22faa8d7e066ec00b018860.jpg)

## 🛠️ How It Works

### 1️⃣ Discovery Phase (BLE)
- Device advertises itself via BLE
- Other devices scan and find targets
- RSSI-based distance estimation
- Basic device information exchange

### 2️⃣ Location Tracking
- GPS coordinates tracking
- Real-time distance calculation
- Bearing computation for direction
- Location permission handling

### 3️⃣ User Feedback
- Visual direction indicator
- Progressive vibration intensity
- Distance-based alerts
- Connection status updates

![Settings Screen](docs/assets/gfm3.0/589960efe12dd7ad952a19a9459bd36.jpg)

## 🚀 Technical Implementation

### Core Stack
- **Flutter Framework** (>=3.0.0)
- **Flutter Blue Plus** (^1.35.3) – BLE implementation
- **Geolocator** (^10.1.0) – Location services
- **Permission Handler** (^11.0.1) – Device permissions
- **Vibration** (^1.7.4) – Haptic feedback

### Configuration Options
- Adjustable signal strength thresholds
- Customizable vibration patterns
- Location update frequency
- Device scanning intervals

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
   - Android 10+ (for BLE support)
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

## 📈 Project Evolution

### Initial Concept Development
- Based on Witcher's medallion concept
- Focus on P2P communication
- Emphasis on privacy and offline functionality

### Technical Research Phase
- Bluetooth Low Energy (BLE) capabilities study
- Location services integration
- Sensor data processing
- Battery optimization research

### Core Development Phases
1. **Service Layer Implementation**
   - Bluetooth service development
   - Location service integration
   - State management architecture

2. **UI/UX Development**
   - Medallion-inspired interface design
   - Real-time feedback visualization
   - Vibration intensity indicators
   - User-friendly navigation

3. **Testing and Optimization**
   - Performance testing
   - Battery consumption optimization
   - Connection stability improvements
   - User experience refinement

## 🔄 Future Roadmap

### Planned Features
- **WiFi Direct Integration** – For faster data exchange
- **Enhanced Location Features** – Improved accuracy and tracking
- **Signal Strength Optimization** – Better distance estimation
- **Group Finding Mode** – Find multiple friends simultaneously
- **Custom Vibration Patterns** – User-defined feedback patterns
- **Energy Optimization** – Extended battery life
- **Cross-Platform Support** – iOS, Web, Desktop versions

### Research Areas
- WiFi Direct implementation possibilities
- Advanced signal processing algorithms
- Battery consumption optimization
- Enhanced security protocols

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

### 🔄 Recent Improvements

1. **BLE RSSI Smoothing**
   - Continuous sampling implementation
   - Sliding average calculation
   - Stable distance feedback

2. **UI Enhancements**
   - Added progress indicators
   - Improved status icons
   - Enhanced visual feedback

### 📈 Upcoming Features

1. **Enhanced Friend Discovery**
   - Improved BLE scanning
   - Better device filtering
   - Nearby friend notifications

2. **Advanced BLE Features**
   - Identity broadcasting
   - Selective device scanning
   - Connection state persistence

3. **UI/UX Improvements**
   - Animated direction indicators
   - Custom vibration patterns
   - Power efficiency optimizations

## 🔒 Privacy & Security

- No external server dependency
- Local data processing only
- Minimal permission requirements
- Secure BLE communication

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

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*This project is part of the CASA0015 Mobile Systems Interactions course at UCL.* 