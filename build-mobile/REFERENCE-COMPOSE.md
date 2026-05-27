# Compose Testing Reference

## Basic Test

```kotlin
package com.example.app.ui

import androidx.compose.ui.test.*
import androidx.compose.ui.test.junit4.createComposeRule
import org.junit.Rule
import org.junit.Test

class MainActivityTest {
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
}
```

## Activity Scenario Test (full app context)

```kotlin
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import com.example.app.MainActivity

class MainActivityScenarioTest {
    @get:Rule
    val activityRule = createAndroidComposeRule<MainActivity>()

    @Test
    fun testWithActivity() {
        activityRule.onNodeWithText("Some Text").assertIsDisplayed()
    }
}
```

## Semantics for Testing

```kotlin
// In your Compose code:
Button(
    onClick = { /* ... */ },
    modifier = Modifier.semantics { testTag = "addButton" }
) { Text("Add") }

// In tests:
composeTestRule.onNodeWithTag("addButton").performClick()
```

## Add Compose Testing Dependencies

```kotlin
// app/build.gradle.kts
dependencies {
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}
```

## New Testing APIs (Compose 1.5+)

```kotlin
import androidx.compose.ui.test.junit4.createComposeRule
import androidx.compose.ui.test.hasText
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsDisplayed

// Modern approach with findNodes
composeTestRule.onNode(hasText("Hello")).assertIsDisplayed()
composeTestRule.onAllNodesWithText("Item").assertCountEquals(5)
```
