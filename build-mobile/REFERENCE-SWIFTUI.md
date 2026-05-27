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

            Button("Get Started") { /* action */ }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
```

### State Management

```swift
// @State — local view state (owned by the view)
struct CounterView: View {
    @State private var count = 0
    var body: some View {
        VStack {
            Text("\(count)")
            Button("Increment") { count += 1 }
        }
    }
}

// @Binding — shared state between views (parent passes $childValue)
struct ParentView: View {
    @State private var text = ""
    var body: some View {
        TextField("Enter", text: $text)
        ChildView(selected: $text)
    }
}
struct ChildView: View {
    @Binding var selected: String
    var body: some View { Text(selected) }
}

// @Observable — modern approach (iOS 17+), replaces ObservableObject
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

// @Published + Combine — reactive property wrappers (iOS 13+)
class SettingsModel: ObservableObject {
    @Published var theme: Theme = .system
    @Published var fontSize: CGFloat = 16
    func toggleTheme() { theme = theme == .light ? .dark : .light }
}

// @EnvironmentObject — app-wide shared state (injected via .environmentObject)
struct EnvironmentView: View {
    @EnvironmentObject var theme: ThemeManager
    var body: some View { Color(theme.primary) }
}
```

### View Lifecycle

```swift
struct LifecycleView: View {
    var body: some View {
        Text("Hello")
            .onAppear { /* view appears on screen */ }
            .onDisappear { /* view disappears */ }
            .task { /* async work on appear, auto-cancelled */ }
            .onChange(of: someValue) { newValue in
                /* react to value change */
            }
            .task(id: someID) { /* re-runs when someID changes */ }
    }
}
```

### Layout Primitives

```swift
// VStack / HStack / ZStack — the three fundamental stacks
VStack(alignment: .leading, spacing: 12) {
    Text("Title")
    Text("Subtitle")
}

HStack(spacing: 8) {
    Image(systemName: "star")
    Text("Favorites")
}

ZStack {
    Color.blue.ignoresSafeArea()  // background
    Text("Overlay")                 // foreground
}

// LazyVStack / LazyHStack — efficient for large data
LazyVStack(spacing: 8) {
    ForEach(items) { item in
        ItemView(item: item)
    }
}

// GeometryReader — access parent size and position
GeometryReader { geo in
    Rectangle()
        .frame(width: geo.size.width * 0.5)  // half of parent
        .position(x: geo.size.width / 2, y: geo.size.height / 2)
}
```

### Custom ViewModifiers

```swift
// Define a custom modifier
struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var shadowRadius: CGFloat = 8
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.1), radius: shadowRadius)
    }
}
// Usage
extension View {
    func card() -> some View {
        modifier(CardModifier())
    }
}
Text("Hello").card()

// Parameterized modifier
struct TextFieldStyleModifier: ViewModifier {
    let placeholder: String
    let icon: String
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(alignment: .leading) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }
            .padding(.horizontal)
    }
}
extension TextField {
    func searchField() -> some TextField {
        modifier(TextFieldStyleModifier(placeholder: "Search", icon: "magnifyingglass"))
    }
}
```

## App Lifecycle & Entry Points

### @main App Entry

```swift
@main
struct MyApp: App {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var theme = ThemeManager()

    var body: some Scene {
        // WindowGroup for standard app windows
        WindowGroup {
            RootView()
                .environmentObject(authVM)
                .environmentObject(theme)
        }

        // Menu bar for macOS
        MenuBarExtra("My App", systemImage: "app.dashed") {
            MenuBarView()
        }

        // Window for multiple document support (macOS)
        WindowGroup(for: Document.self) { document in
            DocumentView(document: document.wrappedValue)
        }

        // Settings scene
        Settings {
            SettingsView()
        }
    }
}
```

### macOS Scene Types

```swift
// Standard window
WindowGroup {
    ContentView()
}

// Document-based app
WindowGroup(for: MyDocument.ID.self) { id in
    if let doc = documentStore.documents[id] {
        DocumentView(document: doc)
    }
}

// Sidebar + detail layout
WindowGroup {
    SplitView {
        SidebarView()
        DetailView()
    }
    .frame(minWidth: 800, minHeight: 600)
}
```

### iOS App Delegates (Legacy / UIKit Integration)

```swift
// For handling background/foreground, deep links, etc.
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ app: UIApplication,
                     open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Handle universal links / custom URL schemes
        return true
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save state
    }
}
```

## Navigation Deep Dive

### NavigationStack with Path

```swift
@Observable
class AppRouter {
    @ObservationIgnored var path = NavigationPath()
    func push(_ route: Route) { path.append(route) }
    func pop() { path.removeLast() }
    func popToRoot() { path.removeLast(path.count) }
}

enum Route: Hashable {
    case home
    case list(id: String)
    case detail(id: String)
    case settings
}

struct AppView: View {
    @Observable private var router = AppRouter()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .home: HomeView()
                    case .list(let id): ListView(id: id)
                    case .detail(let id): DetailView(id: id)
                    case .settings: SettingsView()
                    }
                }
        }
    }
}
```

### TabView with Navigation

```swift
struct TabbedApp: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack { HomeView() }
                .tabItem { Label("Home", systemImage: "house") }
                .tag(0)

            NavigationStack { SearchView() }
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(1)

            NavigationStack { ProfileView() }
                .tabItem { Label("Profile", systemImage: "person") }
                .tag(2)
        }
    }
}
```

### Sheet, FullScreenCover, Alert, ConfirmationDialog

```swift
struct PopupsDemo: View {
    @State private var showSheet = false
    @State private var showFullScreen = false
    @State private var showAlert = false
    @State private var showConfirm = false
    @State private var selectedOption: Int?

    var body: some View {
        VStack(spacing: 12) {
            Button("Sheet") { showSheet = true }
                .sheet(isPresented: $showSheet) {
                    SheetView()
                        .presentationDetents([.medium, .large])
                        .presentationCornerRadius(20)
                }

            Button("Full Screen") { showFullScreen = true }
                .fullScreenCover(isPresented: $showFullScreen) {
                    FullScreenView()
                }

            Button("Alert") { showAlert = true }
                .alert("Error", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                    Button("Retry", role: .destructive) { /* retry */ }
                } message: {
                    Text("Something went wrong")
                }

            Button("Confirmation") { showConfirm = true }
                .confirmationDialog("Delete Item", isPresented: $showConfirm,
                    titleVisibility: .visible) {
                    Button("Delete", role: .destructive) { /* delete */ }
                    Button("Move to Trash") { /* trash */ }
                } message: {
                    Text("This action cannot be undone")
                }
        }
    }
}
```

### Form, TextField, DatePicker, Picker

```swift
struct SettingsForm: View {
    @State private var name = ""
    @State private var email = ""
    @State private var age = 25
    @State private var theme = "System"
    @State private var date = Date()
    @State private var notifications = true

    var body: some View {
        Form {
            Section("Profile") {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.never)
                TextField("Age", value: $age, format: .number)
            }

            Section("Preferences") {
                Picker("Theme", selection: $theme) {
                    Text("System").tag("System")
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                }
                DatePicker("Birthday", selection: $date, displayedComponents: .date)
                Toggle("Notifications", isOn: $notifications)
            }
        }
    }
}
```

## Animations

### Implicit Animation

```swift
struct AnimatedView: View {
    @State private var size = CGSize(width: 100, height: 100)

    var body: some View {
        Circle()
            .frame(width: size.width, height: size.height)
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    size = CGSize(width: 200, height: 200)
                }
            }
    }
}
```

### Animation Modifiers

```swift
// Animate on change
Text("Hello")
    .transition(.move(edge: .leading))
    .animation(.easeInOut(duration: 0.3), value: visibility)

// Spring animation
Button("Bounce") { /* action */ }
    .scaleEffect(isPressed ? 0.95 : 1.0)
    .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isPressed)

// Staggered animations
ForEach(items.indices) { i in
    ItemView(item: items[i])
        .transition(.move(edge: .bottom))
        .animation(.easeOut.delay(Double(i) * 0.05), value: items)
}

// Keyframe animation for complex choreography
withAnimation(.keyframeAnimator(
    initialValue: .zero,
    keyframes: { currentValue in
        KeyframeCurve(.easeIn) { currentValue }
        KeyframeCurve(.easeOut) { currentValue }
    }
)) {
    view.transform = /* final state */
}

// Timeline animation
struct TimelineDemo: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1)) { timeline in
            Text(timeline.date, format: .dateTime.hour().minute().second())
        }
    }
}
```

## @Published + Combine Integration

```swift
class UserStore: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var error: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        $users
            .dropFirst()
            .sink { users in
                // react to user list changes
            }
            .store(in: &cancellables)
    }

    func fetchUsers() {
        isLoading = true
        Task {
            do {
                users = try await api.getUsers()
            } catch {
                error = error.localizedDescription
            }
            isLoading = false
        }
    }
}

// SwiftUI + Combine: bridging
let publisher = NotificationCenter.default.publisher(
    for: UIApplication.didBecomeActiveNotification
)
.publisher
.map { _ in Date() }
.assign(to: &$lastActive)
```

## Charts & Maps

### Charts (ios16+)

```swift
import Charts

struct ChartDemo: View {
    let data = [
        ChartData(x: "Jan", y: 30),
        ChartData(x: "Feb", y: 45),
        ChartData(x: "Mar", y: 60),
        ChartData(x: "Apr", y: 50),
        ChartData(x: "May", y: 75),
        ChartData(x: "Jun", y: 90),
    ]

    var body: some View {
        Chart(data) { item in
            LineXAxisMark(x: .value("Month", item.x))
            LineYAxisMark(y: .value("Score", item.y))
            LineMark(
                x: .value("Month", item.x),
                y: .value("Score", item.y)
            )
            .foregroundStyle(.blue)
        }
        .chartXAxisLabel("Month")
        .chartYAxisLabel("Score")
        .frame(height: 300)
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    let x: String
    let y: Int
}

// Bar chart
BarMark(
    position: .value("Category", item.category),
    value: .value("Value", item.value)
)

// Area chart
AreaMark(
    x: .value("X", x),
    yStart: .value("Y1", y1),
    yEnd: .value("Y2", y2)
)
```

### MapKit Integration

```swift
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D
    @Binding var region: MKCoordinateRegion

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.setUserTrackingMode(.follow, animated: true)
        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.setRegion(region, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapView
        init(_ parent: MapView) { self.parent = parent }
        func mapView(_ mapView: MKMapView,
                     annotationView view: MKAnnotationView,
                     calloutAccessoryControlTapped control: UIControl) {
            // handle callout tap
        }
    }
}

// SwiftUI Map (iOS 16+)
import Maps

struct SimpleMap: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true) {
            Marker("San Francisco", coordinate:
                CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
            )
        }
        .frame(height: 300)
    }
}
```

## SwiftUI Testing

### XCTest + ViewTesting

```swift
import XCTest
import SwiftUI
import XCTestExtensions  // or use built-in ViewTesting (iOS 17+)

final class LoginViewTests: XCTestCase {

    func testLoginButtonIsDisabledWhenEmpty() {
        let view = LoginView()
        // Verify button is disabled with empty fields
        XCTAssertTrue(true) // assertion on view state
    }

    func testLoginButtonShowsLoading() {
        let viewModel = AuthViewModel()
        let view = LoginView(viewModel: viewModel)

        viewModel.isLoading = true
        // Check for ProgressView in view hierarchy
        XCTAssertTrue(true)
    }

    func testNavigationOnSuccess() {
        let viewModel = AuthViewModel()
        let view = LoginView(viewModel: viewModel)
        viewModel.user = User(id: "1", name: "Test")

        // Verify navigation state changed
        XCTAssertTrue(true)
    }
}
```

### UI Testing (XCUITest)

```swift
import XCTest

final class LoginUITests: XCTestCase {

    func testLoginFlow() {
        let app = XCUIApplication()
        app.launch()

        // Fill in credentials
        let emailField = app.textFields["Email"]
        emailField.typeText("user@example.com")
        let passwordField = app.secureTextFields["Password"]
        passwordField.typeText("password123")

        // Tap login
        app.buttons["Login"].tap()

        // Verify navigation
        XCTAssertTrue(app.staticTexts["Home"].exists)
    }
}
```

## Charts Deep Dive

```swift
import Charts

// Multi-series line chart
struct MultiSeriesChart: View {
    let data = [
        Series(name: "Revenue", points: [Point(day: 1, value: 100), Point(day: 2, value: 150)]),
        Series(name: "Expenses", points: [Point(day: 1, value: 80), Point(day: 2, value: 120)]),
    ]

    var body: some View {
        Chart(data) { series in
            LineMark(
                x: .value("Day", $0.day),
                y: .value("Amount", $0.value)
            )
            .foregroundStyle(by: .value("Series", series.name))
            .lineStyle(StrokeStyle(lineWidth: 3))
        }
        .chartLegend(.hidden)
        .chartXAxisLabel("Day")
        .chartYAxisLabel("Amount")
    }
}

struct Series: Identifiable {
    let id = UUID()
    let name: String
    let points: [Point]
}
struct Point: Identifiable {
    let id = UUID()
    let day: Int
    let value: Double
}
```

## Maps Deep Dive

```swift
// Using Map (SwiftUI Maps - iOS 16+)
struct DetailedMap: View {
    @State private var selectedPin: CLLocationCoordinate2D?

    var body: some View {
        Map(initialPosition: .automatic) {
            Marker("Office", coordinate: officeLocation)
                .symbolVariant(.fill)
                .tag(officeLocation)

            Marker("Branch", coordinate: branchLocation)
                .symbolVariant(.circle.fill)
                .tag(branchLocation)

            ForEach(pins) { pin in
                Marker(pin.title, coordinate: pin.coordinate)
                    .tag(pin.coordinate)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .onMapCameraChange { value in
            // react to camera changes
        }
    }
}

// MKMapItem for directions
func openDirections(to coordinate: CLLocationCoordinate2D) {
    let placemark = MKPlacemark(coordinate: coordinate)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = "Destination"
    MKMapItem.openMaps(with: [mapItem])
}
```

## Accessibility

```swift
struct AccessibleView: View {
    var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .accessibilityLabel("Starred")
                .accessibilityAddTraits(.isSelected)

            Button("Save") { /* action */ }
                .accessibilityLabel("Save document")
                .accessibilityHint("Saves the current document")

            Text("3 unread messages")
                .accessibilityAddTraits(.hasNotifications)
                .accessibilityValue("Three unread messages")
        }
    }
}

// VoiceOver labels
struct ListRow: View {
    let item: ListItem
    var body: some View {
        HStack {
            Image(systemName: item.icon)
            Text(item.title)
            Spacer()
            Text(item.subtitle)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.title) - \(item.subtitle)")
        .accessibilityHint("Tap to view details")
    }
}
```

## Real-World App Structure

```
MyApp/
├── MyApp.swift              // @main entry
├── App/
│   ├── MyApp.swift          // @main App struct with WindowGroup
│   └── AppDelegate.swift    // UIKit delegate (optional)
├── Core/
│   ├── Theme/
│   │   ├── AppTheme.swift        // Theme enum, colors
│   │   └── FontStyles.swift      // Custom fonts
│   ├── Constants/
│   │   ├── API.swift           // base URLs, keys
│   │   └── AppInfo.swift       // app name, version
│   ├── Errors/
│   │   ├── AppError.swift      // Error enum
│   │   └── ValidationError.swift
│   └── Utils/
│       ├── DateFormatter.swift
│       └── DeepLinkParser.swift
├── Features/
│   ├── Auth/
│   │   ├── AuthViewModel.swift
│   │   ├── LoginView.swift
│   │   ├── RegisterView.swift
│   │   └── AuthStore.swift     // @Observable state
│   ├── Home/
│   │   ├── HomeViewModel.swift
│   │   ├── HomeView.swift
│   │   └── Widget/
│   │       ├── FeaturedView.swift
│   │       └── RecentView.swift
│   ├── Profile/
│   │   ├── ProfileViewModel.swift
│   │   ├── ProfileView.swift
│   │   └── EditProfileView.swift
│   └── Settings/
│       ├── SettingsViewModel.swift
│       └── SettingsView.swift
├── Shared/
│   ├── Components/
│   │   ├── CardView.swift          // CardModifier
│   │   ├── LoadingView.swift
│   │   ├── ErrorView.swift
│   │   ├── EmptyView.swift
│   │   └── CustomNavigationBar.swift
│   ├── Navigation/
│   │   └── AppRouter.swift         // AppRouter with NavigationPath
│   └── Views/
│       └── ContentView.swift       // Root view, tab/router setup
├── Data/
│   ├── API/
│   │   ├── APIClient.swift         // URLSession + async/await
│   │   ├── Endpoints.swift
│   │   └── Requests.swift
│   ├── Repository/
│   │   ├── UserRepository.swift
│   │   └── HomeRepository.swift
│   └── Local/
│       ├── Preferences.swift       // UserDefaults wrapper
│       └── Cache.swift
└── Tests/
    ├── Unit/
    ├── UI/
    └── Integration/
```

## macOS-Specific SwiftUI

### Menu Bar App

```swift
struct MenuBarApp: App {
    var body: some Scene {
        MenuBarExtra("My App", systemImage: "app.dashed") {
            VStack(spacing: 12) {
                Button("Open Main App") { /* open window */ }
                Button("Settings") { /* open settings */ }
                Divider()
                Button("Quit") { NSApplication.shared.terminate(nil) }
            }
            .padding()
            .frame(width: 200)
        }
        .menuBarExtraStyle(.window)
    }
}
```

### Multiple Windows

```swift
// macOS: multiple document windows
@main
struct MyMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        // Multiple document windows
        WindowGroup(for: Document.ID.self) { docID in
            if let doc = documentStore.documents[docID] {
                DocumentView(document: doc)
            }
        }

        // Settings
        Settings {
            SettingsView()
        }

        // About
        WindowGroup("About") {
            AboutView()
        }
        .windowStyle(.titleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About") { /* show about */ }
            }
        }
    }
}
```

## iOS 16+ to 17+ to 18+ Features

| Feature | iOS Version | Use Case |
|---|---|---|
| NavigationStack / NavigationPath | iOS 16+ | Modern navigation with programmatic paths |
| Chart | iOS 16+ | Native charting without third-party libs |
| Map (SwiftUI Maps) | iOS 16+ | Built-in Map view |
| @Observable | iOS 17+ | Cleaner reactive state, no Combine needed |
| ContentUnavailableView | iOS 16+ | Empty/error states |
| ViewTesting | iOS 17+ | Testing SwiftUI views |
| @ObservationIgnored | iOS 17+ | Mark non-reactive properties in @Observable |
| TextEditor | iOS 16+ | Rich text editing |
| PresentationDetents (.medium, .large, .fraction) | iOS 16+ | Custom sheet sizes |
| TimelineView | iOS 16+ | Periodic updates |
| Keyframe Animator | iOS 17+ | Complex choreographed animations |
| ContentMargins | iOS 16+ | Layout margins without Spacer |
| FormStyle(.automatic) | iOS 16+ | Adaptive form styling |

```swift
// Feature flag example
@available(iOS 16.0, *)
func modernNavigation() -> some View {
    NavigationStack(path: $router.path) {
        // ...
    }
}

// Fallback for older iOS
@ViewBuilder
func buildNavigation() -> some View {
    if #available(iOS 16.0, *) {
        NavigationStack { /* modern */ }
    } else {
        NavigationView { /* legacy */ }
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
# Check Xcode version
ssh <REMOTE_USER>@<REMOTE_HOST> 'zsh -l -c "xcodebuild -version"'

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

## iOS App Distribution

### TestFlight & Beta

```bash
# Archive and export for TestFlight
xcodebuild archive -workspace ios/Runner.xcworkspace \
  -scheme Runner -configuration Release \
  -archive-path build/Runner.xcarchive

# Export for App Store (TestFlight)
xcodebuild -exportArchive \
  -archivePath build/Runner.xcarchive \
  -exportPath build/ios/ipa \
  -exportOptionsPlist exportOptionsTestFlight.plist

# Upload to App Store Connect
xcrun altool --upload-app \
  --file build/ios/ipa/*.ipa \
  // @version-check App Store Connect API key — EXAMPLE placeholder, replace with real credentials
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID
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
    <!-- "app-store" = App Store, "developer-id" = macOS,
         "enterprise" = Enterprise, "ad-hoc" = AdHoc,
         "development" = Development -->
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>none</string>
    <key>teamID</key>
    // @version-check Team ID — EXAMPLE placeholder, replace with real Team ID
    <string>YOUR_TEAM_ID</string>
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
          // @version-check Flutter — EXAMPLE pin, verify: https://flutter.dev/docs/development/tools/sdk/releases
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
| "Missing Swift version" | Xcode → Project → Info → Swift Language Version |
| "Build settings not found" | Clean: `xcodebuild clean` then rebuild |
| "Provisioning profile expired" | Xcode → Accounts → Manage Certificates → refresh |
| "Widget extension not building" | Check Target → Signing → same team ID as main app |