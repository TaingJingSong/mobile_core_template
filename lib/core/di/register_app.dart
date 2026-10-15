import 'package:app_base/register.dart';

/// ════════════════════════════════════════════════════════════
/// APP REGISTRATIONS — EDIT PER PROJECT
/// ════════════════════════════════════════════════════════════
Future<void> registerApp() async {
  // ── Bindings (Step 2) ───────────────────────────────────
  locator.registerLazySingleton<LoaderBinding>(() => GlobalOverlayLoaderBinding());
  locator.registerLazySingleton<ToastBinding>(() => AppToastBinding());
  locator.registerLazySingleton<LoggerBinding>(() => LoggerBindingImpl());

  // ── Network (Step 3) ────────────────────────────────────
  locator.registerLazySingleton<HttpConfig>(() => const HttpConfigImpl());
  locator.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  locator.registerLazySingleton<HeaderProvider>(() => HeaderProviderImpl());
  locator.registerLazySingleton<InterceptorProvider>(() => InterceptorProviderImpl());
  locator.registerLazySingleton<BaseApiService>(
    () => NetworkApiService(
      httpConfig: locator<HttpConfig>(),
      headerProvider: locator<HeaderProvider>(),
      interceptorProvider: locator<InterceptorProvider>(),
      logger: locator<LoggerBinding>(),
      loader: locator<LoaderBinding>(),
    ),
  );

  // ── Theme Repository (Step 5) ──────────────────────────
  locator.registerLazySingleton<ThemeRepository>(() => ThemeRepositoryImpl());

  // ── Repositories (Step 4) ───────────────────────────────
  // Register repositories lazily:
  // locator.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // ── Feature APIs ────────────────────────────────────────
  // locator.registerLazySingleton(() => AuthApi(locator<BaseApiService>()));

  // ── App services ────────────────────────────────────────
  locator.registerLazySingleton<DeepLinkService>(() => DeepLinkServiceImpl());

  // ── View models are NOT registered here ─────────────────
  // Create them per-screen via CoreView:
  //
  //   CoreView<LoginViewModel>(
  //     model: LoginViewModel(loginRepo: locator<LoginRepository>()),
  //     builder: (context, vm, _) => ...,
  //   )
  //
  // Or, if you want DI to build them:
  //
  //   locator.registerFactory(() => LoginViewModel(
  //     loginRepo: locator<LoginRepository>(),
  //   ));
  //
  // ...then: model: locator<LoginViewModel>()
}
