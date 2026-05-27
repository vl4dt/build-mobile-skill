# SwiftUI, iOS/macOS & Remote Mac Reference

## SwiftUI Fundamentals

### Basic View

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Hello, World!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Welcome to your app")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Get Started") {
                // Action
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

### State Management

```swift
// @State — local view state
struct CounterView: View {
    @State private var count = 0
    var body: some View {
        VStack {
            Text("\(count)")
            Button("Increment") { count += 1 }
        }
    }
}

// @Binding — shared state between views
struct ChildView: View {
    @Binding var value: String
    var body: some View {
        TextField("Enter", text: $value)
    }
}

// @Observable — modern approach (iOS 17+)
@Observable
class CounterModel {
    var count = 0
    func increment() { count += 1 }
}

struct ModernCounterView: View {
    @Observable private var model = CounterModel()
    var body: some View {
        VStack {
            Text("\(model.count)")
            Button("Increment") { model.increment() }
        }
    }
}

// @EnvironmentObject — app-wide shared state
struct EnvironmentView: View {
    @EnvironmentObject var theme: ThemeManager
    var body: some View {
        Color(theme.primary)
    }
}
```

### View Lifecycle

```swift
struct LifecycleView: View {
    var body: some View {
        Text("Hello")
            .onAppear { print("View appeared") }
            .onDisappear { print("View disappeared") }
            .task { /* Async work on view appear */ }
            .onChange(of: someValue) { newValue in
                print("Changed to: \(newValue)")
            }
    }
}
```

### Modifiers (order matters!)

```swift
// Apply from outside-in (outermost first)
Text("Styled")
    .font(.title)
    .fontWeight(.bold)
    .foregroundColor(.blue)
    .padding()
    .background(Color.yellow)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(radius: 5)
```

## Architecture: MVVM with Observable

### Model

```swift
struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
}
```

### ViewModel

```swift
@Observable
class AuthViewModel {
    var user: User?
    var isLoading = false
    var error: String?
    private let api: ApiClient
    
    init(api: ApiClient = ApiClient()) {
        self.api = api
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        error = nil
        do {
            user = try await api.login(email: email, password: password)
        } catch {
            error = error.localizedDescription
        }
        isLoading = false
    }
    
    func logout() {
        user = nil
    }
}
```

### View

```swift
struct LoginView: View {
    @Observable private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    var email, password = ""
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            SecureField("Password", text: $password)
            
            if viewModel.isLoading {
                ProgressView()
            }
            
            if let error = viewModel.error {
                Text(error).foregroundColor(.red)
            }
            
            Button("Login") {
                Task { await viewModel.login(email: email, password: password) }
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}
```

## Navigation

### NavigationStack (iOS 16+)

```swift
struct NavigationDemo: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Settings", destination: SettingsView())
                NavigationLink("Profile", destination: ProfileView())
            }
            .navigationTitle("Menu")
        }
    }
}
```

### Programmatic Navigation

```swift
@Observable
class NavigationModel {
    @ObservationIgnored var navPath = NavigationPath()
    var selectedTab: Int = 0
}

struct ContentView: View {
    @Observable private var model = NavigationModel()
    
    var body: some View {
        TabView(selection: $model.selectedTab) {
            NavigationStack(path: $model.navPath) {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house") }
            .tag(0)
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(1)
        }
    }
}
```

### Sheets & Modals

```swift
struct SheetDemo: View {
    @State private var showSheet = false
    
    var body: some View {
        Button("Open") { showSheet = true }
            .sheet(isPresented: $showSheet) {
                SheetContent()
                    .presentationDetents([.medium, .large])
            }
    }
}
```

### Deep Links / Navigation Path

```swift
@Observable
class AppRouter {
    @ObservationIgnored var path = NavigationPath()
    func navigate(to route: AppRoute) { path.append(route) }
    func pop() { path.removeLast() }
}

enum AppRoute: Hashable {
    case home, profile, settings, detail(String)
}
```

## Swift Concurrency

```swift
@MainActor
class ViewModel: ObservableObject {
    func fetchData() async throws -> Data {
        try await withTaskCancellationHandler {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1s
            return Data()
        } onCancel: {
            Task.current.isCancelled = true
        }
    }
}

// Run async work in view
struct AsyncView: View {
    var body: some View {
        AsyncImage(url: URL(string: "https://example.com/img.jpg")) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
    }
}
```

## Remote Mac Setup (User-Configured)

### SSH Connection

```bash
# Connect to your remote Mac
ssh <REMOTE_USER>@<REMOTE_HOST>

# Example with key-based auth
ssh -i ~/.ssh/id_ed25519 -p 22 <REMOTE_USER>@<REMOTE_HOST>
```

### Run Commands Non-Interactively

macOS uses zsh. Non-interactive SSH sessions don't load `.zprofile` or `.zshrc`:

```bash
# Check Flutter version
ssh <REMOTE_USER>@<REMOTE_HOST> 'zsh -l -c "flutter --version"'

# List simulators
ssh <REMOTE_USER>@<REMOTE_HOST> 'zsh -l -c "xcrun simctl list devices"'

# Run Flutter build
ssh <REMOTE_USER>@<REMOTE_HOST> 'zsh -l -c "cd /path/to/app && flutter build ipa --release --no-codesign"'
```

### Sync Code to Mac

```bash
# rsync (set up SSH keys first)
rsync -avz --exclude=.git --exclude=build/ . <REMOTE_USER>@<REMOTE_HOST>:/path/to/app/

# Or use git: push from local, pull on Mac
ssh <REMOTE_USER>@<REMOTE_HOST> 'zsh -l -c "cd /path/to/app && git pull"'
```

## Xcode CLI Commands

```bash
ssh <REMOTE_USER>@<REMOTE_HOST>

# List all simulators
xcrun simctl list devices

# Launch simulator
xcrun simctl boot "iPhone 16 Pro Max"

# Clear all simulators
xcrun simctl shutdown all && xcrun simctl erase all

# Install IPA
xcrun simctl install booted /path/to/app.ipa

# Get simulator logs
log stream --process simulator --predicate 'eventMessage contains "error"' --level debug

# Create custom simulator
xcrun simctl create "My iPhone" com.apple.CoreSimulator.SimDeviceType.iPhone-16-Pro-Max ios17.0

# Screenshot
xcrun simctl io booted screenshot /path/to/screenshot.png
```

### Xcode Build Commands

```bash
# Clean build
xcodebuild clean -workspace ios/Runner.xcworkspace -scheme Runner

# Build for simulator
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Debug -sdk iphonesimulator -arch x86_64 build

# Build for device
xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Release -sdk iphoneos -arch arm64 build

# Archive for App Store
xcodebuild archive -workspace ios/Runner.xcworkspace \
  -scheme Runner -configuration Release \
  -archive-path build/Runner.xcarchive

# Export IPA
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build/ios/ipa \
  -exportOptionsPlist exportOptions.plist
```

## iOS 26+ Features

- **SwiftUI Improvements:** Enhanced canvas rendering, new layout protocols
- **iOS 26 Simulator:** Available on macOS 26+ via Xcode 26+
- **New UIKit Integrations:** Improved SwiftUI-UIKit bridge
- **WidgetKit:** Enhanced live activity support
- **App Intents:** Richer widget and shortcut integrations

```swift
// Example: iOS 26-compatible view
@available(iOS 26.0, *)
struct ModernView: View {
    var body: some View {
        ContentUnavailableView(
            "No Content",
            systemImage: "tray",
            description: Text("There is nothing to show here.")
        )
    }
}
```

## App Store Provisioning

### One-time Setup on Mac

```bash
# List available certificates
security find-identity -v -p codesigning

# List provisioning profiles
ls ~/Library/MobileDevice/Provisioning\ Profiles/

# For development:
# Xcode → Preferences → Accounts → Apple ID → Manage Certificates
# Create "Apple Development" certificate
```

### exportOptions.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <!-- or "apple-developer", "enterprise", "development", "ad-hoc" -->
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>none</string>
</dict>
</plist>
```

## CI/CD: GitHub Actions for iOS

```yaml
name: iOS Build
on:
  push:
    tags: ['v*']
jobs:
  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.0'
      - run: flutter pub get
      - run: flutter build ipa --release --no-codesign
      - uses: actions/upload-artifact@v4
        with:
          name: ios-app
          path: build/ios/ipa/*.ipa
```

## Common iOS Issues & Fixes

| Issue | Fix |
|---|---|
| "Signing is required" | Xcode → Runner → Signing → "Automatically manage signing" |
| "No signing certificate" | Xcode → Accounts → Add Apple ID → create Development certificate |
| "Could not find compatible Application Host" | `sudo xcode-select -switch /Applications/Xcode.app` |
| "Build failed" | `cd ios && pod deintegrate && pod install` |
| "Simulator not found" | `xcrun simctl list devices`, boot: `xcrun simctl boot "iPhone 15"` |
| "Code signing error" | `security find-identity -v -p codesigning` |
| "Pod install fails" | `sudo gem install ffi` then `cd ios && pod install --repo-update` |
| "Architectures mismatch" | Simulator: `x86_64`. Device: `arm64`. Use `--simulator` flag. |
