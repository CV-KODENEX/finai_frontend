import 'package:finai_frontend/app/presentation/pages/home/home_page.dart';
import 'package:finai_frontend/app/presentation/pages/welcome/welcome_page.dart';
import 'package:finai_frontend/core/util/navigation.dart';
import 'package:finai_frontend/core/util/preferences.dart';
import 'package:flutter/material.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  _checkLogin() async {
    bool isLoggedIn = await Prefs.getIsLoggedIn;
    if (isLoggedIn) {
      navigateOffAll(const HomePage());
    } else {
      navigateOffAll(const WelcomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Hello Kodenox',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
