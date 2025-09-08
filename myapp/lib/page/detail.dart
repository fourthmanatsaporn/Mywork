// detail.dart
import 'package:flutter/material.dart';

class Detail extends StatelessWidget {
  const Detail({super.key});

  @override
  Widget build(BuildContext context) {
    const heroTag = 'logo-hero';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: Center(
        child: Hero(
          tag: heroTag,
          // ชนิดวิดเจ็ตต้อง "เหมือนกัน" กับฝั่งต้นทาง (ClipOval + Image.asset)
          child: ClipOval(
            child: Image.asset(
              'images/logo.jpg',
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.width * 0.6,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
