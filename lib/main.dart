import 'package:flutter/material.dart';
import 'homepage.dart'; // your StudentHome screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/StudentHome': (context) => StudentHome(),
        '/Dashboard': (context) => const PlaceholderScreen('Dashboard'),
        '/Logout': (context) => const PlaceholderScreen('Logout'),
        // Add other routes here...
      },
      home: StudentHome(),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Screen')),
    );
  }
}
