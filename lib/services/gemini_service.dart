import 'package:dartantic_ai/dartantic_ai.dart';
import 'package:json_schema/json_schema.dart';

class GeminiService {
  GeminiService(String apiKey) {
    if (apiKey.isEmpty) {
      throw Exception('API Key cannot be empty');
    }
    // Set API key in environment for the agent to find
    // Using both names for maximum compatibility
    Agent.environment['GEMINI_API_KEY'] = apiKey;
    Agent.environment['GOOGLE_API_KEY'] = apiKey;

    // Use the model name with 'google:' prefix as recommended for v2.0.2
    _agent = Agent('google:gemini-3-flash-preview');

    _history.add(
      ChatMessage.system(
        '''
You are a creative storyteller for a "Choose Your Own Adventure" game.
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
    );
  }
  late final Agent _agent;
  final List<ChatMessage> _history = [];

  Future<StorySegment> generateStory(String prompt) async {
    final result = await _agent.sendFor<StorySegment>(
      prompt,
      history: _history,
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

    _history.addAll(result.messages);
    return result.output;
  }

  // Get the full chat history for context
  List<ChatMessage> get chatHistory => _history;
}

class StorySegment {
  StorySegment({required this.text, required this.choices});

  factory StorySegment.fromJson(Map<String, dynamic> json) {
    return StorySegment(
      text: json['text'] as String,
      choices: (json['choices'] as List).map((e) => e as String).toList(),
    );
  }
  final String text;
  final List<String> choices;
}
