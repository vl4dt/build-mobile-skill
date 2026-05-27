#!/bin/bash
# Build Mobile environment audit script
# Outputs current SDK state for SKILL.md updates
# Run this and copy the output into the Environment table placeholders
# Example: SDK_PATH=<path from output>, JDK_VERSION=<version>, etc.

SDK="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
if [ -z "$SDK" ] || [ ! -d "$SDK" ]; then
    echo "ERROR: Android SDK not found. Set ANDROID_HOME or ANDROID_SDK_ROOT."
    exit 1
fi

echo "=== Build Mobile Environment Audit ==="
echo "SDK: $SDK"
echo "JAVA: $(java -version 2>&1 | head -1)"
echo "JAVA_HOME: $JAVA_HOME"
echo ""
echo "Platforms:"
ls "$SDK/platforms/" 2>/dev/null | tr '\n' ', '
echo ""
echo "Build Tools:"
ls "$SDK/build-tools/" 2>/dev/null | tr '\n' ', '
echo ""
echo "System Images:"
ls "$SDK/system-images/" 2>/dev/null | tr '\n' ', '
echo ""
echo "CMake:"
ls "$SDK/cmake/" 2>/dev/null | tr '\n' ', '
echo ""
echo "AVDs:"
ls "$HOME/.android/avd/" 2>/dev/null | grep -v '\.ini$' | tr '\n' ', '
echo ""
echo "ADB devices:"
adb devices 2>/dev/null
echo ""
echo "Flutter:"
if command -v flutter &>/dev/null; then
    flutter --version 2>&1 | head -3
else
    echo "  Flutter not found. Set FLUTTER_HOME."
fi
echo ""
echo "Gradle wrapper:"
if command -v gradle &>/dev/null; then
    gradle --version 2>&1 | head -1
else
    echo "  (system gradle not installed, using project-local gradlew)"
fi
echo ""
echo "=== Environment Summary ==="
echo "Copy the values above into SKILL.md Environment table placeholders:"
echo "  <SDK_PATH> = $SDK"
echo "  <JDK_VERSION> = $(java -version 2>&1 | head -1 | sed 's/java version "//;s/".*//')"
echo "  <FLUTTER_VER> = $(flutter --version 2>&1 | head -3 | grep 'Flutter ' | cut -d' ' -f2 || echo 'not installed')"
echo "  <DART_VER> = $(flutter --version 2>&1 | grep 'Dart ' | cut -d' ' -f2 || echo 'bundled with Flutter')"

