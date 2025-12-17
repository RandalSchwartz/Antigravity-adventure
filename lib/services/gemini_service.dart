import 'package:dartantic_ai/dartantic_ai.dart';

class GeminiService {
  late final Agent _agent;
  final String _apiKey;

  GeminiService(this._apiKey) {
    if (_apiKey.isEmpty) {
      throw Exception('API Key cannot be empty');
    }
    _agent = Agent(
      'gemini-2.5-flash',
      apiKey: _apiKey,
      systemPrompt:
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
    );
  }

  Future<StorySegment> generateStory(String prompt) async {
    final result = await _agent.sendFor<StorySegment>(
      prompt,
      outputSchema: JsonSchema.create({
        'type': 'object',
        'properties': {
          'text': {'type': 'string'},
          'choices': {
            'type': 'array',
            'items': {'type': 'string'},
          },
        },
        'required': ['text', 'choices'],
      }),
      outputFromJson: StorySegment.fromJson,
    );

    return result.output;
  }

  // Get the full chat history for context
  List<ChatMessage> get chatHistory => _agent.history;
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
