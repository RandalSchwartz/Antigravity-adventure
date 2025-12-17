import 'package:flutter/foundation.dart';
import 'package:dartantic_ai/dartantic_ai.dart';

class ImageService {
  late final Agent _agent;

  ImageService(String apiKey) {
    if (apiKey.isEmpty) {
      throw Exception('API Key cannot be empty');
    }
    // Using documented connection string for image generation
    Agent.environment['GEMINI_API_KEY'] = apiKey;
    Agent.environment['GOOGLE_API_KEY'] = apiKey;
    _agent = Agent('google?media=gemini-3-pro-image-preview');
  }

  Future<Uint8List> generateImage({
    required String storyText,
    required List<ChatMessage> conversationHistory,
    Uint8List? previousImage,
  }) async {
    try {
      final List<ChatMessage> history = [];

      // Grounding for image generation
      history.add(
        ChatMessage.system(
          'You are an expert image generator. '
          'Generate a high-quality photorealistic image of the scene described. '
          'Do NOT return text, return ONLY the visual image.',
        ),
      );

      // 1. Add conversation history as context (limiting to useful context)
      final recentHistory = conversationHistory.length > 3
          ? conversationHistory.sublist(conversationHistory.length - 3)
          : conversationHistory;

      for (final msg in recentHistory) {
        history.add(msg);
      }

      // 2. Add previous image if available
      if (previousImage != null) {
        history.add(
          ChatMessage.user(
            '',
            parts: [
              DataPart(previousImage, mimeType: 'image/png'),
              const TextPart('Context: This was the previous scene.'),
            ],
          ),
        );
      }

      // 3. Generate the new image
      debugPrint('ImageService: Generating image with prompt: $storyText');

      final result = await _agent.generateMedia(
        storyText,
        history: history,
        mimeTypes: ['image/png'],
      );

      debugPrint(
        'ImageService: Received response. Assets count: ${result.assets.length}, Messages: ${result.messages.length}',
      );

      // 4. Extract image bytes from assets (recommended way)
      for (final asset in result.assets) {
        if (asset is DataPart && asset.mimeType.startsWith('image/')) {
          debugPrint(
            'ImageService: Found image asset (${asset.bytes.length} bytes)',
          );
          return asset.bytes;
        }
      }

      // Fallback: check parts in messages if assets list is empty
      if (result.messages.isNotEmpty) {
        for (final part in result.messages.last.parts) {
          if (part is DataPart && part.mimeType.startsWith('image/')) {
            debugPrint('ImageService: Found image in message parts');
            return part.bytes;
          } else if (part is TextPart) {
            debugPrint('ImageService: Text part in response: ${part.text}');
          }
        }
      }

      throw Exception('No image data found in the response.');
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        Exception('Failed to generate image: $e'),
        stackTrace,
      );
    }
  }
}
