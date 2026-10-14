import 'package:flutter/material.dart';

/// Reusable error placeholder with message and optional retry callback.
class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryText;

  const AppErrorWidget({super.key, required this.message, this.onRetry, this.retryText = 'Retry'});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
            if (onRetry != null) ...[const SizedBox(height: 16), ElevatedButton(onPressed: onRetry, child: Text(retryText))],
          ],
        ),
      ),
    );
  }
}
