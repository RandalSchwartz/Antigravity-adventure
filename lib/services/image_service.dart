import 'package:flutter/foundation.dart';
import 'package:dartantic_ai/dartantic_ai.dart';

class ImageService {
  late final Agent _agent;

  ImageService(String apiKey) {
    if (apiKey.isEmpty) {
      throw Exception('API Key cannot be empty');
    }
    // Using string identifier for model as it's the most reliable way in v2.0.2
    Agent.environment['GEMINI_API_KEY'] = apiKey;
    Agent.environment['GOOGLE_API_KEY'] = apiKey;
    _agent = Agent('google:gemini-3-pro-image-preview');
  }

  Future<Uint8List> generateImage({
    required String storyText,
    required List<ChatMessage> conversationHistory,
    Uint8List? previousImage,
  }) async {
    try {
      final List<ChatMessage> history = [];

      // Add a strong system instruction to enforce image generation
      history.add(
        ChatMessage.system(
          'You are an expert image generator. '
          'Your ONLY task is to generate high-quality images based on the user description. '
          'DO NOT return text explanations or refusals unless absolutely necessary. '
          'ALWAYS prioritize generating the visual scene.',
        ),
      );

      // 1. Add conversation history as context
      // We'll take the last few messages to provide context for visual consistency
      final recentHistory = conversationHistory.length > 4
          ? conversationHistory.sublist(conversationHistory.length - 4)
          : conversationHistory;

      for (final msg in recentHistory) {
        history.add(msg);
      }

      // 2. Add previous image if available as a DataPart
      if (previousImage != null) {
        history.add(
          ChatMessage.user(
            '',
            parts: [
              DataPart(previousImage, mimeType: 'image/png'),
              const TextPart('This was the previous scene.'),
            ],
          ),
        );
      }

      // 3. Generate the new image
      final prompt = 'HIGH-QUALITY PHOTOREALISTIC IMAGE: $storyText';
      debugPrint('ImageService: Generating image with prompt: $prompt');
      debugPrint('ImageService: Context history count: ${history.length}');

      final result = await _agent.generateMedia(
        prompt,
        history: history,
        mimeTypes: ['image/png'],
      );

      debugPrint(
        'ImageService: Received response from agent. Message count: ${result.messages.length}',
      );

      // 4. Extract image bytes from the result
      // The image is expected in the last message's parts
      final assistantMsg = result.messages.last;
      debugPrint(
        'ImageService: Last message parts count: ${assistantMsg.parts.length}',
      );

      for (final part in assistantMsg.parts) {
        if (part is DataPart && part.mimeType.startsWith('image/')) {
          debugPrint(
            'ImageService: Found image data (${part.bytes.length} bytes)',
          );
          return part.bytes;
        } else if (part is TextPart) {
          debugPrint(
            'ImageService: Found text part instead of image: ${part.text}',
          );
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
