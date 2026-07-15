import 'package:flutter/material.dart';
import 'home_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  //ThemeMode für Dark/Light-Mode
  ThemeMode _themeMode = ThemeMode.light;

  void _toogleTheme() {
      // SetState informiert Flutter, dass sich der Zustand geändert hat und
    // neu gerendert werden soll, ohne SetState würde sich das Thema ändern, 
    // aber nicht angezeigt werden
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asteroiden-Tracker',
      themeMode: _themeMode,
// Ersetze diese Abschnitte in deiner main_app.dart (MainApp)
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF28965A),
        brightness: Brightness.light,
        surface: const Color(0xFFF3F6F9), // Kühles, helles Grau
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent, // Nutzt die Hintergrundfarbe
        scrolledUnderElevation: 2,
      ),
    ),
    darkTheme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF28965A),
        brightness: Brightness.dark,
        surface: const Color(0xFF0B141A), // Extrem dunkles Space-Blau/Grau
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 2,
      ),
    ),
      home: HomePage(
        onToggleTheme: _toogleTheme,
        isDark: _themeMode == ThemeMode.dark,
      ),
    );

  }
}
