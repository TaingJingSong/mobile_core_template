import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../di/locator.dart';
import '../network/network_info.dart';
import '../mixins/network_aware_mixin.dart';
import '../mixins/loading_controller_mixin.dart';
import 'base_view_model.dart';
import 'loader_binding.dart';
import 'toast_binding.dart';

enum CoreViewMode { reactive, stateless, selective }

typedef CoreViewBuilder<T> = Widget Function(BuildContext context, T model, Widget? child);

typedef CoreViewErrorBuilder = Widget Function(BuildContext context, Object error, StackTrace? stackTrace);

/// ════════════════════════════════════════════════════════════
/// CORE VIEW
/// ════════════════════════════════════════════════════════════
/// Presentation wrapper for a [CoreViewModel]. It:
///   - Creates the ChangeNotifierProvider for you
///   - Wires the loader, toast, and network bindings
///   - Handles dispose, model replacement, and hot reload
///   - Provides an optional error boundary
///
/// It does NOT know about app-specific colors, translations, or
/// snackbars. Those come through the bindings.
class CoreView<T extends ChangeNotifier> extends StatefulWidget {
  final CoreViewMode mode;
  final CoreViewBuilder<T> builder;
  final T model;
  final Widget? child;

  final void Function(T model)? onModelReady;
  final void Function(T model)? onDispose;
  final void Function(T model)? onClose;
  final void Function(T oldModel, T newModel)? onModelChanged;

  final bool shareState;
  final bool autoReloadOnReconnect;
  final NetworkInfo? networkInfo;

  final CoreViewErrorBuilder? errorBuilder;
  final Object? Function(T model)? selectorValue;

  const CoreView({
    super.key,
    this.mode = CoreViewMode.reactive,
    required this.builder,
    required this.model,
    this.child,
    this.onModelReady,
    this.onDispose,
    this.onClose,
    this.onModelChanged,
    this.shareState = false,
    this.autoReloadOnReconnect = false,
    this.networkInfo,
    this.errorBuilder,
    this.selectorValue,
  }) : assert(!autoReloadOnReconnect || networkInfo != null, 'autoReloadOnReconnect = true requires a non-null networkInfo.'),
       assert(selectorValue == null || mode == CoreViewMode.selective, 'selectorValue is only supported with CoreViewMode.selective.');

  const CoreView.stateless({Key? key, required CoreViewBuilder<T> builder, required T model, void Function(T)? onModelReady, void Function(T)? onDispose, void Function(T)? onClose, CoreViewErrorBuilder? errorBuilder})
    : this(key: key, mode: CoreViewMode.stateless, builder: builder, model: model, onModelReady: onModelReady, onDispose: onDispose, onClose: onClose, errorBuilder: errorBuilder);

  const CoreView.selective({
    Key? key,
    required CoreViewBuilder<T> builder,
    required T model,
    Widget? child,
    void Function(T)? onModelReady,
    void Function(T)? onDispose,
    void Function(T)? onClose,
    void Function(T, T)? onModelChanged,
    Object? Function(T)? selectorValue,
    CoreViewErrorBuilder? errorBuilder,
  }) : this(key: key, mode: CoreViewMode.selective, builder: builder, model: model, child: child, onModelReady: onModelReady, onDispose: onDispose, onClose: onClose, onModelChanged: onModelChanged, selectorValue: selectorValue, errorBuilder: errorBuilder);

  @override
  State<CoreView<T>> createState() => _CoreViewState<T>();
}

class _CoreViewState<T extends ChangeNotifier> extends State<CoreView<T>> {
  late T _model;
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    _model = widget.model;
    _initModel(_model);
  }

  @override
  void didUpdateWidget(covariant CoreView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      final oldModel = _model;
      _teardownModel(oldModel);
      _model = widget.model;
      _initModel(_model);
      widget.onModelChanged?.call(oldModel, _model);
    }
  }

  @override
  void dispose() {
    widget.onClose?.call(_model);
    _teardownModel(_model);
    super.dispose();
  }

  void _initModel(T model) {
    try {
      // Network binding
      if (model is NetworkAwareMixin && widget.networkInfo != null) {
        model.setupNetwork(networkInfo: widget.networkInfo!, autoReloadOnReconnect: widget.autoReloadOnReconnect);
      }

      // Loader binding — pulls from DI, no GlobalOverlay reference
      if (model is LoadingControllerMixin) {
        model.bindLoader(locator<LoaderBinding>());
      }

      // Init hook
      if (model is CoreViewModel) {
        (model as CoreViewModel).initModel();
      }

      widget.onModelReady?.call(model);
    } catch (e, st) {
      if (widget.errorBuilder != null) {
        setState(() {
          _error = e;
          _stackTrace = st;
        });
      } else {
        rethrow;
      }
    }
  }

  void _teardownModel(T model) {
    if (!widget.shareState) {
      widget.onDispose?.call(model);
      if (model is NetworkAwareMixin) {
        model.onNetworkDispose();
      }
      model.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error!, _stackTrace);
    }

    // Attach toast binding once per screen — replaces AppSnackBar.fToast.init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      locator<ToastBinding>().attach(context);
    });

    final content = _buildContent();
    if (widget.shareState) return content;

    return ChangeNotifierProvider<T>.value(value: _model, child: content);
  }

  Widget _buildContent() {
    switch (widget.mode) {
      case CoreViewMode.stateless:
        return Builder(builder: (ctx) => widget.builder(ctx, _model, widget.child));

      case CoreViewMode.selective:
        if (widget.selectorValue != null) {
          return Selector<T, Object?>(selector: (_, m) => widget.selectorValue!(m), builder: (ctx, _, child) => widget.builder(ctx, _model, child), child: widget.child);
        }
        return Builder(builder: (ctx) => widget.builder(ctx, _model, widget.child));

      case CoreViewMode.reactive:
        return Consumer<T>(builder: widget.builder, child: widget.child);
    }
  }
}
