import 'package:flutter/material.dart';

/// Reusable progress indicator with optional text message.
class LoadingWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const LoadingWidget({
    super.key,
    this.size = 24.0,
    this.color,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: color != null
                  ? AlwaysStoppedAnimation<Color>(color!)
                  : null,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}
