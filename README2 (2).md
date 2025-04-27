# CASA0015-Mobile-Systems-Interactions
good friend medallion
# **🔵 P2P Direction Finder**
**"Find your target, no server required."**

> 📌 **A Bluetooth & WiFi Direct-based peer-to-peer location and direction finder.**  
> Inspired by the **Witcher's medallion**, this app vibrates when you are close to another user running the app. The closer you get, the stronger the vibration.

![Witcher Medallion](https://vignette.wikia.nocookie.net/witcher/images/0/03/Tw3_medallion.png/revision/latest/scale-to-width-down/2000?cb=20160416054840)  
**"The Witcher Medallion – "When danger is near, it trembles..."**
<sub>*Inspired by the Witcher's Medallion, this app helps you sense your target in the real world.*</sub>

---

## **🚀 Features**
✅ **P2P Communication** – No cloud, no server, full privacy.  
✅ **Hybrid Bluetooth & WiFi Direct** – BLE for discovery, WiFi Direct for fast data exchange.  
✅ **Real-time Distance & Direction** – Uses GPS & device sensors to calculate target location.  
✅ **Vibration Feedback** – The closer you get, the stronger the vibration.  
✅ **Works Offline** – Ideal for rescue, social encounters, or real-world games.  

---

## **🛠️ How It Works**
### **1️⃣ Discovery via Bluetooth (BLE)**
- The mobile phone positioning system provides coordinates.
- One device **advertises** itself via BLE.
- Another device **scans** and finds the target.
- BLE only sends **basic info** (WiFi SSID, unique ID).

### **2️⃣ High-Speed Data Exchange via WiFi Direct**
- Once discovered, devices switch to **WiFi Direct**.
- **GPS and compass data** are exchanged in real-time.
- **Distance & direction** are computed **locally**.

### **3️⃣ Real-time Feedback**
- The app calculates **bearing & distance**.
- **Vibration intensity increases** as you get closer.
- No internet required! **Fully offline, private, secure.**

---

## **📦 Installation**
### **🔹 Prerequisites**
- **Flutter 3.0+**
- **Android 10+ (for WiFi Direct)**
- **Bluetooth & Location Permissions Enabled**

### **🔹 Clone & Run**
```sh
git clone https://github.com/UCLcaozhiyu/CASA0015-Mobile-Systems-Interactions.git
cd P2P-Direction-Finder
flutter pub get
flutter run
```

## **📝 Development Journey**

### **Project Evolution**
1. **Initial Concept Development**
   - Based on Witcher's medallion concept
   - Focus on P2P communication
   - Emphasis on privacy and offline functionality

2. **Technical Research Phase**
   - Bluetooth Low Energy (BLE) capabilities study
   - WiFi Direct implementation research
   - Location services integration
   - Sensor data processing

### **Environment Configuration Attempts**
1. **Initial Setup (the_good_friend_medallion_new)**
   - First attempt at project configuration
   - Basic Flutter environment setup
   - Initial dependency integration
   - Basic project structure implementation
   - Encountered Flutter version compatibility issues

2. **Optimization Phase (the_good_friend_medallion_optimized)**
   - Refined project structure
   - Optimized dependency management
   - Enhanced build configurations
   - Improved development workflow
   - Resolved Android SDK version conflicts

### **Core Development Phases**
1. **Service Layer Implementation**
   - Bluetooth service development
   - Location service integration
   - QR code scanning functionality
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

### **Dependencies and Configuration**
Key dependencies used in the project:
- flutter_blue_plus: ^1.31.13 (Bluetooth functionality)
- geolocator: ^10.1.0 (Location services)
- flutter_spinkit: ^5.2.0 (UI components)
- provider: ^6.1.1 (State management)
- shared_preferences: ^2.2.2 (Local storage)

### **Major Challenges Faced**

1. **Environment Configuration**
   - Flutter SDK version conflicts
   - Android SDK version requirements
   - Device connection and debugging issues
   - Build configuration problems
   - Multiple environment setup attempts

2. **Implementation Challenges**
   - Bluetooth service implementation
   - Location service permissions
   - QR code scanning functionality
   - State management architecture
   - Service layer organization
   - Battery optimization for continuous operation

3. **Project Structure**
   - Directory organization
   - Code reusability
   - Modular design
   - Service layer implementation
   - Cross-platform compatibility

### **Solution Attempts**

1. **Environment Setup**
   - Multiple project configurations (new and optimized versions)
   - Updated Flutter SDK
   - Adjusted Android SDK versions
   - Modified build.gradle configurations
   - Implemented proper device connection protocols

2. **Code Architecture**
   - Reorganized project structure
   - Separated core functionality modules
   - Implemented service layer
   - Optimized state management
   - Created modular components
   - Implemented efficient battery management

3. **Feature Implementation**
   - Step-by-step implementation of core features
   - Regular testing and validation
   - Reference implementation from existing codebases
   - Service layer integration
   - Performance optimization

## **Current Status**
The project is in the restructuring phase, focusing on:
1. Reorganizing project structure
2. Implementing core features step by step
3. Ensuring each component is functional
4. Service layer implementation
5. State management optimization
6. Battery consumption optimization

## **Next Steps**
1. Complete basic project structure
2. Implement core feature modules
3. Add necessary testing
4. Optimize user experience
5. Implement service layer
6. Enhance state management
7. Improve battery efficiency
8. Add comprehensive documentation

## **Important Considerations**
1. Ensure proper Flutter environment configuration
2. Maintain Android SDK version compatibility
3. Verify device connection status during testing
4. Implement proper permission management
5. Follow service layer architecture
6. Maintain proper state management
7. Optimize battery consumption
8. Ensure cross-platform compatibility

## **Reference Resources**
1. [Flutter Official Documentation](https://flutter.dev/docs)
2. [flutter_blue_plus Documentation](https://pub.dev/packages/flutter_blue_plus)
3. [geolocator Documentation](https://pub.dev/packages/geolocator)
4. [Provider Documentation](https://pub.dev/packages/provider)
5. [Flutter Service Layer Architecture](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options)
6. [Android Battery Optimization](https://developer.android.com/training/monitoring-device-state/battery-monitoring)

## **Contact Information**
For contributions or inquiries, please contact the development team.
