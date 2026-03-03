import 'package:flutter/material.dart';
import 'package:meteo_app/providers/meteo_provider.dart';
import 'package:meteo_app/providers/theme_provider.dart';
import 'package:meteo_app/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MeteoProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: 'MétéoVision',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.theme,
      home: const HomeScreen(),
    );
  }
}

