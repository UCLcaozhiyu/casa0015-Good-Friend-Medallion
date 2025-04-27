# 📖 Development Log: The Good Friend Medallion App

A Flutter app for peer-to-peer friend tracking, combining **BLE** (Bluetooth Low Energy) and **GPS** to locate nearby friends with vibration feedback.

---

# ✨ Table of Contents
- [🚀 Project Goal](#-project-goal)
- [🛠️ Development Timeline](#-development-timeline)
  - [📅 Step 1: Setup Flutter Project](#-step-1-setup-flutter-project)
  - [📅 Step 2: Core Features Implementation](#-step-2-core-features-implementation)
  - [📅 Step 3: Testing Setup](#-step-3-testing-setup)
  - [📅 Step 4: BLE Permissions on Android](#-step-4-ble-permissions-on-android)
  - [📅 Step 5: Research & Learning](#-step-5-research--learning)
  - [📅 Step 6: Build Troubleshooting - JDK Issue](#-step-6-build-troubleshooting-april-27-2025)
  - [📅 Step 7: Build Troubleshooting - NDK Issue](#-step-7-build-troubleshooting-ndk-issue-april-27-2025)
- [📈 Next Plans](#-next-plans)
- [🖼️ Sneak Peek of Current App](#-sneak-peek-of-current-app)
- [📚 References](#-references)

---

# 🚀 Project Goal

Design and build an app where:

- Two users launch the app simultaneously.
- The app helps them find each other:
  - **Far away** ➔ Show direction and distance using GPS.
  - **Close proximity** ➔ Switch to BLE scanning and provide vibration feedback based on distance.

Inspired by the Witcher's Medallion that senses nearby presence.

---

# 🛠️ Development Timeline

## 📅 Step 1: Setup Flutter Project

- Initialized a Flutter project named **`the_good_friend_medallion`**.
- Configured `pubspec.yaml` with necessary dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_blue_plus: ^1.35.3
  geolocator: ^10.0.1
  vibration: ^1.7.4
  permission_handler: ^11.0.1
  cupertino_icons: ^1.0.8
```

- Installed packages with:

```bash
flutter pub get
```

---

## 📅 Step 2: Core Features Implementation

### ✅ Location Fetching
- Used `geolocator` to request location permissions and fetch the device's current GPS coordinates.
- Displayed the coordinates on the UI.

### ✅ BLE Scanning
- Integrated `flutter_blue_plus` to scan for nearby BLE devices.
- Filtered devices by checking non-empty names.
- Displayed the RSSI (signal strength) of the detected device.

### ✅ Vibration Feedback
- Used `vibration` plugin to trigger different vibration patterns based on the RSSI value.

### ✅ Permissions Handling
- Used `permission_handler` to request Bluetooth and location permissions.

---

## 📅 Step 3: Testing Setup

- Customized `widget_test.dart` to match real UI elements.
- Verified initial screen displays location text and scan button.

---

## 📅 Step 4: BLE Permissions on Android

- Configured `AndroidManifest.xml` with required permissions for BLE.

---

## 📅 Step 5: Research & Learning

- Studied FlutterBluePlus documentation.
- Understood BLE scanning behaviors and limitations.
- Planned future WiFi Direct integration for better data sync.

---

## 📅 Step 6: Build Troubleshooting 

### 🔧 Problem Encountered
- When running `flutter run`, the project failed during Gradle's `assembleDebug` task.
- Error messages included:
  - `Execution failed for task ':app:compileDebugJavaWithJavac'`
  - `Could not resolve all files for configuration ':app:androidJdkImage'`
  - `Error while executing process jlink.exe`

### 🔎 Root Cause
- `jlink` requires a full **standard JDK 11+**, but the system defaulted to an incomplete JBR (JetBrains Runtime) without full `jmod` support.
- Project was also targeting Java 8 (`source 8` warnings), which is outdated for modern Android builds.

### 🛠 Solutions Applied
1. Installed **Oracle JDK 17** for Windows.
2. Configured `JAVA_HOME` system environment variable to point to the new JDK.
3. Updated `Path` to include `%JAVA_HOME%\bin`.
4. Verified JDK version via terminal.
5. Cleared and rebuilt the project successfully.

### 📚 Lessons Learned
- Flutter Android builds are sensitive to JDK version and configuration.
- Always avoid using non-standard runtime environments like JBR for Gradle builds.
- Setting correct `JAVA_HOME` is crucial for smooth Flutter + Android integration.

---

## 📅 Step 7: Build Troubleshooting - NDK Issue 

### 🔧 Problem Encountered
- Running `flutter run` failed during the Gradle `assembleDebug` task.
- Error log highlighted:
  - `NDK at C:\Users\22050\AppData\Local\Android\sdk\ndk\26.3.11579264 did not have a source.properties file`
  - `A problem occurred configuring project ':app'`

### 🔎 Root Cause
- Installed NDK version `26.3.11579264` was incomplete.
- Missing `source.properties` file, which is required by Android Gradle Plugin to correctly configure the CMake toolchain and native builds.
- Although the Flutter app itself did not explicitly depend on native libraries (C++/JNI), the Android build pipeline still initialized NDK by default.

### 🛠 Solutions Applied
1. Opened **Android Studio** → **SDK Manager** → **SDK Tools** tab.
2. Uninstalled the faulty NDK `26.3.11579264`.
3. Installed a stable NDK version `25.2.9519653` via the "Show Package Details" option.
4. Edited `local.properties` to explicitly point to the correct NDK.
5. Ran cleaning commands and rebuilt.
6. Verified successful build and deployment.

### 📚 Lessons Learned
- Flutter's Android build system may implicitly require a valid NDK setup even if no native code is used.
- Always ensure installed SDK/NDK components are complete (contain `source.properties`).
- Prefer stable NDK versions aligned with your current Android Gradle Plugin version.
- Keeping `local.properties` clean and specific helps avoid build misconfigurations.

---

# 📈 Next Plans

- [ ] Add friend pairing functionality.
- [ ] Display direction and distance on a map.
- [ ] Create animated directional arrow.
- [ ] Optimize BLE scanning for power efficiency.

---

## Step 8: BLE Distance Optimization and Friend Matching (April 27, 2025)

### 🔧 Problems Addressed
- Limited BLE effective range makes direct long-distance friend matching difficult.
- High fluctuation of RSSI values causes unstable vibration/distance feedback.

### 🛠 Solutions Implemented
1. **BLE RSSI Smoothing**
   - Introduced continuous RSSI sampling with sliding average to avoid instant spikes.
   - Used the RSSI from connected BLE device streams instead of advertisement packets.

2. **Dynamic Vibration Feedback Adjustment**
   - Dynamically adjust vibration strength based on real-time RSSI changes (heavyImpact/mediumImpact/lightImpact).
   - Allowed users to adjust RSSI thresholds within the app and reset to defaults.

3. **Real-Time Adjustable UI Elements**
   - Added a LinearProgressIndicator to represent signal strength visually.
   - Enlarged distance status icons (🔥🙂👀) for better visual feedback.

4. **Exploration of BLE Broadcasting and GPS Strategy**
   - Acknowledged BLE's physical broadcasting limits.
   - Planned future implementation combining GPS for mid-range detection and BLE for close-range precision.

### 🖼️ Updated Interface Screenshot
(Insert screenshot of updated app interface here)

---

## Step 9: Planning GPS Assisted Friend Discovery (April 27, 2025)

### 🧠 Insights and Ideas
- BLE can only accurately sense within ~10 meters.
- GPS is suitable for detecting friends at a rough distance of 50–300 meters.

### 🛠 Planned Implementations

1. **Real-Time GPS Position Upload**
   - Use the `geolocator` plugin to periodically fetch device coordinates.
   - Upload location data to Supabase / Firebase backend.

2. **Friend List Management**
   - Predefined friend identities (username / MAC address / UID) within the app.
   - Scan and match only specific friend devices.

3. **Nearby Friend Matching Logic**
   - Use the Haversine formula or `geolocator.distanceBetween()` to compute straight-line distances.
   - If within 100 meters, trigger a "Friend Nearby" notification; otherwise continue monitoring.

4. **Advanced Mode: Broadcasting Identity via BLE**
   - Each device periodically broadcasts a unique ID via BLE advertisements.
   - Devices match nearby broadcast IDs against a friend list without establishing connections.

### 🔥 Future Extensions
- Add geo-fence based event triggering.
- Develop multi-user collaborative search modes (group work / event meetups).
- Implement LAN-only peer-to-peer synchronization without internet.

### 📈 Updated Next Plans
- [ ] Complete the GPS position upload module.
- [ ] Integrate friend detection logic with UI notifications.
- [ ] Design a BLE identity broadcasting and binding system.
- [ ] Develop animation and vibration feedback for better UX.
- [ ] Evaluate Supabase vs Firebase for synchronization.
- [ ] Implement privacy protection and data consent prompts.

### 🖼️ Planned System Architecture
```
[User Interface (UI)]
    ↓
[Location Module (GPS)] + [Bluetooth Module (BLE)]
    ↓
[Backend Server (Friend Location Database)]
    ↓
[Feedback Mechanism (Vibration / Icons / Sounds)]
```

---

(Step 10 and beyond to be continued based on actual development progress)


# 🖼️ Sneak Peek of Current App

| Screenshot | Description |
|------------|-------------|
| ![Main UI](link_to_main_ui_image) | Displaying location, BLE scan status, and scan button |
| ![Login UI](link_to_login_ui_image) | Planned login screen inspired by the Witcher's Medallion |

---

# 📚 References

- [FlutterBluePlus Official Docs](https://pub.dev/packages/flutter_blue_plus)
- [Geolocator Package](https://pub.dev/packages/geolocator)
- [Flutter Vibration Package](https://pub.dev/packages/vibration)
- [Permission Handler](https://pub.dev/packages/permission_handler)

---

> “The path will be dangerous, but your medallion will guide you.” 🐺
