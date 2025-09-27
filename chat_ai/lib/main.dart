// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/chat_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // โหลดไฟล์ .env (ต้องอยู่ที่ root ของโปรเจกต์)
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // ถ้าโหลด .env ไม่ได้ ให้แค่ print (กันแอป crash)
    debugPrint("ไม่สามารถโหลดไฟล์ .env: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Janee AI Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const ChatScreen(),
      builder: (context, child) {
        // กันกรณีเกิด error runtime แล้วจอขาว
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Material(
            child: Center(
              child: Text(
                "⚠️ Error: ${details.exception}",
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        };
        return child!;
      },
    );
  }
}
