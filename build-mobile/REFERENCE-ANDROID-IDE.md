# Android Studio & IDE Troubleshooting Reference

> **Critical:** This reference covers Android Studio, IDE cache management, and build-toolchain incompatibilities that are NOT covered by general Flutter or Gradle references.

---

## 🔴 Golden Rules for IDE Issues

1. **ALWAYS verify command-line builds first** — if `flutter build apk --debug` and `./gradlew assembleDebug` succeed, the issue is 100% in the IDE layer.
2. **ALWAYS delete `.idea/` before reopening** — Android Studio caches project type classification and will ignore regenerated `.idea` files until caches are fully cleared.
3. **ALWAYS close Android Studio completely** (not just close the window) — `File > Exit` or `Ctrl+Q` / `Cmd+Q`. Task Manager may be needed on Windows.
4. **ALWAYS list routes in declaration order** in `go_router` — literal routes must appear before wildcard (`:id`) routes. GoRouter matches top-to-bottom.

---

## 🐛 Issue: "The SDK is not specified for modules"

### Symptom
Android Studio shows error: `The SDK is not specified for modules <project>_android, <project>`. The Project Structure dialog prompts for SDK selection. The IDE treats the Flutter project as a plain Android/Kotlin project.

### Root Cause
The `.idea/libraries/Flutter_Plugins.xml` file is missing. This file tells Android Studio "this is a Flutter project" by defining a library with `type="FlutterPluginsLibraryType"`. Without it, Android Studio falls back to treating the project as plain Java/Android.

### Why It Happens
- Initial project open with a corrupted or missing `.idea/` directory
- Project was opened from the `android/` subfolder instead of the project root
- IDE cached a "non-Flutter/Java project" classification from a previous open
- `flutter create .` regenerates some `.idea` files but NOT `Flutter_Plugins.xml` (that's only created by Android Studio's Flutter plugin during a proper project sync)

### Fix — Fresh Reopen (Preferred)

```bash
# 1. Completely quit Android Studio
# 2. Delete the .idea directory
rm -rf <project_root>/.idea

# 3. Regenerate minimal .idea files
cd <project_root>
flutter create .
flutter pub get

# 4. Manually create Flutter_Plugins.xml (bootstraps Flutter project recognition)
mkdir -p .idea/libraries
cat > .idea/libraries/Flutter_Plugins.xml << 'EOF'
<component name="libraryTable">
  <library name="Flutter Plugins" type="FlutterPluginsLibraryType">
    <CLASSES>
      <root url="file://<pub_cache_dir>" />
    </CLASSES>
    <JAVADOC />
    <SOURCES />
  </library>
</component>
EOF

# 5. Launch Android Studio fresh — do NOT use "Open Recent"
#    Use File > Open → navigate to project root
```

### Fix — Invalidate Caches (If Fresh Reopen Fails)

```
Android Studio: File > Invalidate Caches > Invalidate and Restart
Then: File > Open → <project_root>
```

### Fix — Manual `.idea` Reconstruction

If automatic regeneration doesn't work, manually create ALL required `.idea` files:

#### `.idea/modules.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectModuleManager">
    <modules>
      <module fileurl="file://$PROJECT_DIR$/<project>.iml" filepath="$PROJECT_DIR$/<project>.iml" />
      <module fileurl="file://$PROJECT_DIR$/android/<project>_android.iml" filepath="$PROJECT_DIR$/android/<project>_android.iml" />
    </modules>
  </component>
</project>
```

#### `.idea/misc.xml`
```xml
<project version="4">
  <component name="ProjectRootManager" version="2" languageLevel="JDK_17" default="true" project-jdk-name="jbr-17" project-jdk-type="JavaSDK">
    <output url="file://$PROJECT_DIR$/out" />
  </component>
</project>
```

#### `.idea/vcs.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="VcsDirectoryMappings">
    <mapping directory="$PROJECT_DIR$" vcs="Git" />
  </component>
</project>
```

#### `.idea/libraries/Flutter_Plugins.xml`
```xml
<component name="libraryTable">
  <library name="Flutter Plugins" type="FlutterPluginsLibraryType">
    <CLASSES>
      <root url="file://C:/Users/<USER>/AppData/Local/Pub/Cache/hosted/pub.dev/device_info_plus-<VER>" />
      <root url="file://C:/Users/<USER>/AppData/Local/Pub/Cache/hosted/pub.dev/image_picker_android-<VER>" />
      <root url="file://C:/Users/<USER>/AppData/Local/Pub/Cache/hosted/pub.dev/workmanager-<VER>" />
      <!-- Add all Kotlin-requiring plugins -->
    </CLASSES>
    <JAVADOC />
    <SOURCES />
  </library>
</component>
```

> **Note:** Android Studio will overwrite this with correct plugin paths after a proper project sync. This is just a bootstrap file.

#### `.idea/libraries/Dart_SDK.xml`
```xml
<component name="libraryTable">
  <library name="Dart SDK">
    <CLASSES>
      <root url="file://<flutter_sdk>/bin/cache/dart-sdk/lib/async" />
      <root url="file://<flutter_sdk>/bin/cache/dart-sdk/lib/collection" />
      <root url="file://<flutter_sdk>/bin/cache/dart-sdk/lib/convert" />
      <root url="file://<flutter_sdk>/bin/cache/dart-sdk/lib/core" />
      <root url="file://<flutter_sdk>/bin/cache/dart-sdk/lib/developer" />
      <root url="file://<flutter_sdk>/bin/cache/dart-sdk/lib/io" />
      <root url="file://<flutter_sdk>/bin/cache/dart-sdk/lib/isolate" />
      <root url="file://<flutter_sdk>/bin/cache/dart-sdk/lib/math" />
      <root url="file://<flutter_sdk>/bin/cache/dart-sdk/lib/typed_data" />
    </CLASSES>
    <JAVADOC />
    <SOURCES />
  </library>
</component>
```

#### `.idea/libraries/Dart_Packages.xml`
```xml
<component name="libraryTable">
  <library name="Dart Packages" type="DartPackagesLibraryType">
    <CLASSES />
    <JAVADOC />
    <SOURCES />
  </library>
</component>
```

#### `.idea/runConfigurations/main_dart.xml`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<component name="ProjectRunConfigurationManager">
  <configuration default="false" name="main.dart" type="FlutterRunConfigurationType" factoryName="Flutter">
    <option name="filePath" value="$PROJECT_DIR$/lib/main.dart" />
    <method />
  </configuration>
</component>
```

### Verification Checklist

| Check | Command | Expected |
|---|---|---|
| Flutter project recognized | `flutter doctor -v` | No Android SDK errors |
| Dart SDK path valid | `which dart` | Points to Flutter's bundled Dart |
| .iml files exist | `ls *.iml` | `<project>.iml` and `android/<project>_android.iml` |
| local.properties valid | `cat android/local.properties` | Has `sdk.dir` and `flutter.sdk` |
| Command-line build | `flutter build apk --debug` | Succeeds |
| Gradle build | `./gradlew assembleDebug` | Succeeds |

### Windows-Specific Notes

- **Scoop Flutter SDK:** `flutter.sdk=C:\Users\<USER>\scoop\apps\flutter\<VER>`
- **Chocolatey Flutter SDK:** `flutter.sdk=C:\Program Files\Flutter\bin\..\cache`
- **SDK path:** `sdk.dir=C:\Users\<USER>\AppData\Local\Android\Sdk`
- **Line endings:** Windows uses CRLF. Git may auto-convert `.idea` XML files. If Android Studio rejects configs, check line endings with `file .idea/*.xml`.

---

## 🐛 Issue: Kotlin Incremental Cache Corruption (Windows)

### Symptom
```
e: Daemon compilation failed
java.lang.Exception
Caused by: java.lang.AssertionError: java.lang.Exception: Could not close incremental caches
...
java.lang.IllegalStateException: Storage for [.../class-fq-name-to-source.tab] is already registered
```

Affects multiple plugins (device_info_plus, image_picker_android, workmanager, etc.). Build fails with `BUILD FAILED in <time>`.

### Root Cause
The Kotlin daemon's incremental compilation caches on Windows use memory-mapped files. When:
- The daemon crashes mid-compilation
- A build is interrupted
- Multiple Gradle processes compete for the same cache
- Windows file locks interfere with cache file handles

...the `.tab` cache files become corrupted and subsequent builds fail with "Storage already registered" errors. This is a **known Windows-specific issue** with Kotlin's incremental compilation.

### Fix — Disable Kotlin Incremental Compilation (Recommended for Windows)

Add to `android/gradle.properties`:

```properties
# Disable Kotlin incremental compilation to avoid cache corruption on Windows
kotlin.incremental=false
```

### Fix — Manual Cache Clear (If Incremental Is Required)

```bash
# 1. Stop all Gradle daemons
./gradlew --stop

# 2. Kill any running Kotlin daemon processes
# Windows:
taskkill /F /IM java.exe
# Or use Task Manager to kill java.exe processes

# 3. Delete all build directories
cd <project_root>
rm -rf build/ .dart_tool/
cd android && rm -rf build/ .gradle/ && cd ..

# 4. Delete global Kotlin caches
rm -rf ~/.gradle/caches/*/kotlin-dsl
rm -rf ~/.gradle/kotlin
rm -rf ~/.m2/repository/org/jetbrains/kotlin*

# 5. Fresh pub get and build
cd <project_root>
flutter pub get
flutter build apk --debug
```

### Prevention

- **For Windows projects:** Set `kotlin.incremental=false` in `android/gradle.properties` as a project default.
- **For cross-platform teams:** Document this as a known Windows-only workaround. The issue does NOT occur on macOS or Linux.
- **CI/CD:** Ensure clean builds in CI (no stale cache from previous runs).

---

## 🐛 Issue: GoRouter Route Matching Order

### Symptom
```
FormatException: Invalid radix-10 number (at character 1)
settings
^
#4 AppRouter.router.<anonymous closure> (package:app/shared/router/app_router.dart:70:37)
```

Navigating to `/pets/settings` crashes the app instead of showing the Settings screen.

### Root Cause
`go_router` matches routes **in declaration order** (first match wins). The `:id` wildcard route captures any path segment that isn't matched by a preceding literal route.

```dart
// WRONG — :id matches "settings" first
routes: [
  GoRoute(path: ':id', builder: (c, s) => PetDetailScreen(...)),
  GoRoute(path: 'settings', builder: (c, s) => SettingsScreen()),  // never reached
]

// CORRECT — literal routes before wildcards
routes: [
  GoRoute(path: 'settings', builder: (c, s) => SettingsScreen()),
  GoRoute(path: ':id', builder: (c, s) => PetDetailScreen(...)),
]
```

### Fix
Move all **literal** route paths BEFORE **wildcard** (`:name`) routes in the children list:

```dart
GoRoute(
  path: 'pets',
  name: 'pet-list',
  builder: (context, state) => const PetListScreen(),
  routes: [
    // ✅ Literal routes FIRST
    GoRoute(path: 'settings', name: 'settings', builder: ...),
    GoRoute(path: 'add', name: 'add-pet', builder: ...),
    // ✅ Wildcard route LAST
    GoRoute(path: ':id', name: 'pet-detail', builder: ...),
  ],
)
```

### Common Patterns

| Route | Type | Order |
|---|---|---|
| `settings` | literal | 1st |
| `add` | literal | 2nd |
| `:id` | wildcard | last |
| `:slug` | wildcard | last |
| `:action` | wildcard | last |

---

## 🐛 Issue: Project Type Stuck as "Non-Flutter"

### Symptom
Android Studio shows:
- No Flutter icon in the top-right
- `File > New` does not offer Flutter templates
- Project Structure dialog has no Flutter facet
- The project is treated as a plain Java/Kotlin project

### Root Cause
Android Studio caches the project type classification in its internal index. If a project was initially opened incorrectly (e.g., from the `android/` subfolder, or with a corrupted `.idea/`), the IDE remembers that classification and ignores regenerated `.idea` files.

### Fix — Complete Reset Procedure

```
1. Quit Android Studio completely (File > Exit)
2. Delete the .idea directory:
   rm -rf <project_root>/.idea
3. Launch Android Studio fresh
4. Use File > Open → navigate to project root (NOT File > Open Recent)
5. If error persists:
   a. File > Invalidate Caches > Invalidate and Restart
   b. After restart, File > Open → project root again
```

> **Critical:** Never use "Open Recent" after deleting `.idea/`. Android Studio's Recent Projects list contains a cached project type that overrides fresh detection.

---

## 🐛 Issue: `jdkName="Android API 24 Platform"` Error

### Symptom
`pawlyfe_android.iml` contains:
```xml
<option name="jdkName" jdkName="Android API 24 Platform" jdkType="Android SDK" />
```

But `Android API 24` is deprecated or missing from the installed Android SDK.

### Root Cause
This is auto-generated by `flutter create .` and uses the minimum SDK version from the project configuration. If the user has deleted older Android platform packages or never installed API 24, this causes IDE warnings.

### Fix

```bash
# Install the required Android platform
sdkmanager "platforms;android-24"

# OR update the project's minSdk to match installed platforms
# In android/app/build.gradle.kts:
defaultConfig {
    minSdk = 26  // or whatever your minimum supported API is
}
```

> **Note:** This error is cosmetic — it does NOT block command-line builds. The IDE will eventually update this during a project sync.

---

## 🐛 Issue: Gradle Version / JDK Mismatch

### Symptom
```
Could not create Java toolchain...
Could not find tools.jar
AGP 8.x requires JDK 17+
```

### Root Cause
The Gradle daemon or Android Studio's bundled JDK doesn't match the AGP requirements.

### Fix

```properties
# android/gradle.properties
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8 -Dorg.gradle.java.home=<JDK_17_PATH>
```

Or set `JAVA_HOME` and `ANDROID_JAVA_HOME` environment variables to point to JDK 17+.

---

## 🐛 Issue: `local.properties` Missing or Incorrect Paths

### Symptom
```
SDK location not found. Define a valid SDK location...
flutter: Command not found
```

### Root Cause
`android/local.properties` is missing, corrupted, or has incorrect paths.

### Fix

```properties
# android/local.properties
sdk.dir=C:\\Users\\<USER>\\AppData\\Local\\Android\\Sdk
flutter.sdk=C:\\Users\\<USER>\\scoop\\apps\\flutter\\3.44.0
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```

> **Note:** Paths use double backslashes (`\\`) in `.properties` files on Windows. Single backslash may not be parsed correctly.

---

## 🐛 Issue: Build Tool Version Mismatch

### Symptom
```
AGP 8.12+ requires Kotlin 2.1+
Kotlin compiler version 1.9.x is incompatible
```

### Root Cause
The Kotlin plugin version in the root `build.gradle.kts` doesn't match the AGP requirements.

### Compatibility Matrix

| AGP Version | Minimum Kotlin | Min Gradle | Min JDK |
|---|---|---|---|
| 7.4 | 1.6.10 | 7.5 | 8 |
| 8.0 | 1.7.10 | 8.0 | 8 |
| 8.1 | 1.7.20 | 8.0 | 8 |
| 8.2 | 1.8.20 | 8.2 | 11 |
| 8.3 | 1.8.22 | 8.4 | 11 |
| 8.5 | 1.9.20 | 8.4 | 17 |
| 8.6 | 1.9.22 | 8.6 | 17 |
| 8.12 | 2.0.20 | 8.11 | 17 |
| 8.13 | 2.1.0 | 8.14 | 17 |

> **ALWAYS verify compatibility before updating.** Check AGP changelog and Kotlin release notes.

---

## 📋 Quick Reference: IDE File Structure

A correctly configured Flutter project's `.idea/` directory should contain:

```
.idea/
├── libraries/
│   ├── Dart_SDK.xml           ← Dart SDK paths
│   ├── Dart_Packages.xml      ← Dart packages library
│   ├── Flutter_Plugins.xml    ← Flutter plugins (type=FlutterPluginsLibraryType)
│   └── KotlinJavaRuntime.xml  ← Kotlin standard library
├── runConfigurations/
│   └── main_dart.xml          ← Flutter run configuration
├── modules.xml                ← Module registration (pawlyfe.iml + pawlyfe_android.iml)
├── misc.xml                   ← JDK version, project settings
├── vcs.xml                    ← VCS mapping (Git)
├── workspace.xml              ← IDE workspace state
├── markdown.xml               ← Markdown editor settings
├── caches/
│   └── deviceStreaming.xml    ← Device streaming config
└── .gitignore                 ← Ignore IDE-generated files
```

> **Note:** The `.idea/` directory is typically in `.gitignore`. Regenerate it when moving between machines or after corruption.

---

## 🔧 Useful Commands

```bash
# Verify Flutter project is valid
flutter doctor -v
flutter analyze

# Clean build artifacts (keeps .idea/)
flutter clean
flutter pub get

# Regenerate IDE files from scratch
rm -rf .idea
flutter create .
flutter pub get

# Verify Gradle can build
cd android && ./gradlew clean && ./gradlew assembleDebug && cd ..

# Check Gradle versions
./gradlew --version

# List installed Android SDK platforms
sdkmanager --list | grep "platforms;"

# Kill all Java processes (Gradle + Kotlin daemon)
taskkill /F /IM java.exe    # Windows
pkill -9 java               # macOS/Linux
```
