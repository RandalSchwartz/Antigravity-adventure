import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'state/game_signals.dart';
import 'ui/api_key_screen.dart';
import 'ui/error_screen.dart';
import 'ui/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // Here you would typically report to Crashlytics
  };

  // Catch async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Async Error: $error');
    // Report to Crashlytics
    return true;
  };

  // Initialize game state
  try {
    await gameState.init();
  } catch (e) {
    debugPrint('Failed to initialize game state: $e');
  }

  runApp(const AdventureApp());
}

class AdventureApp extends StatelessWidget {
  const AdventureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Adventure',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark, // Dark mode fits the vibe better
        ),
        useMaterial3: true,
      ),
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return ErrorScreen(
            error: details.exception,
            onRetry: () {
              // Simple restart by re-running main (in a real app, use a proper restart mechanism)
              main();
            },
          );
        };
        return child!;
      },
      home: Watch((context) {
        if (gameState.apiKey.value == null) {
          return const ApiKeyScreen();
        }
        return const StartScreen();
      }),
    );
  }
}
