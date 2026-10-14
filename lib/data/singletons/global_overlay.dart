import 'package:flutter/material.dart';

enum OverlayType { none, loading, connectionLost }

class GlobalOverlay {
  GlobalOverlay._internal();
  static final GlobalOverlay instance = GlobalOverlay._internal();

  final OverlayPortalController controller = OverlayPortalController();
  final ValueNotifier<Widget?> child = ValueNotifier(null);
  final ValueNotifier<OverlayType> activeType = ValueNotifier(OverlayType.none);

  void showLoader({String? text, Widget? child}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (child != null) {
        this.child.value = child;
      } else if (text != null) {
        this.child.value = Text(text, style: const TextStyle(fontSize: 16, color: Colors.white));
      } else {
        this.child.value = null;
      }
      activeType.value = OverlayType.loading;
      if (!controller.isShowing) {
        controller.show();
      }
    });
  }

  void hideLoader() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (activeType.value == OverlayType.loading) {
        activeType.value = OverlayType.none;
      }
    });
  }

  void setLoadingText(String? text) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (activeType.value == OverlayType.loading) {
        child.value = text != null ? Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)) : null;
      }
    });
  }
}

class GlobalOverlayWidget extends StatefulWidget {
  const GlobalOverlayWidget({super.key});

  @override
  State<GlobalOverlayWidget> createState() => _GlobalOverlayWidgetState();
}

class _GlobalOverlayWidgetState extends State<GlobalOverlayWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  static const showDuration = Duration(milliseconds: 300);
  static const hideDuration = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: showDuration, reverseDuration: hideDuration);

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut, reverseCurve: Curves.easeIn);

    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutBack, reverseCurve: Curves.easeInCubic));

    GlobalOverlay.instance.activeType.addListener(_onActiveTypeChanged);

    if (GlobalOverlay.instance.activeType.value != OverlayType.none) {
      _animController.forward(from: 0.0);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && GlobalOverlay.instance.activeType.value == OverlayType.none && GlobalOverlay.instance.controller.isShowing) {
          GlobalOverlay.instance.controller.hide();
          GlobalOverlay.instance.child.value = null;
        }
      });
    }
  }

  void _onActiveTypeChanged() {
    if (!mounted) return;
    if (GlobalOverlay.instance.activeType.value != OverlayType.none) {
      _animController.forward();
    } else {
      _animController.reverse().then((_) {
        if (mounted && GlobalOverlay.instance.activeType.value == OverlayType.none && GlobalOverlay.instance.controller.isShowing) {
          GlobalOverlay.instance.controller.hide();
          GlobalOverlay.instance.child.value = null;
        }
      });
    }
  }

  @override
  void dispose() {
    GlobalOverlay.instance.activeType.removeListener(_onActiveTypeChanged);
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<OverlayType>(
      valueListenable: GlobalOverlay.instance.activeType,
      builder: (context, type, child) {
        return IgnorePointer(
          ignoring: type == OverlayType.none,
          child: RepaintBoundary(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: ValueListenableBuilder<Widget?>(
                      valueListenable: GlobalOverlay.instance.child,
                      builder: (context, childWidget, _) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const IgnorePointer(child: CircularProgressIndicator(strokeWidth: 4)),
                            if (childWidget != null) ...[
                              const SizedBox(height: 16),
                              DefaultTextStyle(
                                style: const TextStyle(color: Colors.white),
                                child: Material(color: Colors.transparent, child: childWidget),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
