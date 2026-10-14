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
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, _) {
          return MaterialApp(
            title: AppConfig.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeVM.theme,
            navigatorKey: AppRouter.navigatorKey,
            navigatorObservers: [AppRouter.observer],
            initialRoute: Routes.initial,
            onGenerateRoute: AppRouter.onGenerateRoute,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: MediaQuery.of(context).textScaler.clamp(
                  minScaleFactor: 0.7,
                  maxScaleFactor: 1.4,
                ),
              ),
              child: _AppBuilder(child: child),
            ),
          );
        },
      ),
    );
  }
}

class _AppBuilder extends StatefulWidget {
  const _AppBuilder({required this.child});
  final Widget? child;

  @override
  State<_AppBuilder> createState() => _AppBuilderState();
}

class _AppBuilderState extends State<_AppBuilder> {
  late final DeepLinkService _deepLink = locator<DeepLinkService>();

  @override
  void initState() {
    super.initState();
    _deepLink.initialize();
  }

  @override
  void dispose() {
    _deepLink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (_) => OverlayPortal(
            controller: GlobalOverlay.instance.controller,
            overlayChildBuilder: (_) => const GlobalOverlayWidget(),
            child: widget.child ?? const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
