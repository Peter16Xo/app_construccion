import 'package:flutter/material.dart';
import 'login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Construcción',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, 
        scaffoldBackgroundColor: const Color(0xFFFFFBE6), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: const Color(0xFF5D4037), // marrón oscuro
          secondary: const Color(0xFFFF7043), // naranja brillante
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      home: const LoginScreen(), 
    );
  }
}
