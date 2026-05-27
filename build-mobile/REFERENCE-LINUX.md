# Linux Development Guide

## Android SDK on Linux

### Install Android SDK Command Line Tools

```bash
# Option 1: Package manager (recommended)
# Ubuntu/Debian
sudo apt install -y android-sdk
sudo apt install -y android-sdk-platform-tools
sudo apt install -y android-sdk-build-tools
sudo apt install -y android-sdk-commandlinetools
export ANDROID_SDK_ROOT=/usr/lib/android-sdk

# Fedora/RHEL
sudo dnf install android-sdk
sudo dnf install android-commandlinetools

# Arch Linux
sudo pacman -S android-sdk android-commandlinetools

# OpenSUSE
sudo zypper install android-sdk android-commandlinetools
```

### Option 2: Standalone SDK Manager

```bash
# Download commandlinetools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-*.zip -d sdk-tools
mkdir -p $ANDROID_SDK_ROOT/cmdline-tools
mv sdk-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest

# Accept licenses and install components
yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses
$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "platforms;android-36" \
  "build-tools;36.0.0" "platform-tools" "system-images;android-36;google_apis;x86_64"
```

### Install JDK

```bash
# Ubuntu/Debian
sudo apt install openjdk-21-jdk

# Fedora/RHEL
sudo dnf install java-21-openjdk-devel

# Arch Linux
sudo pacman -S jdk-openjdk

# OpenSUSE
sudo zypper install java-21-openjdk-devel
```

### Install KVM for Android Emulator (acceleration)

```bash
# Check if KVM is available
grep -E 'vmx|svm' /proc/cpuinfo

# Ubuntu/Debian
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
sudo adduser $USER libvirt
sudo adduser $USER kvm

# Fedora/RHEL
sudo dnf install -y qemu-kvm libvirt-daemon libvirt-client virt-manager
sudo systemctl enable --now libvirtd

# Arch Linux
sudo pacman -S qemu-kvm libvirt virt-manager
sudo systemctl enable --now libvirtd
```

## Flutter Linux Desktop Setup

### Install Flutter (if not already installed)

```bash
# Download Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux-3.44.0-stable.zip
sudo unzip -q flutter_linux-*.zip -d /opt
sudo chown -R $USER:$USER /opt/flutter
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
source ~/.bashrc

# Verify
flutter doctor
```

### Install Linux Desktop Dependencies

```bash
# Ubuntu/Debian
sudo apt install -y clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-13-dev

# Fedora/RHEL
sudo dnf install -y clang cmake git ninja-build gtk3-devel lzma-devel libstdc++-static

# Arch Linux
sudo pacman -S clang cmake git ninja pkgconf gtk3 lzma libstdc++-libs

# OpenSUSE
sudo zypper install clang cmake git ninja gtk3-devel liblzma-devel gcc-c++
```

### Enable Linux Platform

```bash
# Enable Linux desktop support
flutter create my_app --platforms linux
cd my_app
flutter pub get
```

## Flutter Linux Desktop Build

### Run Linux Desktop App

```bash
flutter run -d linux
flutter run -d linux --release
```

### Build Linux Packages

#### AppImage (recommended for distribution)

```bash
# Using linux_deploy (https://github.com/abumalick/linux_deploy)
# Install linuxdeploy
wget -c https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
chmod +x linuxdeploy-x86_64.AppImage

# Build AppImage
flutter build linux --release
./linuxdeploy-x86_64.AppImage --appdir AppDir \
  --exec $(pwd)/build/linux/x64/release/bundle/my_app \
  --desktop-file $(pwd)/linux/com.example.my_app.desktop \
  --icon $(pwd)/assets/icon.png \
  --output appimage
```

#### Flatpak

```bash
# Create Flatpak manifest
cat > com.example.my_app.json << 'EOF'
{
  "app-id": "com.example.my_app",
  "runtime": "org.freedesktop.Platform",
  "sdk": "org.freedesktop.Sdk",
  "command": "my_app",
  "modules": [
    {
      "name": "my-app",
      "buildsystem": "cmake",
      "sources": [
        { "type": "git", "url": ".", "branch": "main" }
      ]
    }
  ]
}
EOF

# Build with flatpak-builder
flatpak-builder --repo=repo build-dir com.example.my_app.json
flatpak build-bundle repo com.example.my_app.flatpak com.example.my_app
```

#### snap

```bash
# Install snapcraft
sudo snap install snapcraft --classic

# Create snap/snapcraft.yaml
cat > snap/snapcraft.yaml << 'EOF'
name: my-app
version: '1.0.0'
summary: My Flutter App
description: A Flutter desktop application
base: core22
grade: stable
confinement: strict

parts:
  flutter-linux:
    source: https://github.com/letsflatter/flutter-linux.git
    source-type: git
    plugin: nil
    override-build: |
      mkdir -p $SNAPCRAFT_PART_INSTALL/flutter
      cp -r flutter $SNAPCRAFT_PART_INSTALL/flutter/

  my-app:
    after: [flutter-linux]
    plugin: dump
    source: build/linux/x64/release/bundle
EOF

# Build snap
snapcraft
```

#### .deb (Debian/Ubuntu)

```bash
# After flutter build linux
flutter build linux --release

# Create .deb package
cd build/linux/x64/release/bundle
mkdir -p my-app/usr/bin my-app/usr/share/applications my-app/usr/share/icons/hicolor/256x256/apps/

cp my_app my-app/usr/bin/
cp com.example.my_app.desktop my-app/usr/share/applications/
cp ../assets/icon.png my-app/usr/share/icons/hicolor/256x256/apps/

# Build deb
dpkg-deb --build my-app
# Result: my-app.deb
```

## Linux-Specific Troubleshooting

### Flutter Linux Build Errors

| Issue | Cause | Fix |
|---|---|---|
| "gtk-3.0 not found" | Missing GTK3 dev headers | `sudo apt install libgtk-3-dev` (Debian) / `sudo dnf install gtk3-devel` (Fedora) |
| "ninja: command not found" | Ninja not installed | `sudo apt install ninja-build` / `sudo dnf install ninja-build` |
| "cmake not found" | CMake not installed | `sudo apt install cmake` / `sudo dnf install cmake` |
| "lzma not found" | Missing LZMA | `sudo apt install liblzma-dev` / `sudo dnf install lzma-devel` |
| "libstdc++ not found" | Missing C++ stdlib | `sudo apt install libstdc++-dev` / `sudo dnf install libstdc++-static` |
| "clang not found" | Missing Clang | `sudo apt install clang` / `sudo dnf install clang` |
| "pkg-config not found" | Missing pkg-config | `sudo apt install pkg-config` / `sudo dnf install pkgconf-pkg-config` |

### Android Emulator on Linux

| Issue | Cause | Fix |
|---|---|---|
| "HAXM not available" | No Intel VT-x/AMD-V | Use KVM: `sudo apt install qemu-kvm libvirt-daemon-system` |
| "Emulator crashes" | Missing OpenGL libs | `sudo apt install libgl1-mesa-dev` / `sudo dnf install mesa-libGLU` |
| "Emulator slow" | Not using hardware acceleration | Enable KVM (see above), set emulator GPU to Swiftshader or hardware |
| "Permission denied on /dev/kvm" | User not in kvm group | `sudo usermod -aG kvm $USER && newgrp kvm` |
| "Wayland not supported" | Using Wayland compositor | Set `ANDROID_EMULATOR_USE_SYSTEM_LIBC=1` or switch to X11 |

### Gradle on Linux

| Issue | Cause | Fix |
|---|---|---|
| "Gradle daemon not responding" | Port conflict | `./gradlew --stop && ./gradlew assembleDebug` |
| "Permission denied" | gradlew not executable | `chmod +x gradlew` |
| "Java version mismatch" | Wrong JDK | Set `JAVA_HOME` and verify with `java -version` |
| "Out of memory" | Gradle heap too small | Set `org.gradle.jvmargs=-Xmx4g` in gradle.properties |

### Common Linux Development Setup

```bash
# One-liner for Ubuntu/Debian (all-in-one)
sudo apt update && sudo apt install -y \
  openjdk-21-jdk \
  clang cmake git ninja-build pkg-config \
  libgtk-3-dev liblzma-dev libstdc++-13-dev \
  qemu-kvm libvirt-daemon-system libvirt-clients \
  android-sdk android-sdk-platform-tools android-sdk-build-tools \
  && sudo adduser $USER kvm

# One-liner for Fedora/RHEL
sudo dnf install -y \
  java-21-openjdk-devel \
  clang cmake git ninja-build gtk3-devel lzma-devel \
  qemu-kvm libvirt-daemon libvirt-client \
  android-sdk android-commandlinetools && \
  systemctl enable --now libvirtd
```

## Linux IDE Setup

### VS Code (recommended for cross-platform)

```bash
# Install VS Code
# Ubuntu/Debian
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/
echo 'deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main' | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt install -y code

# Fedora
sudo rpm -ivh https://packages.microsoft.com/linux/code/rpm/stable/code-*.rpm

# Arch
yay -S visual-studio-code-bin
```

### Install VS Code Extensions

```bash
# Flutter + Dart extensions
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code

# Kotlin extensions (for KMP)
code --install-extension mathiasfrohlich.kotlin

# Android extensions
code --install-extension Google.android-studio
```

### Android Studio on Linux

```bash
# Download Android Studio
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.2.2.12/android-studio-2024.2.2.12-linux.tar.gz
tar -xzf android-studio-*.tar.gz -C ~/opt
~/opt/android-studio/bin/studio.sh

# Add to PATH
echo 'export PATH="$HOME/opt/android-studio/bin:$PATH"' >> ~/.bashrc
```

## Linux CI/CD (GitHub Actions)

```yaml
name: Linux Build
on: [push, pull_request]
jobs:
  linux-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '21'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.0'
          cache: true
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build linux --release
```
