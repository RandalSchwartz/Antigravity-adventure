import 'package:cyoa_game/services/gemini_service.dart';
import 'package:cyoa_game/services/image_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';

class GameState {
  GeminiService? _geminiService;
  ImageService? _imageService;

  // Signals
  final FlutterSignal<String?> apiKey = signal<String?>(
    null,
    debugLabel: 'Game State: API Key',
  );
  final FlutterSignal<StorySegment?> currentStory = signal<StorySegment?>(
    null,
    debugLabel: 'Game State: Current Story',
  );
  final FlutterSignal<Uint8List?> currentImage = signal<Uint8List?>(
    null,
    debugLabel: 'Game State: Current Image',
  );
  final FlutterSignal<bool> isLoading = signal(
    false,
    debugLabel: 'Game State: Is Loading',
  );
  final FlutterSignal<bool> isImageLoading = signal(
    false,
    debugLabel: 'Game State: Image Is Loading',
  );
  final FlutterSignal<String?> error = signal<String?>(
    null,
    debugLabel: 'Game State: Error',
  );
  final ListSignal<String> history = listSignal<String>(
    [],
    debugLabel: 'Game State: Story History',
  );

  // Internal state to track the last valid image for context
  Uint8List? _lastSuccessfulImage;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('gemini_api_key');
    if (key != null && key.isNotEmpty) {
      await setApiKey(key);
    }
  }

  Future<void> setApiKey(String key) async {
    apiKey.value = key;
    _geminiService = GeminiService(key);
    _imageService = ImageService(key);

    // Save to prefs
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', key);
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
      error.value = 'API Key not set';
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
      currentImage.value = null; // Clear previous image context

      // Add to display history
      history
        ..add('Start: $initialPrompt')
        ..add(story.text);
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
      error.value = 'API Key not set';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      // Generate next segment
      final story = await _geminiService!.generateStory(choice);
      currentStory.value = story;
      currentImage.value = null; // Clear previous image context

      // Update display history
      history
        ..add('Action: $choice')
        ..add(story.text);
    } on Exception catch (e, stackTrace) {
      error.value = e.toString();
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateImageForCurrentSegment() async {
    final story = currentStory.value;
    if (story == null || _imageService == null) return;
    if (isImageLoading.value) return;

    isImageLoading.value = true;
    error.value = null;

    try {
      final image = await _imageService!.generateImage(
        storyText: story.text,
        conversationHistory: _geminiService!.chatHistory,
        previousImage: _lastSuccessfulImage,
      );
      currentImage.value = image;
      _lastSuccessfulImage = image;
    } on Exception catch (e, stackTrace) {
      debugPrint('On-demand image generation failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      error.value = 'Visual scene generation failed: $e';
      currentImage.value = null;
    } finally {
      isImageLoading.value = false;
    }
  }
}

final gameState = GameState();
