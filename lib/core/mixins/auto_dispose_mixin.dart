import 'dart:async';
import 'package:flutter/material.dart';

mixin AutoDisposeMixin on ChangeNotifier {
  final List<Object?> _resources = <Object?>[];
  List<T> get<T>() => _resources.whereType<T>().toList();
  bool _disposed = false;

  bool get isDisposed => _disposed;

  /// Register controller or disposable object to dispose automatically
  T create<T>(T controller) {
    _resources.add(controller);
    return controller;
  }

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    for (final res in _resources) {
      try {
        if (res is ChangeNotifier) {
          res.dispose();
        } else if (res is FocusNode) {
          res.dispose();
        } else if (res is OverlayEntry) {
          res.remove();
        } else if (res is StreamSubscription<dynamic>) {
          res.cancel();
        } else if (res is Timer) {
          res.cancel();
        }
      } catch (_) {}
    }

    _disposed = true;
    _resources.clear();
    super.dispose();
  }
}
