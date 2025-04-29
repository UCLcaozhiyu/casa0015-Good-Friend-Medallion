# **🔵 Good Friend Medallion - P2P BLE Finder**

**"Find your target, no server required."**

> 📌 **A Bluetooth-based peer-to-peer location and direction finder.**  
> Inspired by the **Witcher's medallion**, The program vibrates when you are near another user, and use Magic (BLE) to probe nearby Bluetooth devices to find out how far away they are from you, and the closer you are after docking that device, the stronger the vibration.

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

2. **Real-time Feedback**
   - The app calculates bearing & distance
   - Vibration intensity increases as you get closer
   - No internet required! Fully offline, private, secure

## Good Friends Medal v3.0 Introduction

![App Interface](landingpage/assets/gfm3.0/589960efe12dd7ad952a19a9459bd36.jpg)

## 🌟 Overview

Good Friend Medallion is an innovative mobile application that combines Bluetooth Low Energy (BLE) and GPS technology to help you find your friends in the real world. Just like the Witcher's medallion vibrates when magic is near, the app can also help you detect nearby Bluetooth devices and tell you the distance to you, this app provides haptic feedback as you get closer to Bluetooth signal source. Let all hidden Bluetooth devices have nowhere to hide before you!

**"Find your target, no server required."**

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
- **Device Scanner** – Discover nearby automatically
## QR Code docking and data logging
![Compass Interface](landingpage/assets/gfm3.0/cf814fcd22faa8d7e066ec00b018860.jpg)
## The compass points to the friend screen
![Location Tracking](landingpage/assets/gfm3.0/d9ea1f52dcced32691b50368b3a048a.jpg)
## Bluetooth device detection function page
![Location Tracking](landingpage/assets/gfm3.0/b0ae231ef1bb6dbf41cb21c37790aa5.jpg)


## 🛠️ How It Works

### 1️⃣ Discovery Phase (BLE)
- Device advertises itself via BLE
- Other devices scan and find targets
- RSSI-based distance estimation

### 2️⃣ Location Tracking
- GPS coordinates tracking
- Real-time distance calculation
- Bearing computation for direction
- Location permission handling

### 3️⃣ User Feedback
- Visual direction indicator
- Progressive vibration intensity
- Connection status updates

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

### Latest Update (April 28, 2024)

#### 🔧 BLE Connection and RSSI Enhancement
- **Device List Display**
  - Improved RSSI signal strength visualization
  - Added distance categories with color coding
  - Enhanced device name resolution
  ```dart
  Text(
    'RSSI: ${result.rssi} dBm (${_getDistanceCategory(result.rssi.toDouble())})',
    style: TextStyle(
      color: result.rssi > -70 ? Colors.green : 
             result.rssi > -90 ? Colors.orange : Colors.red,
    ),
  )
  ```

![Enhanced Device List](assets/updates/2024-04-28/device_list.png)
*Enhanced device list with RSSI values and distance categories*

- **Connection Logic**
  - Implemented stable reconnection mechanism
  - Added connection state verification
  - Enhanced error handling
  - Optimized MTU settings for better performance

![Connection Workflow](assets/updates/2024-04-28/connection_flow.png)
*Updated Bluetooth connection workflow diagram*

- **RSSI Monitoring**
  - Added timeout handling
  - Improved update frequency
  - Enhanced stability
  - Better disconnection handling

![RSSI Monitoring](assets/updates/2024-04-28/rssi_monitoring.png)
*Real-time RSSI monitoring and distance feedback*

For detailed changelog, see [Update Log](app_update.md)

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
   - Custom vibration patterns
   - Power efficiency optimizations

## 🔒 Privacy & Security

- No external server dependency
- Local data processing only
- Minimal permission requirements
- Secure BLE communication

## 📚 Documentation

- [Project Website](https://uclcaozhiyu.github.io/casa0015-Good-Friend-Medallion/)

## 🤝 Contributing

We welcome contributions! Here's how you can help:
- Report bugs and suggest features
- Improve documentation
- Share your experience

## 📧 Contact & Support

For questions or contributions, please:

- Email: [ucfnzca@ucl.ac.uk]

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Developed by: Zhiyu Cao
- Email: [ucfnzca@ucl.ac.uk]
---

*This project is part of the CASA0015 Mobile Systems Interactions course at UCL.*

## 最新更新

### 2024年4月28日更新
- 优化了蓝牙设备列表显示和连接逻辑
- 改进了RSSI信号强度监控
- 提升了应用性能和稳定性
- 详细更新内容请查看 [更新日志](app_update.md)

## 功能特点

- 蓝牙设备扫描和连接
  - 实时RSSI信号强度显示
  - 距离类别指示（Very Close/Near/Moderate/Far）
  - 信号强度颜色编码
  - 自动重连机制
- 二维码配对系统
- 电子罗盘导航
- 好友管理系统

## 安装要求

- Flutter 3.0.0 或更高版本
- Android 6.0 (API level 23) 或更高版本
- iOS 11.0 或更高版本
- 支持BLE的设备

## 权限要求

- 蓝牙权限（扫描和连接）
- 位置权限
- 相机权限（用于扫描二维码）

## 开发环境设置

1. 克隆仓库
```bash
git clone https://github.com/yourusername/good-friend-medallion.git
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行应用
```bash
flutter run
```

## 使用说明

1. 启动应用并授予必要权限
2. 使用二维码扫描添加好友
3. 在蓝牙界面查看附近的好友设备
4. 使用罗盘功能导航到好友位置

## 更新日志

查看完整的更新历史请访问 [更新日志](app_update.md)

## 截图

[在此处添加最新的应用截图]

## 贡献指南

欢迎提交 Pull Requests 和 Issues。

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件 

A revolutionary Bluetooth-based proximity detection and navigation application that helps users maintain optimal social distancing while staying connected.

## Core Concept
The Good Friend Medallion app uses Bluetooth Low Energy (BLE) technology to create a virtual "social bubble" around users, helping them maintain appropriate physical distances in social settings.

## Key Design Features
- Real-time distance monitoring using BLE RSSI
- Visual and haptic feedback for distance awareness
- Directional guidance using compass integration
- Social distance alerts and notifications
- API-enhanced location tracking and synchronization

## How It Works
1. Users pair their devices via Bluetooth
2. The app continuously monitors signal strength (RSSI)
3. Distance is calculated and displayed in real-time
4. Visual and haptic feedback is provided based on proximity
5. API integration enhances location accuracy and tracking

## Technical Implementation
- BLE GATT profile for device communication
- RSSI-based distance estimation
- Compass integration for directional guidance
- API integration for enhanced functionality
- Real-time data synchronization

## Installation
1. Clone the repository
2. Install dependencies: `npm install`
3. Run the development server: `npm start`
4. Build for production: `npm run build`

## Project Evolution
- Initial release: Basic BLE connectivity
- Version 1.1: Added RSSI monitoring
- Version 1.2: Implemented compass integration
- Version 1.3: Enhanced with API support
- Current version: Optimized performance and stability

## Latest Update (April 28, 2024)
### BLE Connection and RSSI Enhancements
- Improved RSSI signal strength display
- Enhanced connection stability
- Optimized distance calculation
- Added API integration for better accuracy

### Device List Display Improvements
- Color-coded signal strength indicators
- Distance category display
- Enhanced connection status feedback

### Connection Logic
- More reliable device pairing
- Improved error handling
- Better reconnection mechanism

### RSSI Monitoring
- Optimized reading frequency
- Enhanced stability
- Better timeout handling

### API Integration
- Enhanced compass functionality
- Improved location tracking
- Real-time data synchronization
- Better device management

## Future Roadmap
- Enhanced API features
- Improved accuracy algorithms
- Additional social features
- Cross-platform compatibility

## Contributing
We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details.

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 