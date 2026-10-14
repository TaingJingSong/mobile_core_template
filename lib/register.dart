/// ════════════════════════════════════════════════════════════
/// REGISTER — the single import barrel
/// ════════════════════════════════════════════════════════════
/// Every file in the app imports this file, nothing else.
library;

import 'package:flutter/widgets.dart';
import 'core/di/register_core.dart';
import 'core/di/register_app.dart';

// ── Flutter / packages ──────────────────────────────────────
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:provider/provider.dart';
export 'package:get_it/get_it.dart';
export 'dart:async';

// ── Core DI ─────────────────────────────────────────────────
export 'core/di/locator.dart';
export 'core/di/register_core.dart';
export 'core/di/register_app.dart';

// ── Config ──────────────────────────────────────────────────
export 'configs/config.dart';
export 'configs/app_configs/register.dart';

// ── Core base classes ───────────────────────────────────────
export 'core/base/base_view_model.dart';
export 'core/base/base_view.dart';
export 'core/base/loader_binding.dart';
export 'core/base/logger_binding.dart';
export 'core/base/toast_binding.dart';

// ── Core mixins ─────────────────────────────────────────────
export 'core/mixins/loading_controller_mixin.dart';
export 'core/mixins/auto_dispose_mixin.dart';
export 'core/mixins/network_aware_mixin.dart';

// ── Core network ────────────────────────────────────────────
export 'core/network/api_service.dart';
export 'core/network/core_api_base.dart';
export 'core/network/network_info.dart';
export 'core/network/http_config.dart';
export 'core/network/header_provider.dart';
export 'core/network/interceptor_provider.dart';

// ── Core errors ─────────────────────────────────────────────
export 'core/errors/failure.dart';
export 'core/errors/exceptions.dart';
export 'core/errors/error_handler.dart';

// ── App network impls ───────────────────────────────────────
export 'configs/networks/networks.dart';

// ── Data ────────────────────────────────────────────────────
export 'data/data.dart';
export 'data/singletons/global_overlay.dart';
export 'data/singletons/user_singleton.dart';

// ── Routes ──────────────────────────────────────────────────
export 'routes/routes.dart';

// ── Widgets ─────────────────────────────────────────────────
export 'widgets/widget.dart';

// ── Bootstrap ───────────────────────────────────────────────
/// Called from every main_*.dart.
/// Keep this dumb: no app logic here, only wiring.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await registerCore();
  await registerApp();
}