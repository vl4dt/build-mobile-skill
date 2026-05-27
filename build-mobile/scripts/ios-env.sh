#!/bin/bash
# iOS/macOS environment audit script
# Outputs current Xcode & iOS toolchain state for SKILL.md updates
# Run this and copy the output into the iOS Environment table placeholders
# Example: XCODE_VER=<version from output>, SIMULATORS=<list from output>, etc.

set -e

echo "=== iOS/macOS Environment Audit ==="

# Xcode version
if command -v xcodebuild &>/dev/null; then
    XCODE_VER=$(xcodebuild -version 2>/dev/null | head -1)
    echo "Xcode: $XCODE_VER"
else
    echo "Xcode: NOT FOUND — install from App Store or developer.apple.com"
fi

# Command line tools
XCODE_CLT=$(xcode-select -p 2>/dev/null || echo "NOT SET")
echo "xcode-select: $XCODE_CLT"

# Swift version
if command -v swift &>/dev/null; then
    SWIFT_VER=$(swift --version 2>/dev/null | head -1)
    echo "Swift: $SWIFT_VER"
else
    echo "Swift: NOT FOUND"
fi

# macOS SDK
MACOS_SDK=$(xcrun --sdk macosx --show-sdk-version 2>/dev/null || echo "NOT FOUND")
echo "macOS SDK: $MACOS_SDK"

# iOS SDK
IOS_SDK=$(xcrun --sdk iphoneos --show-sdk-version 2>/dev/null || echo "NOT FOUND")
echo "iOS SDK: $IOS_SDK"

# Simulator devices
echo ""
echo "Simulators (booted first):"
xcrun simctl list devices 2>/dev/null | while IFS= read -r line; do
    if echo "$line" | grep -q "iOS\|tvOS\|watchOS"; then
        echo "  $line"
    fi
done

# Available runtimes
echo ""
echo "Runtimes:"
xcrun simctl list runtimes 2>/dev/null | while IFS= read -r line; do
    if echo "$line" | grep -q "iOS\|tvOS"; then
        echo "  $line"
    fi
done

# CocoaPods
if command -v pod &>/dev/null; then
    POD_VER=$(pod --version 2>/dev/null)
    POD_REPO=$(cd ~/Documents 2>/dev/null && pod repo list 2>/dev/null | head -5 || echo "N/A")
    echo "CocoaPods: $POD_VER"
    echo "  Repo: $POD_REPO"
else
    echo "CocoaPods: NOT FOUND — install: sudo gem install cocoapods"
fi

# Homebrew (optional but recommended)
if command -v brew &>/dev/null; then
    BREW_VER=$(brew --version 2>/dev/null | head -1)
    echo "Homebrew: $BREW_VER"
else
    echo "Homebrew: NOT FOUND — recommended for macOS dev tooling"
fi

# Provisioning profiles
echo ""
echo "Provisioning Profiles:"
PROFILE_DIR="$HOME/Library/MobileDevice/Provisioning Profiles"
if [ -d "$PROFILE_DIR" ]; then
    ls "$PROFILE_DIR"/*.mobileprovision 2>/dev/null | while IFS= read -r p; do
        profile_name=$(security cms -D -i "$p" 2>/dev/null | grep -A1 '<key>Name</key>' | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/' || echo "unknown")
        echo "  $profile_name"
    done
else
    echo "  No provisioning profiles found at $PROFILE_DIR"
fi

# Certificates
echo ""
echo "Code Signing Certificates:"
security find-identity -v -p codesigning 2>/dev/null | while IFS= read -r line; do
    echo "  $line"
done

# Keychain (Apple ID / API keys)
echo ""
echo "Keychain (API keys / signing identities):"
security find-generic-password -s "Altool API Key" 2>/dev/null && echo "  API key found" || echo "  No API key found in keychain"

# Xcode projects workspace (optional)
echo ""
echo "Workspace check (if Xcode project exists):"
if [ -d "ios" ] && [ -f "ios/Podfile" ]; then
    echo "  Podfile: FOUND"
    if [ -d "ios/Pods" ]; then
        echo "  Pods: INSTALLED"
    else
        echo "  Pods: NOT INSTALLED — run 'cd ios && pod install'"
    fi
else
    echo "  No ios/ directory or Podfile found. Run from project root."
fi

# Flutter iOS check (optional)
echo ""
if command -v flutter &>/dev/null; then
    echo "Flutter iOS support:"
    flutter config 2>/dev/null | grep -i "enable-ios\|enable-macos\|enable-web" || echo "  (flutter config not available)"
    echo "  Flutter: $(flutter --version 2>&1 | head -1)"
else
    echo "Flutter: NOT INSTALLED"
fi

# CocoaPods repo update check
echo ""
echo "Last pod repo update: $(stat -f '%Sm' ~/Documents/CocoaPods/Pods/Manifest.lock 2>/dev/null || echo 'N/A')"

# In-app purchases / StoreKit (optional)
echo ""
echo "StoreKit (for In-App Purchase development):"
if command -v xcrun &>/dev/null; then
    # Check if StoreKit types are available
    STOREKIT_VER=$(xcrun --show-sdk-path 2>/dev/null | grep -o "iOS.*" || echo "N/A")
    echo "  StoreKit SDK path: $STOREKIT_VER"
else
    echo "  xcrun not available"
fi

echo ""
echo "=== Environment Summary ==="
echo "Copy the values above into SKILL.md iOS Environment table placeholders:"
echo "  <XCODE_VER> = $(xcodebuild -version 2>/dev/null | head -1 || echo 'not installed')"
echo "  <SWIFT_VER> = $(swift --version 2>/dev/null | head -1 | cut -d' ' -f2 || echo 'not installed')"
echo "  <IOS_SDK_VER> = $(xcrun --sdk iphoneos --show-sdk-version 2>/dev/null || echo 'not found')"
echo "  <POD_VER> = $(pod --version 2>/dev/null || echo 'not installed')"
