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

This is the Final assessment template for CASA0014 - Please use this template and edit the relevant sections to personalise.
This section has a short introduction to what the application is

## Use this README File 

Use this section to show us what your Mobile App is about.   Include a Screenshot to the App, link to the various frameworks you've used. Include your presentation video here that shows off your Mobile App.   Emojis are also fun to include 📱 😄

Look at some other Flutter Apps online and see how they use there README File.  Good examples are:

- https://github.com/miickel/flutter_particle_clock
- https://github.com/Tarikul711/flutter-food-delivery-app-ui    
- https://github.com/mohak1283/Instagram-Clone


## Include A Section That Tells Developers How To Install The App

Include a section that gives intructions on how to install the app or run it in Flutter.  What versions of the plugins are you assuming?  Maybe define a licence

##  Contact Details

Having Contact Details is also good as it shows people how to get in contact with you if they'd like to contribute to the app. 
