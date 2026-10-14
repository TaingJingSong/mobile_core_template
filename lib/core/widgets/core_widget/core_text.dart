import 'package:flutter/material.dart';

/// Framework text widget using Theme.of(context).
class CoreText extends StatelessWidget {
  const CoreText(this.text, {super.key, this.style});
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: style ?? Theme.of(context).textTheme.bodyMedium);
  }
}
