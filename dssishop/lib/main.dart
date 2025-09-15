// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/home.dart';

const kPinkSeed = Color(0xFFF48FB1);
const kRoseBg   = Color(0xFFFFEBEE);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSSI SHOP By Janenie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kPinkSeed),
        scaffoldBackgroundColor: kRoseBg,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      // ✅ ต้องอยู่นอก theme
      home: const HomePage(),
    );
  }
}
