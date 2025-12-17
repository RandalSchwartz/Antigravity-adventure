import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:google_generative_ai/google_generative_ai.dart';

class ImageService {
  final String _apiKey;
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-image:generateContent';

  ImageService(this._apiKey) {
    if (_apiKey.isEmpty) {
      throw Exception('API Key cannot be empty');
    }
  }

  Future<Uint8List> generateImage({
    required String storyText,
    required List<Content> conversationHistory,
    Uint8List? previousImage,
  }) async {
    final url = Uri.parse('$_baseUrl?key=$_apiKey');

    // Build the prompt parts
    final parts = <Map<String, dynamic>>[];

    // 1. Add conversation history as text context
    // We'll take the last 4 messages (2 turns)
    final recentHistory = conversationHistory.length > 4
        ? conversationHistory.sublist(conversationHistory.length - 4)
        : conversationHistory;

    final contextBuffer = StringBuffer();
    contextBuffer.writeln('Story context:');
    for (final content in recentHistory) {
      for (final part in content.parts) {
        if (part is TextPart) {
          contextBuffer.writeln(part.text);
        }
      }
    }
    parts.add({'text': contextBuffer.toString()});

    // 2. Add previous image if available (Inline Data)
    if (previousImage != null) {
      parts.add({
        'inline_data': {
          'mime_type': 'image/png',
          'data': base64Encode(previousImage),
        },
      });
    }

    // 3. Add the specific image generation prompt
    parts.add({
      'text': '\nGenerate an image that depicts this scene: $storyText',
    });

    final body = {
      "contents": [
        {"parts": parts},
      ],
      "safetySettings": [
        {
          "category": "HARM_CATEGORY_HARASSMENT",
          "threshold": "BLOCK_ONLY_HIGH",
        },
        {
          "category": "HARM_CATEGORY_HATE_SPEECH",
          "threshold": "BLOCK_ONLY_HIGH",
        },
        {
          "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
          "threshold": "BLOCK_ONLY_HIGH",
        },
        {
          "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
          "threshold": "BLOCK_ONLY_HIGH",
        },
      ],
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to generate image: ${response.statusCode} ${response.body}',
        );
      }

      final json = jsonDecode(response.body);

      final candidates = json['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final candidate = candidates[0];

        // Check finish reason
        if (candidate['finishReason'] != 'STOP' &&
            candidate['finishReason'] != null) {
          throw Exception(
            'Image generation stopped. Reason: ${candidate['finishReason']}',
          );
        }

        final content = candidate['content'];
        if (content != null && content['parts'] != null) {
          final parts = content['parts'] as List;

          // Look for inline_data
          for (final part in parts) {
            if (part.containsKey('inlineData')) {
              final data = part['inlineData']['data'];
              return base64Decode(data);
            }
          }

          // If no inlineData, check for text
          final textParts = parts
              .where((p) => p.containsKey('text'))
              .map((p) => p['text'])
              .join(' ');
          throw Exception('Model returned only text: "$textParts"');
        }
      }

      throw Exception(
        'No candidates found in response. Body: ${response.body}',
      );
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        Exception('Failed to generate image: $e'),
        stackTrace,
      );
    }
  }
}
