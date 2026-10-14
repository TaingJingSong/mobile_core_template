/// ════════════════════════════════════════════════════════════
/// LOADER BINDING
/// ════════════════════════════════════════════════════════════
/// The contract for "show/hide a global loading overlay."
/// The app provides the implementation (e.g. GlobalOverlay) in
/// registerCore(). The core layer only knows this interface.
abstract interface class LoaderBinding {
  void show({String? text});
  void hide();
  void setText(String? text);
}
