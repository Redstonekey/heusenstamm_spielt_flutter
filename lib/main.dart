
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/tournament_page.dart';
import 'screens/login_screen.dart';
import 'screens/admin_login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://xvzanzuenlcmcotzgktz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh2emFuenVlbmxjbWNvdHpna3R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIzOTg1MjEsImV4cCI6MjA2Nzk3NDUyMX0.03Fdybrs4YNTQWbPp0EqO6ZGuVwDFZGqo9ANR-dPqwE',
  );
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
      initialRoute: '/', // Add initial route
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/tournament/')) {
          final id = settings.name!.substring('/tournament/'.length);
          return MaterialPageRoute(
            builder: (context) => TournamentPage(tournamentId: id),
            settings: settings,
          );
        }
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/admin':
            return MaterialPageRoute(builder: (context) => const AdminLoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterScreen());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
