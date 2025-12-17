import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../services/gemini_service.dart';
import '../services/image_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  GeminiService? _geminiService;
  ImageService? _imageService;

  // Signals
  final apiKey = signal<String?>(null, debugLabel: 'Game State: API Key');
  final currentStory = signal<StorySegment?>(
    null,
    debugLabel: 'Game State: Current Story',
  );
  final currentImage = signal<Uint8List?>(
    null,
    debugLabel: 'Game State: Current Image',
  );
  final isLoading = signal(false, debugLabel: 'Game State: Is Loading');
  final error = signal<String?>(null, debugLabel: 'Game State: Error');
  final history = listSignal<String>(
    [],
    debugLabel: 'Game State: Story History',
  );

  // Internal state to track the last valid image for context
  Uint8List? _lastSuccessfulImage;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('gemini_api_key');
    if (key != null && key.isNotEmpty) {
      setApiKey(key);
    }
  }

  void setApiKey(String key) {
    apiKey.value = key;
    _geminiService = GeminiService(key);
    _imageService = ImageService(key);

    // Save to prefs
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('gemini_api_key', key);
    });
  }

  Future<void> clearApiKey() async {
    apiKey.value = null;
    _geminiService = null;
    _imageService = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gemini_api_key');
  }

  Future<void> startGame(String initialPrompt) async {
    if (_geminiService == null || _imageService == null) {
      error.value = "API Key not set";
      return;
    }
    isLoading.value = true;
    error.value = null;
    history.clear();
    _lastSuccessfulImage = null; // Reset on new game

    try {
      // Generate first story segment
      final story = await _geminiService!.generateStory(initialPrompt);
      currentStory.value = story;

      // Generate image based on story text
      try {
        final image = await _imageService!.generateImage(
          storyText: story.text,
          conversationHistory: _geminiService!.chatHistory,
          previousImage: null,
        );
        currentImage.value = image;
        _lastSuccessfulImage = image;
      } on Exception catch (e, stackTrace) {
        debugPrint('Initial image generation failed: $e');
        debugPrintStack(stackTrace: stackTrace);
        currentImage.value = null;
        error.value = "Story generated, but visual scene failed: $e";
      }

      // Add to display history
      history.add("Start: $initialPrompt");
      history.add(story.text);
    } on Exception catch (e, stackTrace) {
      error.value = e.toString();
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> makeChoice(String choice) async {
    if (isLoading.value) return;
    if (_geminiService == null || _imageService == null) {
      error.value = "API Key not set";
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      // Generate next segment
      final story = await _geminiService!.generateStory(choice);
      currentStory.value = story;

      // Generate image with full context (using last successful image)
      try {
        final image = await _imageService!.generateImage(
          storyText: story.text,
          conversationHistory: _geminiService!.chatHistory,
          previousImage: _lastSuccessfulImage,
        );
        currentImage.value = image;
        _lastSuccessfulImage = image;
      } on Exception catch (e, stackTrace) {
        debugPrint('Image generation failed: $e');
        debugPrintStack(stackTrace: stackTrace);
        // If failed, we clear the current display image but keep _lastSuccessfulImage for next time
        currentImage.value = null;
        error.value = "Story continued, but visual scene failed: $e";
      }

      // Update display history
      history.add("Action: $choice");
      history.add(story.text);
    } on Exception catch (e, stackTrace) {
      error.value = e.toString();
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }
}

final gameState = GameState();
