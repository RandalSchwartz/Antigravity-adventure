import 'dart:typed_data';
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
      final prompt = 'Generate an image that depicts this scene: $storyText';
      final result = await _agent.generateMedia(
        prompt,
        history: history,
        mimeTypes: ['image/png'],
      );

      // 4. Extract image bytes from the result
      // The image is expected in the last message's parts
      final assistantMsg = result.messages.last;
      for (final part in assistantMsg.parts) {
        if (part is DataPart && part.mimeType.startsWith('image/')) {
          return part.bytes;
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
