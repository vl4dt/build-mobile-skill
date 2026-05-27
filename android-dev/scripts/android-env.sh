#!/bin/bash
# Android environment audit script
# Outputs current SDK state for SKILL.md updates

SDK="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
if [ -z "$SDK" ] || [ ! -d "$SDK" ]; then
    echo "ERROR: Android SDK not found"
    exit 1
fi

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
echo "Gradle wrapper:"
if command -v gradle &>/dev/null; then
    gradle --version 2>&1 | head -1
else
    echo "  (system gradle not installed, using project-local gradlew)"
fi
