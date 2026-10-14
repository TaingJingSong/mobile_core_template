// lib/configs/app_configs/bindings/loader_binding_impl.dart
import 'package:app_base/register.dart';

class GlobalOverlayLoaderBinding implements LoaderBinding {
  @override
  void show({String? text}) => GlobalOverlay.instance.showLoader(text: text);
  @override
  void hide() => GlobalOverlay.instance.hideLoader();
  @override
  void setText(String? text) => GlobalOverlay.instance.setLoadingText(text);
}
