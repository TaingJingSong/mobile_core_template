import 'package:app_base/register.dart';

/// ════════════════════════════════════════════════════════════
/// APP REGISTRATIONS — EDIT PER PROJECT
/// ════════════════════════════════════════════════════════════
/// Register your singletons, repositories, services, and
/// view models here. Order doesn't matter — get_it is lazy.
Future<void> registerApp() async {
  // ── Singletons ────────────────────────────────────────────
  locator.registerLazySingleton(() => UserSingleton.instance);

  // ── Bindings (Step 2) ────────────────────────────────────
  locator.registerLazySingleton<LoaderBinding>(
    () => GlobalOverlayLoaderBinding(),
  );
  locator.registerLazySingleton<ToastBinding>(
    () => AppToastBinding(),
  );
  locator.registerLazySingleton<LoggerBinding>(
    () => LoggerBindingImpl(),
  );

  // ── Network (Step 3) ─────────────────────────────────────
  locator.registerLazySingleton<HttpConfig>(() => const HttpConfigImpl());
  locator.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  locator.registerLazySingleton<HeaderProvider>(() => HeaderProviderImpl());
  locator.registerLazySingleton<InterceptorProvider>(
    () => InterceptorProviderImpl(),
  );

  locator.registerLazySingleton<BaseApiService>(
    () => NetworkApiService(
      httpConfig: locator<HttpConfig>(),
      headerProvider: locator<HeaderProvider>(),
      interceptorProvider: locator<InterceptorProvider>(),
      logger: locator<LoggerBinding>(),
      loader: locator<LoaderBinding>(),
    ),
  );

  // ── Feature Repositories & APIs (add per project) ─────────
  // locator.registerLazySingleton<LoginRepository>(
  //   () => LoginRepositoryImpl(locator<BaseApiService>()),
  // );

  // ── View models ───────────────────────────────────────────
  // Always factories — a new instance per view.
  // locator.registerFactory(() => LoginViewModel(
  //   repository: locator<LoginRepository>(),
  // ));
}