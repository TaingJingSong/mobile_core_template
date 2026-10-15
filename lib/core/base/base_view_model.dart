import 'package:flutter/foundation.dart';

import '../mixins/auto_dispose_mixin.dart';
import '../mixins/loading_controller_mixin.dart';

/// ════════════════════════════════════════════════════════════
/// CORE VIEW MODEL
/// ════════════════════════════════════════════════════════════
/// Base class for every view model in the app.
///
/// - Backed by [ChangeNotifier] (this template uses Provider).
/// - Mixes in [LoadingControllerMixin] for busy/loader control.
/// - Mixes in [AutoDisposeMixin] for safe notifyListeners after dispose.
///
/// It knows NOTHING about:
///   - GlobalOverlay (loader comes from [bindLoader])
///   - App colors / translations / toasts
///   - Any app-specific singleton
///
/// If you need to make the template use Bloc or Riverpod later,
/// this is the only class you replace.
abstract class CoreViewModel extends ChangeNotifier with LoadingControllerMixin, AutoDisposeMixin {
  bool _initialized = false;
  bool get isInit => _initialized;

  @override
  void notifyListeners() {
    if (isDisposed) return;
    super.notifyListeners();
  }

  /// Called once by [CoreView] after the view is mounted.
  /// Override for light setup only — no network, no heavy work.
  @mustCallSuper
  void initModel() {
    _initialized = true;
  }

  /// Called once before dispose. Do cleanup here.
  @mustCallSuper
  void onDispose() {}

  @override
  void dispose() {
    if (!isDisposed) {
      onDispose();
    }
    super.dispose();
  }
}
