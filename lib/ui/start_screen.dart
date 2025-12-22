import 'dart:async';

import 'package:cyoa_game/state/game_signals.dart';
import 'package:cyoa_game/ui/story_screen.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startGame() async {
    if (_controller.text.trim().isEmpty) return;

    await gameState.startGame(_controller.text.trim());
    if (mounted) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const StoryScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = gameState.isLoading.watch(context);
    final error = gameState.error.watch(context);

    // Listen for error to show snackbar
    // We can use a reaction or just check in build if we want simple handling
    // But for navigation/snackbars, a listener in initState or a Watch is better.
    // Here we just show it in the UI for simplicity.

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Adventure'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              unawaited(
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Settings'),
                    content: const Text('Do you want to reset your API Key?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          unawaited(gameState.clearApiKey());
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Reset Key',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Choose Your Own Adventure',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter a theme, setting, or starting scenario to begin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Starting Scenario',
                  hintText: 'e.g., A cyberpunk detective in Neo-Tokyo...',
                ),
                maxLines: 3,
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _startGame(),
              ),
              const SizedBox(height: 24),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _startGame,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Begin Adventure'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
