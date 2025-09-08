// MyHomePage.dart
import 'package:flutter/material.dart';
import 'package:myapp/page/detail.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const heroTag = 'logo-hero';
  int _counter = 0;

  void _incrementCounter() {
    setState(() { _counter++; });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Detail()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text('$_counter', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        // ใช้ Hero ของ FAB เอง (อย่าห่อ Hero ซ้ำด้านใน)
        heroTag: heroTag,
        child: ClipOval(
          child: Image.asset(
            'images/logo.jpg',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
