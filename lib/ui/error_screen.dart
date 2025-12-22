import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({required this.error, super.key, this.onRetry});
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.red.shade900,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                error.toString(),
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.red.shade800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (onRetry != null)
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Restart App'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
