import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  runApp(
    const ProviderScope(
      child: AnkaRotaApp(),
    ),
  );
}

class AnkaRotaApp extends StatelessWidget {
  const AnkaRotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnkaRota',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const HomePage(),
    );
  }
}