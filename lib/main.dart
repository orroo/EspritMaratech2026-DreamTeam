import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/app_shell.dart';

void main() {
  runApp(const RctApp());
}

class RctApp extends StatefulWidget {
  const RctApp({super.key});

  @override
  State<RctApp> createState() => _RctAppState();
}

class _RctAppState extends State<RctApp> {
  ThemeMode _mode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _mode = (_mode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.interTextTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RCT',
      theme: AppTheme.light(textTheme),
      darkTheme: AppTheme.dark(textTheme),
      themeMode: _mode,

      home: Builder(
        builder: (context) => SplashScreen(
          // Continue as guest -> News (blog)
          onGetStarted: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AppShell(
                  onToggleTheme: toggleTheme,
                  isGuest: true,
                ),
              ),
            );
          },

          // Login -> LoginScreen
          onLogin: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LoginScreen(onToggleTheme: toggleTheme),
              ),
            );
          },
        ),
      ),
    );
  }
}
