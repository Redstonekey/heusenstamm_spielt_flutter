import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/hero_section.dart';
import '../widgets/about_section.dart';
import '../widgets/game_of_month_section.dart';
import '../widgets/tournament_list_section.dart';
import '../widgets/calendar_section.dart';
import '../widgets/footer_section.dart';
import 'image_test_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeController;
  bool _isScrolled = false;

  // GlobalKeys for each section
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _gameOfMonthKey = GlobalKey();
  final GlobalKey _tournamentKey = GlobalKey();
  final GlobalKey _calendarKey = GlobalKey();
  final GlobalKey _footerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_isScrolled) {
        setState(() {
          _isScrolled = true;
        });
        _fadeController.forward();
      } else if (_scrollController.offset <= 100 && _isScrolled) {
        setState(() {
          _isScrolled = false;
        });
        _fadeController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: _isScrolled ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ] : [],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Hero(
                    tag: 'logo',
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.casino,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Heusenstamm spielt',
                      style: GoogleFonts.roboto(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 768) ...[
                    _buildNavButton('Home', 0),
                    _buildNavButton('Über uns', 1),
                    _buildNavButton('Spiel des Monats', 2),
                    _buildNavButton('Turniere', 3),
                    _buildNavButton('Termine', 4),
                    _buildNavButton('Kontakt', 5),
                  ] else ...[
                    PopupMenuButton<int>(
                      icon: const Icon(Icons.menu, color: Colors.black87),
                      onSelected: _scrollToSection,
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 0, child: Text('Home')),
                        const PopupMenuItem(value: 1, child: Text('Über uns')),
                        const PopupMenuItem(value: 2, child: Text('Spiel des Monats')),
                        const PopupMenuItem(value: 3, child: Text('Turniere')),
                        const PopupMenuItem(value: 4, child: Text('Termine')),
                        const PopupMenuItem(value: 5, child: Text('Kontakt')),
                        const PopupMenuItem(value: 6, child: Text('🧪 Image Test')),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            HeroSection(key: _heroKey),
            AboutSection(key: _aboutKey),
            GameOfMonthSection(key: _gameOfMonthKey),
            TournamentListSection(key: _tournamentKey),
            CalendarSection(key: _calendarKey),
            FooterSection(key: _footerKey),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String text, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton(
        onPressed: () => _scrollToSection(index),
        style: TextButton.styleFrom(
          foregroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  void _scrollToSection(int index) {
    final contextList = [
      _heroKey.currentContext, // 0
      _aboutKey.currentContext, // 1
      _gameOfMonthKey.currentContext, // 2
      _tournamentKey.currentContext, // 3
      _calendarKey.currentContext, // 4
      _footerKey.currentContext, // 5
    ];
    if (index < 0 || index >= contextList.length) return;
    final sectionContext = contextList[index];
    if (sectionContext != null) {
      Scrollable.ensureVisible(
        sectionContext,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }
}
