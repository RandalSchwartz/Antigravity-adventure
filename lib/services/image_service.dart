import 'package:flutter/foundation.dart';
import 'package:dartantic_ai/dartantic_ai.dart';

class ImageService {
  late final Agent _agent;

  ImageService(String apiKey) {
    if (apiKey.isEmpty) {
      throw Exception('API Key cannot be empty');
    }
    // Using Gemini 3 Pro Image (Nano Banana Pro) for 3.0 consistency and higher quality
    Agent.environment['GEMINI_API_KEY'] = apiKey;
    Agent.environment['GOOGLE_API_KEY'] = apiKey;
    _agent = Agent(
      'google?media=gemini-3-pro-image-preview',
      mediaModelOptions: const GoogleMediaGenerationModelOptions(
        safetySettings: [
          ChatGoogleGenerativeAISafetySetting(
            category: ChatGoogleGenerativeAISafetySettingCategory.harassment,
            threshold: ChatGoogleGenerativeAISafetySettingThreshold.blockNone,
          ),
          ChatGoogleGenerativeAISafetySetting(
            category: ChatGoogleGenerativeAISafetySettingCategory.hateSpeech,
            threshold: ChatGoogleGenerativeAISafetySettingThreshold.blockNone,
          ),
          ChatGoogleGenerativeAISafetySetting(
            category:
                ChatGoogleGenerativeAISafetySettingCategory.sexuallyExplicit,
            threshold: ChatGoogleGenerativeAISafetySettingThreshold.blockNone,
          ),
          ChatGoogleGenerativeAISafetySetting(
            category:
                ChatGoogleGenerativeAISafetySettingCategory.dangerousContent,
            threshold: ChatGoogleGenerativeAISafetySettingThreshold.blockNone,
          ),
        ],
      ),
    );
  }

  Future<Uint8List> generateImage({
    required String storyText,
    required List<ChatMessage> conversationHistory,
    Uint8List? previousImage,
  }) async {
    try {
      // 1. Prepare the prompt for visual consistency
      String prompt =
          'A high-quality photorealistic image of this scene: $storyText';
      final List<Part> attachments = [];

      if (previousImage != null) {
        prompt +=
            '. Maintain visual consistency with the provided image (character features, environment style, and lighting).';
        attachments.add(DataPart(previousImage, mimeType: 'image/png'));
        debugPrint('ImageService: Using image-to-image reference');
      }

      debugPrint('ImageService: Generating image with prompt: $prompt');

      // 2. Generate the image
      final result = await _agent.generateMedia(
        prompt,
        mimeTypes: ['image/png'],
        attachments: attachments,
      );

      debugPrint(
        'ImageService: Received response. Assets count: ${result.assets.length}, Messages: ${result.messages.length}',
      );

      // 3. Extract image bytes from assets
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
