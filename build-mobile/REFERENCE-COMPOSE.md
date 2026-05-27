# Jetpack Compose Reference

## Layouts

### Basic Layouts

```kotlin
// Column — vertical stack
Column(horizontalAlignment = Alignment.CenterHorizontally) {
    Text("Title")
    Text("Subtitle")
    Button(onClick = { /* action */ }) { Text("Click") }
}

// Row — horizontal stack
Row(horizontalArrangement = Arrangement.SpaceBetween) {
    Icon(Icons.Default.Search, contentDescription = null)
    TextField(value, onValueChange = { /* ... */ })
}

// Box — overlay/stack
Box(contentAlignment = Alignment.Center) {
    Image(painter, contentDescription = null)  // background
    Text("Overlay")                              // foreground
}

// LazyColumn / LazyRow — efficient lists
LazyColumn {
    items(items) { item ->
        ItemRow(item)
    }
}

// LazyVerticalGrid — grid layouts
LazyVerticalGrid(
    columns = GridCells.Fixed(2),
    contentPadding = PaddingValues(8.dp),
    horizontalArrangement = Arrangement.spacedBy(8.dp),
    verticalArrangement = Arrangement.spacedBy(8.dp)
) {
    items(items) { item ->
        CardItem(item)
    }
}
```

### ConstraintLayout

```kotlin
// ConstraintLayout for complex layouts
ConstraintLayout {
    val (image, title, subtitle, button) = createRefs()

    AsyncImage(
        model = imageUrl,
        contentDescription = null,
        modifier = Modifier.constrainAs(image) {
            top.linkTo(parent.top)
            start.linkTo(parent.start)
        }
    )

    Text(title, modifier = Modifier.constrainAs(title) {
        top.linkTo(image.bottom, margin = 8.dp)
        start.linkTo(parent.start)
    })

    Text(subtitle, modifier = Modifier.constrainAs(subtitle) {
        top.linkTo(title.bottom, margin = 4.dp)
        start.linkTo(parent.start)
    })

    Button(onClick = { /* action */ }, modifier = Modifier.constrainAs(button) {
        top.linkTo(subtitle.bottom, margin = 16.dp)
        start.linkTo(parent.start)
    }) {
        Text("Action")
    }
}
```

### Padding & Spacing

```kotlin
// Padding
Box(modifier = Modifier.padding(16.dp)) { Text("With padding") }
Box(modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)) { }
Box(modifier = Modifier.padding(
    PaddingValues(vertical = 8.dp, start = 16.dp, end = 16.dp)
)) { }

// Spacing with Spacer
Column {
    Text("Item 1")
    Spacer(modifier = Modifier.height(8.dp))
    Text("Item 2")
}

// Weight (proportional sizing)
Row(modifier = Modifier.fillMaxWidth()) {
    Text("Text", modifier = Modifier.weight(1f))
    Button(onClick = {}) { Text("Button", modifier = Modifier.weight(0.5f)) }
}

// Size & Max/Min constraints
Box(modifier = Modifier
    .fillMaxWidth()
    .heightIn(min = 100.dp, max = 300.dp)
    .width(200.dp)
)
```

## Theming

### Material3 Theme

```kotlin
// Color palette
private val LightColorScheme = lightColorScheme(
    primary = Color(0xFF6750A4),
    onPrimary = Color.White,
    primaryContainer = Color(0xFFE0BCFF),
    secondary = Color(0xFF625B71),
    tertiary = Color(0xFF7D5260),
    background = Color(0xFFFFFBFE),
    surface = Color(0xFFFFFBFE),
    error = Color(0xFFB3261E),
)

private val DarkColorScheme = darkColorScheme(
    primary = Color(0xFFCCC2DC),
    onPrimary = Color(0xFF381E72),
    primaryContainer = Color(0xFF4F378B),
    secondary = Color(0xFFCCC2DC),
    tertiary = Color(0xFFEFB8C8),
    background = Color(0xFF1C1B1F),
    surface = Color(0xFF1C1B1F),
    error = Color(0xFFF2B8B5),
)

// Theme composable
@Composable
fun MyAppTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}

// Usage
@Composable
fun MyApp() {
    MyAppTheme {
        // App content
    }
}
```

### Custom Typography & Components

```kotlin
// Custom typography
val AppTypography = Typography(
    displayLarge = TextStyle(
        fontSize = 57.sp,
        fontWeight = FontWeight.Normal,
        letterSpacing = (-0.25.sp)
    ),
    headlineMedium = TextStyle(
        fontSize = 28.sp,
        fontWeight = FontWeight.Bold
    ),
    bodyLarge = TextStyle(
        fontSize = 16.sp,
        fontWeight = FontWeight.Normal,
        lineHeight = 24.sp
    ),
)

// Custom shapes
val AppShapes = Shapes(
    extraSmall = RoundedCornerShape(4.dp),
    small = RoundedCornerShape(8.dp),
    medium = RoundedCornerShape(16.dp),
    large = RoundedCornerShape(24.dp),
    extraLarge = RoundedCornerShape(32.dp)
)

MaterialTheme(
    colorScheme = colorScheme,
    typography = AppTypography,
    shapes = AppShapes,
    content = content
)
```

## Material3 Components

### Cards

```kotlin
// Filled card
Card(
    modifier = Modifier.fillMaxWidth(),
    shape = RoundedCornerShape(16.dp),
    elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
) {
    Column(modifier = Modifier.padding(16.dp)) {
        Text("Title", style = MaterialTheme.typography.titleMedium)
        Text("Description", style = MaterialTheme.typography.bodyMedium)
    }
}

// Elevated card
ElevatedCard(
    modifier = Modifier.fillMaxWidth(),
    onClick = { /* navigate */ }
) { /* content */ }

// Outlined card
OutlinedCard(
    modifier = Modifier.fillMaxWidth(),
    onClick = { /* action */ }
) { /* content */ }
```

### Lists

```kotlin
// Single line list
LazyColumn {
    items(items) { item ->
        ListItem(
            headlineText = { Text(item.title) },
            supportingText = { Text(item.subtitle) },
            leadingContent = {
                Icon(Icons.Default.Favorite, contentDescription = null)
            },
            trailingContent = {
                Icon(Icons.Default.ChevronRight, contentDescription = null)
            },
            modifier = Modifier.clickable(onClick = { /* navigate */ })
        )
    }
}

// Two-line list with actions
ListItem(
    headlineText = { Text("Item") },
    supportingText = { Text("Description") },
    overlineText = { Text("OVERLINE") },
    leadingContent = { CircleAvatar(text = "A") },
    trailingContent = {
        IconButton(onClick = { /* more actions */ }) {
            Icon(Icons.Default.MoreVert, contentDescription = null)
        }
    }
)

// Custom list with SwipeToDismiss
LazyColumn {
    items(items, key = { it.id }) { item ->
        SwipeToDismiss(
            directions = { SwipeDirection.StartToEnd },
            background = {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.Red),
                    contentAlignment = Alignment.CenterStart
                ) {
                    Text("Delete", color = White)
                }
            },
            onDismissed = { /* handle delete */ }
        ) { dismissState ->
            CustomListItem(item, modifier = Modifier
                .graphicsLayer { alpha = dismissState.progress })
        }
    }
}
```

### Bottom Sheets

```kotlin
// ModalBottomSheet (Navigation-based)
@Composable
fun SheetSheet(@PreviewParameter(SheetPreviewParameterProvider::class) sheet: Sheet) {
    Navigation(
        previewParameterProvider = SheetPreviewParameterProvider()
    ) { navController ->
        ModalBottomSheet(
            onDismissRequest = { navController.popBackStack() },
            modifier = Modifier.nestedScroll(
                navController.nestedScrollConnection
            )
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("Title", style = MaterialTheme.typography.titleMedium)
                Text("Content", style = MaterialTheme.typography.bodyMedium)
                Button(onClick = { /* action */ }) { Text("Action") }
            }
        }
    }
}

// Scaffold with bottom bar
Scaffold(
    bottomBar = {
        NavigationBar {
            items.forEachIndexed { index, item ->
                NavigationBarItem(
                    selected = selectedIndex == index,
                    onClick = { selectedIndex = index },
                    icon = { Icon(item.icon, contentDescription = null) },
                    label = { Text(item.title) }
                )
            }
        }
    },
    content = { padding -> /* content */ }
)
```

### Dialogs

```kotlin
// Basic dialog
@Composable
fun BasicDialog(
    onDismiss: () -> Unit,
    onConfirm: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Confirm Action") },
        text = { Text("Are you sure you want to proceed?") },
        confirmButton = {
            TextButton(onClick = onConfirm) { Text("Confirm") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}

// Custom dialog (BasicAlertDialog)
@Composable
fun CustomDialog(onDismiss: () -> Unit) {
    BasicAlertDialog(onDismissRequest = onDismiss) {
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            shape = RoundedCornerShape(16.dp),
            tonalElevation = 8.dp
        ) {
            Column(modifier = Modifier.padding(24.dp)) {
                Text("Custom Dialog", style = MaterialTheme.typography.headlineSmall)
                Spacer(modifier = Modifier.height(8.dp))
                Text("This is a fully custom dialog content.")
                Spacer(modifier = Modifier.height(16.dp))
                Button(onClick = onDismiss) { Text("Close") }
            }
        }
    }
}
```

### Snackbars & Toast

```kotlin
// Snackbar with Scaffold
@Composable
fun SnackbarDemo(scaffoldState: ScaffoldState) {
    LaunchedEffect(Unit) {
        // Show snackbar
        scaffoldState.snackbarHostState.showSnackbar(
            message = "Item saved successfully",
            actionLabel = "Undo"
        ) { /* handle action */ }
    }
}

Scaffold(
    snackbarHost = {
        SnackbarHost(hostState = scaffoldState.snackbarHostState) { data ->
            Snackbar(
                modifier = Modifier.padding(8.dp),
                action = { Button(onClick = data::performAction) { Text("Undo") } },
                shape = RoundedCornerShape(8.dp)
            ) { Text(data.snackbarData.message) }
        }
    },
    content = { /* content */ }
)
```

## ViewModel Integration

```kotlin
// ViewModel class
class HomeViewModel @Inject constructor(
    private val repository: HomeRepository
) : ViewModel() {
    private val _uiState = MutableStateFlow<HomeUiState>(HomeUiState.Loading)
    val uiState: StateFlow<HomeUiState> = _uiState

    init { loadContent() }

    private fun loadContent() {
        viewModelScope.launch {
            _uiState.value = HomeUiState.Loading
            try {
                val data = repository.getHomeData()
                _uiState.value = HomeUiState.Success(data)
            } catch (e: Exception) {
                _uiState.value = HomeUiState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun onItemClicked(id: String) { /* handle */ }
}

sealed interface HomeUiState {
    object Loading : HomeUiState
    data class Success(val data: HomeData) : HomeUiState
    data class Error(val message: String) : HomeUiState
}

// Use in composable
@Composable
fun HomeScreen(viewModel: HomeViewModel = viewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    when (val state = uiState) {
        is HomeUiState.Loading -> CircularProgressIndicator()
        is HomeUiState.Success -> Content(state.data)
        is HomeUiState.Error -> ErrorView(
            message = state.message,
            onRetry = { viewModel.loadContent() }
        )
    }
}

// With Hilt (dependency injection)
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val repository: HomeRepository
) : ViewModel() { /* ... */ }
```

## Navigation (NavHost/NavController)

### Setup

```kotlin
// Routes
sealed class Screen(val route: String) {
    object Home : Screen("home")
    object Detail : Screen("detail/{itemId}") {
        fun createRoute(itemId: String) = "detail/$itemId"
    }
    object Settings : Screen("settings")
    object Profile : Screen("profile")
}

// NavGraph
@Composable
fun AppNavGraph(
    navController: NavHostController = rememberNavController(),
    startDestination: String = Screen.Home.route
) {
    NavHost(
        navController = navController,
        startDestination = startDestination
    ) {
        composable(Screen.Home.route) {
            HomeScreen(
                onItemClicked = { itemId ->
                    navController.navigate(Screen.Detail.createRoute(itemId))
                },
                onSettingsClicked = { navController.navigate(Screen.Settings.route) }
            )
        }
        composable(
            route = Screen.Detail.route,
            arguments = listOf(navArgument("itemId") { defaultValue = "" })
        ) { backStackEntry ->
            val itemId = backStackEntry.arguments?.getString("itemId") ?: ""
            DetailScreen(itemId = itemId) {
                navController.popBackStack()
            }
        }
        composable(Screen.Settings.route) { SettingsScreen() }
    }
}

// With Navigation Animation
NavHost(
    navController = navController,
    startDestination = startDestination,
    enterTransition = { fadeIn() + slideIntoContainer(EnumValues.SLIDE_LEFT) },
    exitTransition = { fadeOut() + slideOutOfContainer(EnumValues.SLIDE_RIGHT) },
    popEnterTransition = { fadeIn() },
    popExitTransition = { fadeOut() }
)
```

### Nested Navigation

```kotlin
// Nested graph for settings
 NavGraph(
    navController = navController,
    startDestination = "settings_group"
) {
    navigation(
        route = "settings_group",
        startDestination = Screen.Settings.route
    ) {
        composable(Screen.Settings.route) { SettingsScreen() }
        composable("privacy") { PrivacyScreen() }
        composable("notifications") { NotificationsScreen() }
    }
}
```

### Deep Links

```kotlin
@Route(
    deepLinks = [
        NavigationDeepLink(
            uriPattern = "https://example.com/detail/{itemId}"
        ),
        NavigationDeepLink(
            uriPattern = "myapp://detail/{itemId}"
        )
    ]
)
```

## Pull-to-Refresh & Infinite Scroll

```kotlin
// Pull-to-refresh
var isRefreshing by remember { mutableStateOf(false) }
Scaffold(
    content = {
        LazyColumn {
            items(items) { item -> ItemRow(item) }
        }
    },
    modifier = Modifier.refreshable(state = RefreshState(isRefreshing)) {
        viewModel.loadMore()
    }
)

// Infinite scroll with LazyColumn
var hasMore by remember { mutableStateOf(true) }
LazyColumn(
    modifier = Modifier.fillMaxSize(),
    contentPadding = PaddingValues(8.dp),
    verticalArrangement = Arrangement.spacedBy(8.dp),
    state = listState
) {
    items(items) { item -> ItemCard(item) }

    if (hasMore) {
        item {
            CircularProgressIndicator(modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp))
        }
    }
}
// Use LaunchedEffect to detect scroll end and load more
```

## Forms & Input

```kotlin
// Text field with validation
@Composable
fun ValidatedTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    isError: Boolean = false,
    errorMessage: String = ""
) {
    OutlinedTextField(
        value = value,
        onValueChange = onValueChange,
        label = { Text(label) },
        isError = isError,
        supportingText = {
            if (isError) Text(errorMessage)
        },
        modifier = Modifier.fillMaxWidth()
    )
}

// Form state management
@Composable
fun RegistrationForm(onSubmit: (User) -> Unit) {
    var name by remember { mutableStateOf("") }
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var isLoading by remember { mutableStateOf(false) }

    val nameError = if (name.length < 2) "Name too short" else null
    val emailError = if (!email.contains("@")) "Invalid email" else null
    val passwordError = if (password.length < 8) "At least 8 characters" else null
    val isValid = nameError == null && emailError == null && passwordError == null

    Column(modifier = Modifier.padding(16.dp)) {
        ValidatedTextField(name, { name = it }, "Name", nameError != null, nameError ?: "")
        ValidatedTextField(email, { email = it }, "Email", emailError != null, emailError ?: "")
        ValidatedTextField(password, { password = it }, "Password", passwordError != null, passwordError ?: "")
            .passwordVisualTransformation()

        Spacer(modifier = Modifier.height(16.dp))

        Button(
            onClick = { if (isValid) { isLoading = true; onSubmit(User(name, email, password)) } },
            modifier = Modifier.fillMaxWidth(),
            enabled = isValid && !isLoading
        ) {
            if (isLoading) CircularProgressIndicator() else Text("Register")
        }
    }
}

// Date/Time picker
DatePickerDialog(
    onDateSelected = { date -> /* handle */ },
    initialSelectedDate = today,
    confirmButton = { Text("OK") },
    dismissButton = { Text("Cancel") }
)
```

## Gesture Handling

```kotlin
// Basic tap
Box(modifier = Modifier.clickable(onClick = { /* action */ }))

// Long press
Box(modifier = Modifier.longClickable(onLongClick = { /* action */ }))

// Swipe
Box(modifier = Modifier
    .pointerInput(Unit) {
        detectTapGestures(
            onPress = { /* press down */ },
            onDoubleTap = { /* double tap */ },
            onLongPress = { /* long press */ },
            onTap = { /* single tap */ }
        )
    }
)

// Pan gesture (drag)
var offset by remember { mutableFloatStateOf(0f) }
Box(
    modifier = Modifier
        .offset { IntOffset(offset.roundToInt(), 0) }
        .pointerInput(Unit) {
            detectDragGestures { change, dragAmount ->
                change.consumeAllChanges()
                offset += dragAmount.x
            }
        }
)

// Nested scrolling (for scroll + expand effects)
Scaffold(
    modifier = Modifier.nestedScroll(
        rememberNestedScrollInteropConnection()
    )
)
```

## Testing (Jetpack Compose)

```kotlin
// Basic test
@get:Rule
val composeTestRule = createComposeRule()

@Test
fun app_launches_andShowsContent() {
    composeTestRule.setContent { MyApp() }
    composeTestRule.onNodeWithText("Hello").assertIsDisplayed()
}

@Test
fun button_click_updatesText() {
    composeTestRule.setContent { MyApp() }
    composeTestRule.onNodeWithContentDescription("Add").performClick()
    composeTestRule.onNodeWithText("1").assertIsDisplayed()
}

// With ViewModel
class HomeViewModelTest {
    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun home_displays_loading_state() {
        val viewModel = HomeViewModel(/* mock repo */)
        composeTestRule.setContent {
            HomeScreen(viewModel = viewModel)
        }
        composeTestRule.onNodeWithText("Loading").assertExists()
    }

    @Test
    fun home_displays_error_with_retry() {
        val viewModel = HomeViewModel(errorRepo)
        composeTestRule.setContent {
            HomeScreen(viewModel = viewModel)
        }
        composeTestRule.onNodeWithText("Retry").assertExists()
    }
}

// Semantics for testing
@Composable
fun AddButton(onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier.semantics { testTag = "addButton" }
    ) { Text("Add") }
}
// In tests:
composeTestRule.onNodeWithTag("addButton").performClick()
```

## Common Compose Patterns

### Loading / Error / Empty / Success States

```kotlin
@Composable
fun StateAwareContent(
    state: UiState,
    retry: () -> Unit = {},
    content: @Composable () -> Unit
) {
    when (state) {
        is UiState.Loading -> CircularProgressIndicator(
            modifier = Modifier.align(Alignment.Center)
        )
        is UiState.Error -> ErrorContent(
            message = state.message,
            onRetry = retry
        )
        is UiState.Empty -> EmptyContent()
        is UiState.Success -> content()
    }
}
```

### Async Image Loading

```kotlin
// Coil (recommended)
implementation("io.coil-kt:coil-compose:2.7.0")

// In composable
AsyncImage(
    model = imageUrl,
    contentDescription = "Image",
    modifier = Modifier.size(100.dp),
    contentScale = ContentScale.Crop,
    placeholder = MemoryImage(placeholderResId),
    error = MemoryImage(errorResId)
)
```

### Pull-to-Refresh with StateFlow

```kotlin
var isRefreshing by remember { mutableStateOf(false) }

LaunchedEffect(viewModel.uiState) {
    when (val state = viewModel.uiState) {
        is UiState.Loading -> isRefreshing = true
        else -> isRefreshing = false
    }
}
```

## Compose Dependencies

| Library | Dependency | Notes |
|---|---|---|
| Material3 | `androidx.compose.material3:material3` | Core UI // @version-check EXAMPLE pin |
| Material3 Windows | `androidx.compose.material3:material3-window-size-class` | Responsive // @version-check EXAMPLE pin |
| Navigation | `androidx.navigation:navigation-compose:2.9.0` | Navigation // @version-check Nav — EXAMPLE pin |
| Lifecycle | `androidx.lifecycle:lifecycle-viewmodel-compose:2.9.0` | ViewModel // @version-check Lifecycle — EXAMPLE pin |
| Lifecycle Runtime | `androidx.lifecycle:lifecycle-runtime-compose:2.9.0` | StateFlow // @version-check Lifecycle Runtime — EXAMPLE pin |
| Animation | `androidx.compose.animation:animation` | Animations // @version-check EXAMPLE pin |
| Icons | `androidx.compose.material:material-icons-extended` | Extra icons // @version-check EXAMPLE pin |
| Coil | `io.coil-kt:coil-compose:2.7.0` | Image loading // @version-check Coil — EXAMPLE pin |
| Hilt | `androidx.hilt:hilt-navigation-compose:1.2.0` | DI // @version-check Hilt — EXAMPLE pin |
| Testing | `androidx.compose.ui:ui-test-junit4` | Instrumented tests // @version-check EXAMPLE pin |
| Testing Manifest | `androidx.compose.ui:ui-test-manifest` | Debug tests // @version-check EXAMPLE pin |

> **ALWAYS check the Compose BOM version** — pin via `val composeBom = platform("androidx.compose:compose-bom:2025.06.01")` and use `implementation(composeBom)`. All version pins in this document are EXAMPLES and must be verified before use.

## Compose on Desktop / Web (Compose Multiplatform)

```kotlin
// Desktop-specific
import androidx.compose.desktop.ui.tooling.preview.Preview

@Preview
@Composable
fun DesktopPreview() {
    DesktopApp()
}

// Window management (desktop)
Window(
    title = "My App",
    size = DpSize(800.dp, 600.dp),
    resizable = true
) {
    Content()
}
```
