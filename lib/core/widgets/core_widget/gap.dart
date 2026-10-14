import 'package:flutter/material.dart';

/// Lightweight spacing widget.
class Gap extends StatelessWidget {
  final double? width;
  final double? height;

  const Gap(double size, {super.key}) : width = size, height = size;

  const Gap.vertical(double size, {super.key}) : width = 0, height = size;

  const Gap.horizontal(double size, {super.key}) : width = size, height = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, height: height);
  }
}
