# AI Adventure 🌌

An infinite, interactive "Choose Your Own Adventure" game powered by Google's Gemini AI.

**AI Adventure** generates unique storylines and context-aware illustrations on the fly, ensuring no two playthroughs are ever the same. It leverages multimodal AI to maintain narrative and visual continuity, allowing you to explore any scenario you can imagine.

## ✨ Features

*   **Infinite Narrative**: Powered by `gemini-2.5-flash`, the story never ends and adapts to your every choice.
*   **Dynamic Illustrations**: Each scene is visualized in real-time using `gemini-2.5-flash-image`.
*   **Visual Continuity**: The AI remembers what the previous scene looked like, maintaining consistency in characters and settings.
*   **Interactive Choices**: Choose from AI-generated options or type your own custom action to do anything you want.
*   **Full-Screen Immersion**: Tap any image to explore it in a zoomable, full-screen view.
*   **Cross-Platform**: Runs smoothly on Android, iOS, macOS, and Web.

## 🛠️ Setup & Configuration

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   A **Gemini API Key** from [Google AI Studio](https://aistudio.google.com/).

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/antigravity-adventure.git
    cd antigravity-adventure
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the App**:
    *   Launch the app on your device or emulator.
    *   You will be prompted to enter your **Gemini API Key** on the first run.
    *   The key is stored securely on your device using `shared_preferences`.

## 🚀 How to Run

### Mobile & Desktop
```bash
flutter run
```

### Web
To run on the web:
```bash
flutter run -d chrome
```

## 🎮 How to Play

1.  **Start Your Adventure**: Enter a starting scenario (e.g., "A space pirate waking up in a jail cell" or "A wizard lost in a neon city").
2.  **Make Choices**: Read the story and select one of the generated choices, or type your own custom action in the text field.
3.  **Explore Visuals**:
    *   The AI generates an image for every scene.
    *   **Tap the image** to open it in full-screen mode.
    *   **Zoom and Pan** to see details.
    *   Press **Esc** (on desktop) or tap the back button to return to the story.

## 🏗️ Architecture

This project uses a clean, reactive architecture:

*   **State Management**: [signals_flutter](https://pub.dev/packages/signals_flutter) for reactive state and clean UI updates.
*   **AI Integration**:
    *   **Text**: Uses the `google_generative_ai` SDK for managing chat sessions and history.
    *   **Images**: Uses a custom REST implementation to handle multimodal context (passing previous images to the model).
*   **Safety**: Implements robust error handling to ensure the game continues even if an image fails to generate due to safety filters.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
