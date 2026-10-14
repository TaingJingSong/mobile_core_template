import 'package:app_base/register.dart';

/// Root application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        navigatorKey: AppRouter.navigatorKey,
        navigatorObservers: [AppRouter.observer],
        initialRoute: Routes.initial,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) {
          return Overlay(
            initialEntries: [
              OverlayEntry(
                builder: (_) => OverlayPortal(
                  controller: GlobalOverlay.instance.controller,
                  overlayChildBuilder: (_) => const GlobalOverlayWidget(),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
