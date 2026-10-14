import 'package:flutter/material.dart';

/// ════════════════════════════════════════════════════════════
/// TOAST BINDING
/// ════════════════════════════════════════════════════════════
/// CoreView calls [attach] once per screen so the app can wire
/// its global toast/snackbar system to the current context.
abstract interface class ToastBinding {
  /// Called once per screen build with a fresh [BuildContext].
  /// Implementations typically re-init an FToast or similar.
  void attach(BuildContext context);

  void show(String message);
  void error(String message);
  void success(String message);
}