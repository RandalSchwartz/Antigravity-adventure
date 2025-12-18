import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../state/game_signals.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final _customInputController = TextEditingController();

  @override
  void dispose() {
    _customInputController.dispose();
    super.dispose();
  }

  void _handleChoice(String choice) {
    gameState.makeChoice(choice);
    _customInputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final story = gameState.currentStory.watch(context);
    final image = gameState.currentImage.watch(context);
    final isLoading = gameState.isLoading.watch(context);
    final isImageLoading = gameState.isImageLoading.watch(context);
    final error = gameState.error.watch(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adventure'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: isLoading && story == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (image != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(
                                backgroundColor: Colors.black,
                                iconTheme: const IconThemeData(
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.black,
                              body: CallbackShortcuts(
                                bindings: {
                                  const SingleActivator(
                                    LogicalKeyboardKey.escape,
                                  ): () {
                                    Navigator.of(context).pop();
                                  },
                                },
                                child: Focus(
                                  autofocus: true,
                                  child: InteractiveViewer(
                                    child: Center(child: Image.memory(image)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: Opacity(
                        opacity: isLoading ? 0.5 : 1.0,
                        child: Image.memory(
                          image,
                          fit: BoxFit.contain,
                          height: 300,
                          width: double.infinity,
                        ),
                      ),
                    )
                  else if (isImageLoading)
                    const SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Generating visual scene...'),
                          ],
                        ),
                      ),
                    )
                  else if (story != null)
                    Container(
                      height: 300,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () =>
                                    gameState.generateImageForCurrentSegment(),
                          icon: const Icon(Icons.image),
                          label: const Text('Visualize this scene'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (error != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.red.shade100,
                            child: Text(
                              error,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        if (story != null) ...[
                          MarkdownBody(
                            data: story.text,
                            styleSheet: MarkdownStyleSheet(
                              p: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'What do you do?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...story.choices.map(
                            (choice) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  alignment: Alignment.centerLeft,
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () => _handleChoice(choice),
                                child: Text(
                                  choice,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                          const Divider(height: 32),
                          const Text('Or try something else:'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _customInputController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Type your own action...',
                                  ),
                                  onSubmitted: (value) {
                                    if (value.isNotEmpty && !isLoading) {
                                      _handleChoice(value);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_customInputController
                                            .text
                                            .isNotEmpty) {
                                          _handleChoice(
                                            _customInputController.text,
                                          );
                                        }
                                      },
                                icon: const Icon(Icons.send),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
