import 'package:flutter/material.dart';

/// Reusable elevated / outlined button with loading indicator support.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final Widget? icon;

  const AppButton({super.key, required this.text, required this.onPressed, this.isLoading = false, this.isOutlined = false, this.width = double.infinity, this.height = 48.0, this.icon});

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(text),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: isOutlined ? OutlinedButton(onPressed: isLoading ? null : onPressed, child: child) : ElevatedButton(onPressed: isLoading ? null : onPressed, child: child),
    );
  }
}
