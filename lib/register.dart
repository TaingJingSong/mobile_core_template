library;

export 'dart:async';

// ── Flutter / packages ──────────────────────────────────────
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:get_it/get_it.dart';
export 'package:provider/provider.dart';
export 'package:provider/single_child_widget.dart';

// ── Providers ───────────────────────────────────────────────
export 'app_providers.dart';
export 'configs/app_configs/register.dart';
export 'configs/app_navigator_keys.dart';
// ── Config ──────────────────────────────────────────────────
export 'configs/config.dart';
// ── App Network & Data ──────────────────────────────────────
export 'configs/networks/networks.dart';
// ── App Theme & Translation ─────────────────────────────────
export 'configs/theme/theme.dart';
export 'configs/translation/app_translation_key.dart';
// ── Core (Base, Mixins, Network, Errors, Routing, Theme, Translation, Widgets)
export 'core/core.dart';
// ── Core DI ─────────────────────────────────────────────────
export 'core/di/locator.dart';
export 'core/di/register_app.dart';
export 'core/di/register_core.dart';
export 'data/data.dart';
export 'data/singletons/global_overlay.dart';
export 'data/singletons/user_singleton.dart';
// ── Routes & Widgets ────────────────────────────────────────
export 'routes/routes.dart';
export 'widgets/widget.dart';
