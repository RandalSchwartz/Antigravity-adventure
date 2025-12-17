# Product Requirements Document (PRD): AI Adventure

## 1. Executive Summary
**AI Adventure** is an infinite, interactive "Choose Your Own Adventure" game powered by Google's latest Gemini AI models. Unlike traditional text adventures, this application generates unique storylines and context-aware illustrations on the fly, ensuring no two playthroughs are ever the same. It leverages multimodal AI to maintain narrative and visual continuity, allowing users to explore any scenario they can imagine.

## 2. Core Features

### 2.1 Dynamic Storytelling
-   **Infinite Narrative**: Uses `gemini-2.5-flash` to generate story segments based on user actions.
-   **Context Retention**: Maintains a persistent chat history so the AI remembers past events, characters, and choices.
-   **Structured Output**: Returns story text and a set of 3 distinct choices in a structured JSON format.

### 2.2 Multimodal Image Generation
-   **Scene Visualization**: Uses `gemini-2.5-flash-image` (Nano-banana) to generate a visual representation of every story segment.
-   **Visual Continuity**: Passes the *previous generated image* and the *entire conversation history* as context to the image model. This ensures that if a character is wearing a red hat in scene 1, they (ideally) still have it in scene 2.
-   **Hybrid Implementation**: Uses a custom REST implementation to bypass current SDK limitations for multimodal context.

### 2.3 User Interaction
-   **Pre-defined Choices**: Users can select from 3 AI-generated options to advance the story.
-   **Custom Input**: Users can type their own free-form action (e.g., "I try to fly away"), and the AI will adapt the story accordingly.
-   **Theme Selection**: Users start the game by defining their own setting (e.g., "Cyberpunk detective," "Medieval wizard," "Space opera").

## 3. Technical Architecture

### 3.1 Tech Stack
-   **Framework**: Flutter (Supports Android, iOS, macOS, Web).
-   **Language**: Dart.
-   **State Management**: `signals_flutter` (Reactive state management for loading, error, and data states).
    -   **Requirement**: All `signal` and `computed` instances must have explicit `debugLabel` properties to facilitate debugging and state tracking.
-   **AI Integration**:
    -   **Text**: `google_generative_ai` Dart SDK (Official). Used for `ChatSession` management.
    -   **Images**: Raw HTTP/REST API. Used to bypass current SDK limitations regarding `inline_data` (images) in both request and response for the `gemini-2.5-flash-image` model.

### 3.2 Data Flow
1.  **Initialization**: User inputs a prompt.
2.  **Text Step**: App sends prompt to Gemini Flash via SDK `ChatSession`. Recieves JSON (Story + Choices).
3.  **Image Step**: App sends Story Text + Chat History (as text) + Previous Image (Base64, via REST) to Gemini Flash Image. Receives new Image (Base64).
    -   **Context Persistence**: The app maintains a reference to the `_lastSuccessfulImage`. If generation fails (e.g., safety filter), this previous image is preserved and used as context for the *next* turn, ensuring visual continuity is not broken by a single failure.
    -   **Error Handling**: Image generation errors (safety, network) are caught gracefully. The UI clears the current image (or shows a placeholder) but allows the text story to proceed uninterrupted.
4.  **Update**: UI updates with new text, image, and choices. History is appended.

### 3.3 Configuration
-   **Dynamic API Key**: API keys are no longer hardcoded or stored in `.env` files.
-   **Storage**: Uses `shared_preferences` to store the user's API key locally on the device.
-   **User Prompt**: On first launch, the app checks for a stored key. If missing, it redirects to an `ApiKeyScreen` where the user can paste their key.
-   **Re-prompt on Failure**: If the API key is invalid or stops working (e.g., 401 Unauthorized), the app must detect the error and automatically redirect the user back to the `ApiKeyScreen` to provide a valid key.

### 3.4 Error Handling & Stability
-   **Safe Exception Handling**: All `try-catch` blocks must explicitly catch `Exception` (e.g., `on Exception catch (e)`) to avoid swallowing critical programming errors (like `TypeError` or `RangeError`).
-   **Global Error Boundary**:
    -   **Framework Errors**: `FlutterError.onError` is overridden to catch and log widget build errors.
    -   **Async Errors**: `PlatformDispatcher.instance.onError` is overridden to catch unhandled background errors.
    -   **User Feedback**: A global `ErrorScreen` is displayed when a fatal error occurs, allowing the user to restart the app gracefully.
-   **Stack Trace Preservation**: When re-throwing exceptions in services, `Error.throwWithStackTrace` must be used to preserve the original origin of the error for easier debugging.

## 4. User Interface (UI)

### 4.1 Start Screen
-   Clean, inviting interface.
-   Text input field for the "Starting Scenario".
-   "Begin Adventure" button.

### 4.2 Story Screen
-   **Header**: Displays the generated scene image.
    -   **Aspect Ratio**: Uses `BoxFit.contain` to ensure the entire image is visible without cropping.
    -   **Interaction**: Tapping the image opens a full-screen, zoomable view (`InteractiveViewer`).
    -   **Keyboard Support**: The full-screen viewer can be closed by pressing the `Escape` key.
-   **Story Text**: Markdown-rendered text describing the current situation.
-   **Choices**: Vertical list of buttons for the AI-suggested actions.
-   **Custom Action**: Text field at the bottom for free-form user input.
    -   **Keyboard Support**: Pressing `Enter` submits the custom action.
-   **Loading State**:
    -   **Buttons**: Disabled while generating.
    -   **Image**: Dims to 50% opacity (`Opacity` widget) to indicate that a new image is being generated, providing visual feedback while maintaining context.

## 5. Demo Build Guide (Step-by-Step)

To recreate this application for a live demo, follow this sequence:

### Step 1: Project Setup
1.  Create a new Flutter project: `flutter create ai_adventure`
2.  Add dependencies:
    ```bash
    flutter pub add signals_flutter google_generative_ai flutter_markdown shared_preferences http url_launcher
    ```

### Step 2: State Management (`GameState`)
1.  Create a singleton `GameState` class.
2.  Define signals: `currentStory`, `currentImage`, `isLoading`, `apiKey`.
3.  Add `init()` method to load the API key from `SharedPreferences`.

### Step 3: Hybrid AI Services
1.  **Text (`GeminiService`)**: Implement using the official SDK (`GenerativeModel`, `ChatSession`).
2.  **Image (`ImageService`)**: Implement using **Raw HTTP** to bypass SDK limitations.
    -   *Critical*: Manually construct the JSON body to include `inline_data` (previous image) for context.
    -   *Critical*: Do NOT use `response_mime_type: application/json`.

### Step 4: UI Implementation
1.  **`ApiKeyScreen`**: Simple input field to save the key to `GameState` (and prefs).
2.  **`StartScreen`**: Text field for the initial prompt.
3.  **`StoryScreen`**:
    -   Use `Watch` (from Signals) to reactively build the UI.
    -   Wrap the image in `Opacity` for the dimming effect during loading.
    -   Use `InteractiveViewer` for the full-screen zoom feature.

### Step 5: Main Entry Point
1.  Update `main.dart` to initialize `GameState` before `runApp`.
100. 2.  Use a reactive `home` widget that switches between `ApiKeyScreen` and `StartScreen` based on the `apiKey` signal.
101. 3.  **Global Error Handler**: Wrap `runApp` logic to catch `FlutterError` and `PlatformDispatcher` errors. Implement `ErrorWidget.builder` to show the `ErrorScreen` on crash.
102. 4.  **macOS Permissions**: Add `com.apple.security.network.client` to `macos/Runner/*.entitlements` to allow internet access.

## 6. Future Roadmap
-   **Save/Load**: Ability to serialize the chat history and image paths to save progress.
-   **Voice Mode**: Text-to-Speech for reading the story and Speech-to-Text for input.
-   **Character Sheets**: Side panel tracking inventory and stats (extracted by the AI).
