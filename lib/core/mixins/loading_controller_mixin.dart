import 'package:flutter/foundation.dart';

import '../base/loader_binding.dart';

mixin LoadingControllerMixin on ChangeNotifier {
  LoaderBinding? _loader;
  bool _busy = false;

  bool get busy => _busy;

  /// Called by [CoreView] once, after the view is mounted.
  /// The app is responsible for providing the [LoaderBinding].
  void bindLoader(LoaderBinding loader) {
    _loader = loader;
  }

  void setBusy(bool value, {bool useOverlayLoader = false}) {
    if (_busy == value) return;
    _busy = value;
    notifyListeners();

    if (useOverlayLoader) {
      value ? showLoader() : hideLoader();
    }
  }

  void showLoader({String? text}) => _loader?.show(text: text);
  void hideLoader() => _loader?.hide();
  void setLoadingText(String? text) => _loader?.setText(text);
}
