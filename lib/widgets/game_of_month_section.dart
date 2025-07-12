import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/image_service.dart';

class GameOfMonthSection extends StatefulWidget {
  const GameOfMonthSection({super.key});

  @override
  State<GameOfMonthSection> createState() => _GameOfMonthSectionState();
}

class _GameOfMonthSectionState extends State<GameOfMonthSection> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Sample data - will be replaced with dynamic data later
  final String currentGameOfMonth = 'Catan';
  final String currentGameDescription = 'Ein strategisches Aufbauspiel, bei dem Spieler eine Insel besiedeln, Ressourcen sammeln und Handelsrouten etablieren. Perfekt für 3-4 Spieler ab 10 Jahren.';
  final int currentGameVotes = 342;
  
  final List<Map<String, dynamic>> votingCandidates = [
    {
      'name': 'Ticket to Ride',
      'description': 'Eisenbahn-Abenteuer quer durch Europa',
      'votes': 287,
    },
    {
      'name': 'Wingspan',
      'description': 'Wunderschönes Vogelspiel mit Engine-Building',
      'votes': 231,
    },
    {
      'name': 'Azul',
      'description': 'Strategisches Fliesenlegespiel',
      'votes': 198,
    },
    {
      'name': 'Splendor',
      'description': 'Edelstein-Handel im Renaissance-Stil',
      'votes': 176,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1976D2),
            Color(0xFF1565C0),
            Color(0xFF0D47A1),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        // Section Title
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'SPIEL DES MONATS',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Dezember 2024',
                              style: GoogleFonts.roboto(
                                fontSize: 42,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Current Game of the Month
                        _buildCurrentGameCard(),
                        
                        const SizedBox(height: 80),
                        
                        // Voting Section
                        _buildVotingSection(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentGameCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 768) {
              return Row(
                children: [
                  // Game Image
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 400,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          ImageService.getPicsumImage(width: 400, height: 400),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF1976D2).withOpacity(0.1),
                                    const Color(0xFF1976D2).withOpacity(0.05),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.casino,
                                      size: 64,
                                      color: const Color(0xFF1976D2),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      currentGameOfMonth,
                                      style: GoogleFonts.roboto(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1976D2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Game Info
                  Expanded(
                    flex: 3,
                    child: _buildGameInfo(),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  Container(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        ImageService.getPicsumImage(width: 400, height: 250),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF1976D2).withOpacity(0.1),
                                  const Color(0xFF1976D2).withOpacity(0.05),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.casino,
                                    size: 48,
                                    color: const Color(0xFF1976D2),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    currentGameOfMonth,
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1976D2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  _buildGameInfo(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildGameInfo() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'GEWINNER',
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$currentGameVotes Stimmen',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            currentGameOfMonth,
            style: GoogleFonts.roboto(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            currentGameDescription,
            style: GoogleFonts.roboto(
              fontSize: 16,
              height: 1.6,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Learn more functionality
                },
                icon: const Icon(Icons.info_outline),
                label: const Text('Mehr erfahren'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1976D2),
                  side: const BorderSide(color: Color(0xFF1976D2)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVotingSection() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Voting Header
          Column(
            children: [
              Text(
                'Stimme für das nächste Spiel des Monats ab!',
                style: GoogleFonts.roboto(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Wähle dein Lieblingsspiel für Januar 2025. Die Abstimmung läuft noch 12 Tage.',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Voting Cards
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 768) {
                return Row(
                  children: votingCandidates.map((game) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: _buildVotingCard(game),
                      ),
                    );
                  }).toList(),
                );
              } else {
                return Column(
                  children: votingCandidates.map((game) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildVotingCard(game),
                    );
                  }).toList(),
                );
              }
            },
          ),
          
          const SizedBox(height: 40),
          
          // Vote CTA
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.how_to_vote,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deine Stimme zählt!',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Melde dich an und stimme für dein Lieblingsspiel ab.',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to voting
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Jetzt abstimmen',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingCard(Map<String, dynamic> game) {
    return GestureDetector(
      onTap: () {
        // Handle voting
        _showVoteDialog(game);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            // Game image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: 120,
                child: Image.network(
                  ImageService.getPicsumImage( width: 300, height: 120),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1976D2).withOpacity(0.1),
                            const Color(0xFF1976D2).withOpacity(0.05),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.casino,
                              size: 32,
                              color: const Color(0xFF1976D2),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              game['name'],
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1976D2),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Game info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    game['name'],
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game['description'],
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.thumb_up,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${game['votes']} Stimmen',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoteDialog(Map<String, dynamic> game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Stimme für ${game['name']} ab',
          style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                game['image'],
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              game['description'],
              style: GoogleFonts.roboto(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Aktuell: ${game['votes']} Stimmen',
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle vote submission
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Danke für deine Stimme für ${game['name']}!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
            ),
            child: const Text('Abstimmen'),
          ),
        ],
      ),
    );
  }
}
