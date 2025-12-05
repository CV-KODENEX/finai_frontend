import 'package:finai_frontend/app/domain/entities/constant.dart';
import 'package:finai_frontend/app/domain/entities/global.dart';
import 'package:finai_frontend/app/presentation/pages/splash/splash_screen_page.dart';
import 'package:finai_frontend/core/services/injection.dart';
import 'package:finai_frontend/core/style/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';

import 'package:finai_frontend/core/util/preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Preferences.getKey();
  configureDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Constant.appName,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      navigatorKey: getIt<Global>().navigatorKey,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [NavigationHistoryObserver()],
      routes: {
        '/': (context) => const SplashScreenPage(),
      },
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) {
                return child ?? const Scaffold();
              },
            ),
          ],
        );
      },
    );
  }
}
