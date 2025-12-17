import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final String _apiKey;

  GeminiService(this._apiKey) {
    if (_apiKey.isEmpty) {
      throw Exception('API Key cannot be empty');
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
      systemInstruction: Content.text(
        '''You are a creative storyteller for a "Choose Your Own Adventure" game.
Generate the next segment of the story based on the user's action.
Return the response in valid JSON format with the following structure:
{
  "text": "The story text goes here...",
  "choices": [
    "Choice 1",
    "Choice 2",
    "Choice 3"
  ]
}''',
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.high),
      ],
    );
    _chat = _model.startChat();
  }

  Future<StorySegment> generateStory(String prompt) async {
    final response = await _chat.sendMessage(Content.text(prompt));

    if (response.text == null) {
      throw Exception('Failed to generate story content');
    }

    try {
      final json = jsonDecode(response.text!);
      return StorySegment.fromJson(json);
    } on Exception catch (e, stackTrace) {
      Error.throwWithStackTrace(
        Exception(
          'Failed to parse JSON response: $e\nResponse: ${response.text}',
        ),
        stackTrace,
      );
    }
  }

  // Get the full chat history for context
  List<Content> get chatHistory => _chat.history.toList();
}

class StorySegment {
  final String text;
  final List<String> choices;

  StorySegment({required this.text, required this.choices});

  factory StorySegment.fromJson(Map<String, dynamic> json) {
    return StorySegment(
      text: json['text'] as String,
      choices: (json['choices'] as List).map((e) => e as String).toList(),
    );
  }
}
