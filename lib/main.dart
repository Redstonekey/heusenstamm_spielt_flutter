import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HeusenstammSpieltApp());
}

class HeusenstammSpieltApp extends StatelessWidget {
  const HeusenstammSpieltApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heusenstamm spielt',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF1976D2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          brightness: Brightness.light,
          
          primary: const Color(0xFF1976D2),
          secondary: const Color(0xFFFF6B35),
          surface: const Color(0xFFFAFAFA),
        ),
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 8,
            shadowColor: const Color(0xFF1976D2).withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: false,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
