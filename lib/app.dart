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
      theme: ThemeData( // Helles Design
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF28965A),
          brightness: Brightness.light
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0, //kein Schatten
          scrolledUnderElevation: 3, // leichter Schatten/Farbton beim Scrollen
          centerTitle: false,
        )
      ),
      darkTheme: ThemeData( // Dunkles Design
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF28965A),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0, //kein Schatten
          scrolledUnderElevation: 3, // leichter Schatten/Farbton beim Scrollen
          centerTitle: false,
        )
      ),
      home: HomePage(
        onToggleTheme: _toogleTheme,
        isDark: _themeMode == ThemeMode.dark,
      ),
    );

  }
}
