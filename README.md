# AI Adventure 🌌

An infinite, interactive "Choose Your Own Adventure" game powered by Google's Gemini AI.

**AI Adventure** generates unique storylines and context-aware illustrations on the fly, ensuring no two playthroughs are ever the same. It leverages multimodal AI to maintain narrative and visual continuity, allowing you to explore any scenario you can imagine.

## ✨ Features

*   **Infinite Narrative**: Powered by `gemini-3-flash`, the story never ends and adapts to your every choice.
*   **Dynamic Illustrations**: Each scene is visualized in real-time using `gemini-3-pro-image-preview` (Nano Banana Pro).
*   **Visual Continuity**: Powered by **Image-to-Image (I2I)**, the AI uses previous scenes as visual references to maintain consistency in characters and settings.
*   **Interactive Choices**: Choose from AI-generated options or type your own custom action to do anything you want.
*   **Full-Screen Immersion**: Tap any image to explore it in a zoomable, full-screen view.
*   **Cross-Platform**: Runs smoothly on Android, iOS, macOS, and Web.

## 🚀 Setup & Configuration

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
*   A **Gemini API Key** from [Google AI Studio](https://aistudio.google.com/).

### Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/RandalSchwartz/Antigravity-adventure.git
    cd Antigravity-adventure
    ```

2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the App**:
    *   Launch the app on your device or emulator.
    *   You will be prompted to enter your **Gemini API Key** on the first run.
    *   The key is stored securely on your device using `shared_preferences`.

## 🏗️ Architecture

This project uses a modern, reactive architecture powered by **Agentic AI**:

*   **State Management**: [signals_flutter](https://pub.dev/packages/signals_flutter) for reactive state and clean UI updates.
*   **AI Framework**: [dartantic_ai](https://pub.dev/packages/dartantic_ai) – a declarative agentic framework for Dart.
    *   **Text Agent**: Uses `gemini-3-flash-preview` with structured JSON output for narrating the story and offering choices.
    *   **Image Agent**: Uses `gemini-3-pro-image-preview` with **Multimedia Input** (attachments) to achieve image-to-image visual consistency.
*   **Safety & Robustness**: Implements robust error handling to ensure the game continues even if an image fails to generate due to safety filters.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.
