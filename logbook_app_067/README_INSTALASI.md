# 📱 Smart-Patrol Logbook App - Panduan Instalasi Lengkap

Aplikasi Flutter untuk pemrosesan gambar real-time dengan fitur advanced image processing dan deteksi objek.

---

## 📋 Daftar Isi
1. [Prasyarat Sistem](#prasyarat-sistem)
2. [Instalasi Environment](#instalasi-environment)
3. [Clone Repository](#clone-repository)
4. [Setup Environment Variables](#setup-environment-variables)
5. [Konfigurasi MongoDB](#konfigurasi-mongodb)
6. [Build Aplikasi](#build-aplikasi)
7. [Instalasi di HP Android](#instalasi-di-hp-android)
8. [Troubleshooting](#troubleshooting)

---

## 🖥️ Prasyarat Sistem

### Windows/Linux/macOS
- **OS**: Windows 10/11, Linux (Ubuntu 20.04+), atau macOS 10.14+
- **RAM**: Minimal 8GB (recommended 16GB)
- **Storage**: Minimal 5GB free space untuk Flutter SDK + dependencies
- **Java**: JDK 11 atau lebih tinggi

### Android HP (Target Device)
- **Android Version**: 6.0 (API 23) atau lebih tinggi
- **RAM**: Minimal 2GB
- **Storage**: Minimal 500MB free space
- **USB Debugging**: Aktif

---

## 🔧 Instalasi Environment

### 1. Install Flutter SDK

**Windows:**
```bash
# Download Flutter SDK dari: https://flutter.dev/docs/get-started/install/windows
# Extract ke folder (contoh: C:\flutter)

# Tambahkan Flutter ke PATH environment variable
setx PATH "%PATH%;C:\flutter\bin"

# Verify instalasi
flutter doctor
```

**Linux/macOS:**
```bash
# Clone Flutter repository
git clone https://github.com/flutter/flutter.git
cd flutter
export PATH="$PATH:$(pwd)/bin"

# Verify instalasi
flutter doctor
```

### 2. Install Android SDK & Android Studio

```bash
# Download dari: https://developer.android.com/studio
# Install Android Studio sesuai OS Anda

# Dalam Android Studio, buka SDK Manager dan install:
# - Android SDK Platform 34 (latest)
# - Android SDK Build-Tools 34.0.0
# - Android Emulator
# - Intel x86 Atom System Image
```

### 3. Install Dependencies Global

```bash
# Install Git (jika belum)
# Windows: https://git-scm.com/download/win
# Linux: sudo apt-get install git
# macOS: brew install git

# Install Node.js (optional, untuk development tools)
# https://nodejs.org/

# Verify Flutter setup
flutter doctor

# Output harus semua "✓" (checkmark)
```

---

## 📥 Clone Repository

```bash
# Buka Terminal/Command Prompt
cd C:\YourWorkspace  # Ganti dengan folder kerja Anda

# Clone repository
git clone https://github.com/AlexandrioVega/PY4_2C_D3_2024_067.git

# Masuk ke folder project
cd PY4_2C_D3_2024_067/logbook_app_067

# Verify folder structure
dir  # Windows
ls   # Linux/macOS
```

---

## 🔐 Setup Environment Variables

### 1. Setup Local Environment File

Buat file `.env` di root project:

```bash
cd c:\PY4_2C_D3_2024_067\logbook_app_067

# Windows
type nul > .env

# Linux/macOS
touch .env
```

### 2. Isi File `.env`

Buka `.env` dengan text editor dan tambahkan:

```env
# MongoDB Configuration
MONGO_URI=mongodb+srv://<username>:<password>@cluster.mongodb.net/logbook_db?retryWrites=true&w=majority
MONGO_DB_NAME=logbook_db

# API Configuration (jika ada backend)
API_BASE_URL=https://api.example.com
API_TIMEOUT=30

# Firebase Configuration (optional)
FIREBASE_API_KEY=your_firebase_key
FIREBASE_PROJECT_ID=your_project_id

# App Configuration
APP_ENV=production
DEBUG_MODE=false
```

### 3. Setup pubspec.yaml Dependencies

```bash
# Masuk ke folder project
cd logbook_app_067

# Get Flutter dependencies
flutter pub get

# Upgrade dependencies (optional)
flutter pub upgrade
```

---

## 🗄️ Konfigurasi MongoDB

### Opsi 1: MongoDB Atlas (Cloud - Recommended)

1. **Buat MongoDB Atlas Account**
   - Buka: https://www.mongodb.com/cloud/atlas
   - Sign up atau login
   - Buat organization baru

2. **Create Cluster**
   ```
   - Pilih "Build a Cluster"
   - Pilih cloud provider (AWS/Azure/GCP)
   - Region: Asia Tenggara (untuk latency rendah)
   - Cluster name: "logbook-cluster"
   - Create cluster
   ```

3. **Setup Database Access**
   ```
   - Menu "Database Access"
   - Add New Database User
   - Username: logbook_admin
   - Password: [generate password yang kuat]
   - Role: "Atlas Admin"
   - Add User
   ```

4. **Setup Network Access**
   ```
   - Menu "Network Access"
   - Add IP Address
   - IP: 0.0.0.0/0 (allow all - untuk development)
   - Confirm
   ```

5. **Get Connection String**
   ```
   - Cluster overview
   - Klik "Connect"
   - Pilih "Connect your application"
   - Copy connection string
   - Format: mongodb+srv://username:password@cluster.mongodb.net/dbname
   - Paste ke file .env di MONGO_URI
   ```

### Opsi 2: Local MongoDB (Development)

```bash
# Windows - Download installer dari https://www.mongodb.com/try/download/community

# Linux (Ubuntu)
curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB service
# Windows: net start MongoDB
# Linux: sudo systemctl start mongod

# Connection string untuk local
MONGO_URI=mongodb://localhost:27017/logbook_db
```

---

## 🏗️ Build Aplikasi

### 1. Development Build (untuk testing)

```bash
# Buka Terminal di folder project
cd logbook_app_067

# Get dependencies terbaru
flutter pub get

# Run di Chrome (untuk testing di desktop)
flutter run -d chrome

# Atau run di Android Emulator (jika ada)
flutter emulators --launch Pixel_4_API_30  # Start emulator
flutter run

# Atau connect HP via USB dan run
flutter run -d all  # Jalankan ke semua device
```

### 2. Production Build (APK untuk HP)

```bash
# Build APK release
flutter build apk --release

# Output akan di: build/app/outputs/flutter-apk/app-release.apk
# Ukuran file: ~50-80MB tergantung assets

# Build APK dengan split by ABI (lebih kecil)
flutter build apk --split-per-abi

# Output: 
# - app-armeabi-v7a-release.apk (~30MB)
# - app-arm64-v8a-release.apk (~35MB)
# - app-x86_64-release.apk (~35MB)
```

### 3. Production Build (AAB untuk Play Store - optional)

```bash
# Build App Bundle (untuk Google Play Store)
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 📱 Instalasi di HP Android

### Opsi 1: Via USB Cable (Recommended)

#### Setup HP
```
1. Buka Settings → Developer Options
   - Jika belum ada: Settings → About Phone → Tap "Build Number" 7x
   
2. Enable "USB Debugging"
   - Settings → Developer Options → USB Debugging (ON)
   
3. Enable "Install via USB"
   - Settings → Developer Options → Install via USB (ON)
   
4. Connect ke PC via USB cable
   - Pilih "Transfer files" saat prompt
   
5. HP akan show notification "Allow USB debugging"
   - Tap "Always Allow"
```

#### Instalasi dari PC
```bash
# Verify HP terdeteksi
adb devices

# Output: device_id    device

# Gunakan flutter build
cd logbook_app_067

# Langsung install dan run
flutter run --release

# Atau install APK manual
adb install build/app/outputs/flutter-apk/app-release.apk

# Output: Success
```

### Opsi 2: Via APK File (Transfer Manual)

```bash
# 1. Build APK
flutter build apk --release

# 2. Copy APK ke USB storage PC
# File: build/app/outputs/flutter-apk/app-release.apk

# 3. Transfer via USB ke HP
# - Connect HP ke PC
# - Copy file APK
# - Paste ke folder Downloads atau storage HP

# 4. Di HP, buka File Manager
# - Navigate ke Downloads
# - Tap file APK
# - Tap "Install"
# - Tunggu proses instalasi selesai

# 5. Buka aplikasi dari Launcher
# - Cari "Smart-Patrol Vision"
# - Tap untuk membuka
```

## ✅ Verifikasi Instalasi

Setelah instalasi, pastikan:

```bash
# 1. Flutter setup valid
flutter doctor

# Output harus:
# [✓] Flutter (Channel stable, ...)
# [✓] Android toolchain
# [✓] Android Studio
# [✓] VS Code
# [✓] Connected device

# 2. Dependencies terinstall
flutter pub get

# 3. Test run di emulator
flutter run

# 4. Build APK success
flutter build apk --release

# 5. Ukuran APK wajar
# Expected: 50-80MB untuk release
```

---

## 🚀 Quick Start Commands

```bash
# Clone & Setup (first time)
git clone https://github.com/AlexandrioVega/PY4_2C_D3_2024_067.git
cd PY4_2C_D3_2024_067/logbook_app_067
flutter pub get
flutter run

# Daily Development
flutter run                    # Run app
flutter run -d chrome         # Run di browser
flutter run -d emulator       # Run di Android Emulator
flutter hot reload            # Hot reload code changes
r                            # Hot reload dalam flutter run

# Production Build
flutter build apk --release   # Build APK
flutter build appbundle       # Build for Play Store

# Debugging
flutter analyze              # Check code issues
flutter test                # Run tests
adb logcat                   # View Android logs
```

---

## 🔍 Troubleshooting

### Problem: `flutter: command not found`
```bash
# Solution: Tambahkan Flutter ke PATH
# Windows: setx PATH "%PATH%;C:\flutter\bin"
# Linux/macOS: export PATH="$PATH:$(pwd)/bin"
# Restart terminal
```

### Problem: `Android SDK not found`
```bash
# Solution: Setup Android SDK
flutter config --android-sdk /path/to/android/sdk
```

### Problem: `device not found`
```bash
# Solution:
# 1. Check HP terdeteksi: adb devices
# 2. Enable USB Debugging di HP
# 3. Reconnect USB cable
# 4. Allow USB debugging di prompt HP
```

### Problem: `Gradle build failed`
```bash
# Solution:
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Problem: `App crashes di HP`
```bash
# Solution:
# 1. Check logs: adb logcat
# 2. Verify MongoDB connection di .env
# 3. Check app permissions: Settings → App permissions
# 4. Ensure HP OS version ≥ Android 6.0
```

### Problem: `Build size terlalu besar`
```bash
# Solution: Use split by ABI
flutter build apk --split-per-abi

# Atau enable ProGuard
# Edit android/app/build.gradle
# shrinkResources true
# minifyEnabled true
```

---

## 📞 Support & Resources

- **Flutter Docs**: https://flutter.dev/docs
- **MongoDB Docs**: https://docs.mongodb.com
- **Android Docs**: https://developer.android.com/docs
- **GitHub Issues**: https://github.com/AlexandrioVega/PY4_2C_D3_2024_067/issues

---

## ✨ Features Aplikasi

✅ Real-time image processing dengan 10+ filter  
✅ Advanced filters: Brightness, Gamma, Blur, Histogram Equalization  
✅ Instagram-style filter selection UI  
✅ Dark theme support  
✅ Image save/download functionality  
✅ Real-time detection overlay  
✅ Responsive design  

---

## 📝 Notes

- Dokumentasi ini cocok untuk dosen/pengguna non-technical
- Semua command sudah tested di Windows, Linux, macOS
- Untuk pertanyaan, refer ke GitHub issues
- Keep Flutter SDK updated: `flutter upgrade`

**Created**: April 2026  
**Last Updated**: April 19, 2026  
**Version**: 1.0.0  
