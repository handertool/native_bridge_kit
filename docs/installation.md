# Installation Guide

Complete platform-specific installation and setup instructions for native_bridge_kit.

## Prerequisites

Before installing, ensure you have:

- **Dart & Flutter**: Flutter 3.0+ and Dart 3.0+
  ```bash
  flutter --version  # Should show 3.0 or later
  ```

- **Git**: For cloning and version control
  ```bash
  git --version
  ```

## Platform-Specific Setup

Choose your development platform:

### macOS Setup

#### 1. Install Xcode (for iOS development)

```bash
# Via App Store (recommended) - search for Xcode
# OR via command line
xcode-select --install

# Verify installation
xcode-select -p  # Should show /Applications/Xcode.app/Contents/Developer
```

#### 2. Install Android Studio and Kotlin

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Android Studio
brew install android-studio

# After installation, run Android Studio setup
# File → Settings → Languages & Frameworks → Kotlin
# Enable Kotlin support
```

#### 3. Configure Android SDK and NDK

```bash
# Set ANDROID_HOME
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/emulator' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools' >> ~/.zshrc
source ~/.zshrc

# Install SDK tools
android update sdk --no-ui --all --filter build-tools-34.0.0
android update sdk --no-ui --all --filter android-34
```

#### 4. Verify Setup

```bash
flutter doctor

# Should show green checkmarks for:
# ✓ Flutter
# ✓ Android toolchain
# ✓ Xcode
# ✓ CocoaPods
```

---

### Linux Setup

#### 1. Install Build Tools

```bash
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  git \
  curl \
  clang \
  cmake
```

#### 2. Install Android SDK

```bash
# Install Java
sudo apt-get install -y openjdk-17-jdk

# Download Android SDK Command Line Tools
mkdir -p ~/Android/Sdk/cmdline-tools
cd ~/Android/Sdk/cmdline-tools

# Download (replace with latest version)
wget https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip
unzip commandlinetools-linux-*
mv cmdline-tools latest

# Set environment variables
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin' >> ~/.bashrc
source ~/.bashrc

# Accept licenses and install packages
yes | sdkmanager --licenses
sdkmanager "build-tools;34.0.0" "platforms;android-34" "ndk;26.0.10792818"
```

#### 3. Install Flutter (if not already installed)

```bash
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:`pwd`/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

flutter doctor
```

#### 4. Verify Setup

```bash
flutter doctor

# Should show green checkmarks for:
# ✓ Flutter
# ✓ Android toolchain
```

---

### Windows Setup

#### 1. Install Visual Studio Build Tools

Download and run [Visual Studio Build Tools](https://visualstudio.microsoft.com/downloads/):
- Select "Desktop development with C++"
- Install the tools

#### 2. Install Android Studio

- Download from [Android Studio](https://developer.android.com/studio)
- Run installer and follow setup wizard
- Install "Android SDK", "Android SDK Platform", and "Android Virtual Device"

#### 3. Configure Environment Variables

Open PowerShell as Administrator:

```powershell
# Set ANDROID_HOME
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "$env:USERPROFILE\AppData\Local\Android\sdk", "User")

# Add to PATH
$androidSdk = "$env:USERPROFILE\AppData\Local\Android\sdk"
$path = [Environment]::GetEnvironmentVariable("PATH", "User")
[Environment]::SetEnvironmentVariable("PATH", "$path;$androidSdk\tools;$androidSdk\tools\bin", "User")

# Restart PowerShell for changes to take effect
```

#### 4. Verify Setup

```powershell
flutter doctor

# Should show green checkmarks for:
# ✓ Flutter
# ✓ Android toolchain
```

---

## Add native_bridge_kit to Your Project

### 1. Update pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  native_bridge_kit: ^0.1.0        # runtime + annotations

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  native_bridge_kit_gen: ^0.1.0    # available in a later release
```

### 2. Get Dependencies

```bash
flutter pub get
```

### 3. Run Code Generation

```bash
flutter pub run build_runner build

# For continuous generation during development
flutter pub run build_runner watch
```

---

## Power Users — Individual Package Imports

If you only target one platform, you can import sub-packages directly instead of the facade:

```yaml
# Android-only (no Swift stubs)
dev_dependencies:
  build_runner: ^2.4.0
  native_bridge_kit_dart_gen: ^0.1.0
  native_bridge_kit_android_gen: ^0.1.0

# iOS-only (no Kotlin stubs)
dev_dependencies:
  build_runner: ^2.4.0
  native_bridge_kit_dart_gen: ^0.1.0
  native_bridge_kit_ios_gen: ^0.1.0

# Pure Dart / server-side (no Flutter runtime)
dependencies:
  native_bridge_kit_annotation: ^0.1.0
dev_dependencies:
  build_runner: ^2.4.0
  native_bridge_kit_dart_gen: ^0.1.0
```

---

## CLI Tool — drift-check

`native_bridge_kit_cli` is a standalone global tool, not a pubspec dependency.

```bash
# Install globally (once per machine / CI setup step)
dart pub global activate native_bridge_kit_cli

# Run drift-check from your project root
drift_check

# Or via dart run
dart pub global run native_bridge_kit_cli:drift_check
```

Use `drift_check` in CI to catch contract-handler drift before it reaches production:

```yaml
# Example GitHub Actions step
- name: Check for bridge drift
  run: |
    dart pub global activate native_bridge_kit_cli
    drift_check --fail-on-drift
```

---

## Verify Complete Installation

Run flutter doctor to verify all tools:

```bash
flutter doctor -v

# Expected output:
# ✓ Flutter (Channel stable, 3.0+)
# ✓ Android toolchain - develop for Android devices
# ✓ Xcode - develop for iOS (if on macOS)
# ✓ Android Studio
# ✓ IntelliJ IDEA Community Edition / VS Code (with Flutter extension)
# ✓ VS Code (version 1.XX)
# ✓ Connected device or emulator
```

All items should show checkmarks (✓).

---

## Platform-Specific Compilation

### Android Setup

1. **Configure build.gradle**

   `android/app/build.gradle.kts`:
   ```kotlin
   android {
       compileSdk 34

       defaultConfig {
           minSdk 21
           targetSdk 34
       }

       compileOptions {
           sourceCompatibility = JavaVersion.VERSION_17
           targetCompatibility = JavaVersion.VERSION_17
       }

       kotlinOptions {
           jvmTarget = "17"
       }
   }
   ```

2. **Add Kotlin Support**

   Ensure Kotlin is configured in your Android project.

3. **Test Build**

   ```bash
   flutter build apk --debug
   ```

### iOS Setup

1. **Update Deployment Target**

   In Xcode:
   - Open `ios/Runner.xcworkspace`
   - Select Runner project
   - Set deployment target to iOS 12.0+

2. **Install CocoaPods**

   ```bash
   sudo gem install cocoapods
   cd ios && pod install && cd ..
   ```

3. **Test Build**

   ```bash
   flutter build ios --debug
   ```

---

## Troubleshooting Installation

### "flutter doctor shows issues"

```bash
# Run detailed diagnostics
flutter doctor -v

# Fix common issues
flutter doctor --android-licenses  # Accept Android licenses
flutter pub global activate build_runner
```

### "Generator not found" error

```bash
# Ensure dev_dependencies are installed
flutter pub get

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build
```

### "Kotlin/Swift compiler errors"

- Check Kotlin version compatibility in `android/build.gradle.kts`
- Update Xcode to latest version
- Ensure minimum SDK versions match

### macOS M1/M2 specific issues

```bash
# If Flutter doesn't work on Apple Silicon
sudo softwareupdate -i -a
arch -arm64 flutter doctor
```

---

## Next Steps

1. **[Getting Started Guide](getting-started.md)** — Create your first bridge
2. **[Example Project](../examples/device-info-app)** — See a complete working app
3. **[Testing Guide](testing-guide.md)** — Learn unit testing patterns

---

**[← Back to Root README](../README.md)**
