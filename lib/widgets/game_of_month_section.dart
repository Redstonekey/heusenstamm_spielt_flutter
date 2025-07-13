
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/image_service.dart';


class GameOfMonthSection extends StatefulWidget {
  const GameOfMonthSection({super.key});

  @override
  State<GameOfMonthSection> createState() => _GameOfMonthSectionState();
}

class _GameOfMonthSectionState extends State<GameOfMonthSection> with TickerProviderStateMixin {
  // Cache for Wikipedia descriptions
  final Map<String, String> _wikiDescriptions = {};
  String? _wikipediaUrl;
  String _getCurrentMonthYearString() {
    final now = DateTime.now();
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }
  final supabase = Supabase.instance.client;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;


  String? currentGameOfMonth;
  String? currentGameDescription;
  int currentGameVotes = 0;
  List<Map<String, dynamic>> votingCandidates = [];

  String? _deviceId;

  bool _hasVoted = false;
  String? _votedForGame;

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
    _initDeviceIdAndVotes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchGameData();
      _animationController.forward();
    });
  }


  // Fetches the German Wikipedia summary for a game and updates the cache/UI
  Future<void> _fetchWikipediaDescription(String gameName) async {
    if (gameName.trim().isEmpty) return;
    final apiTitle = gameName.replaceAll(' ', '_');
    final url = 'https://de.wikipedia.org/api/rest_v1/page/summary/$apiTitle';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['extract'] != null && data['extract'].toString().trim().isNotEmpty) {
          setState(() {
            _wikiDescriptions[gameName] = data['extract'];
            // If this is the current winner, update its description
            if (currentGameOfMonth == gameName) {
              currentGameDescription = data['extract'];
            }
            // If this is a candidate, update its description
            for (final candidate in votingCandidates) {
              if (candidate['name'] == gameName) {
                candidate['description'] = data['extract'];
              }
            }
          });
        }
      }
    } catch (_) {
      // Ignore errors, fallback to Supabase description
    }
  }


  Future<void> _fetchGameData() async {
    // Fetch winner (game of the last month)
    final now = DateTime.now();
    final lastMonth = DateTime(now.year, now.month - 1, 1);
    final winnerRes = await supabase
        .from('winners')
        .select()
        .eq('year', lastMonth.year)
        .eq('month', lastMonth.month)
        .maybeSingle();
    if (winnerRes != null) {
      setState(() {
        currentGameOfMonth = winnerRes['game_name'];
        currentGameDescription = winnerRes['description'];
        _wikipediaUrl = null;
      });
      // Fetch vote count for winner
      final votes = await supabase
          .from('votes')
          .select('game_name')
          .eq('game_name', winnerRes['game_name']);
      setState(() {
        currentGameVotes = votes.length;
      });

      // Try to fetch German Wikipedia page for the winner
      if (winnerRes['game_name'] != null && winnerRes['game_name'].toString().trim().isNotEmpty) {
        final wikiTitle = winnerRes['game_name'].toString().replaceAll(' ', '_');
        final url = 'https://de.wikipedia.org/wiki/$wikiTitle';
        // Just set the URL (optionally, you could check for 404 with http package)
        setState(() {
          _wikipediaUrl = url;
        });
        // Fetch Wikipedia description for winner
        await _fetchWikipediaDescription(winnerRes['game_name'].toString());
      }
    }
    // Fetch games to vote on for this month
    final candidatesRes = await supabase
        .from('candidates')
        .select()
        .eq('year', now.year)
        .eq('month', now.month);
    if (candidatesRes.isNotEmpty) {
      setState(() {
        votingCandidates = candidatesRes.map<Map<String, dynamic>>((row) => {
          'name': row['game_name'],
          'description': row['description'],
          'votes': 0,
        }).toList();
      });
      // Fetch Wikipedia descriptions for all candidates
      // Move _fetchWikipediaDescription above _fetchGameData to fix reference error
      for (final game in votingCandidates) {
        await this._fetchWikipediaDescription(game['name']);
      }
      await _fetchVotes();
  // Fetches the German Wikipedia summary for a game and updates the cache/UI
  Future<void> _fetchWikipediaDescription(String gameName) async {
    if (gameName.trim().isEmpty) return;
    final apiTitle = gameName.replaceAll(' ', '_');
    final url = 'https://de.wikipedia.org/api/rest_v1/page/summary/$apiTitle';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['extract'] != null && data['extract'].toString().trim().isNotEmpty) {
          setState(() {
            _wikiDescriptions[gameName] = data['extract'];
            // If this is the current winner, update its description
            if (currentGameOfMonth == gameName) {
              currentGameDescription = data['extract'];
            }
            // If this is a candidate, update its description
            for (final candidate in votingCandidates) {
              if (candidate['name'] == gameName) {
                candidate['description'] = data['extract'];
              }
            }
          });
        }
      }
    } catch (_) {
      // Ignore errors, fallback to Supabase description
    }
  }
    }
  }

  Future<void> _initDeviceIdAndVotes() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('deviceId');
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString() + '_' + (1000 + (10000 * (DateTime.now().microsecond / 1000000)).toInt()).toString();
      await prefs.setString('deviceId', deviceId);
    }
    // _deviceId is a field, so just assign it directly
    _deviceId = deviceId;
    await _fetchVotes();
    await _checkIfVoted();
  }

  Future<void> _fetchVotes() async {
    final data = await supabase
        .from('votes')
        .select('game_name');
    final Map<String, int> counts = {};
    for (var row in data) {
      final name = row['game_name'] as String;
      counts[name] = (counts[name] ?? 0) + 1;
    }
    setState(() {
      for (var candidate in votingCandidates) {
        candidate['votes'] = counts[candidate['name']] ?? 0;
      }
    });
  }

  Future<void> _checkIfVoted() async {
    if (_deviceId == null) return;
    final data = await supabase
        .from('votes')
        .select('game_name')
        .eq('voter_id', _deviceId!);
    if (data.isNotEmpty) {
      setState(() {
        _hasVoted = true;
        _votedForGame = data[0]['game_name'];
      });
    } else {
      setState(() {
        _hasVoted = false;
        _votedForGame = null;
      });
    }
  }




  Future<void> _saveVoteStatus(String gameName) async {
    if (_deviceId == null) return;
    await supabase.from('votes').insert({
      'game_name': gameName,
      'voter_id': _deviceId,
    });
    setState(() {
      _hasVoted = true;
      _votedForGame = gameName;
    });
    await _fetchVotes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate last month and year
    final now = DateTime.now();
    int lastMonth = now.month - 1;
    int year = now.year;
    if (lastMonth == 0) {
      lastMonth = 12;
      year -= 1;
    }
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ];
    String lastMonthString = months[lastMonth - 1];

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
                              '$lastMonthString $year',
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
    if (currentGameOfMonth == null) {
      return const SizedBox.shrink();
    }
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
            currentGameOfMonth ?? '',
            style: GoogleFonts.roboto(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            (currentGameOfMonth != null && _wikiDescriptions[currentGameOfMonth!] != null)
                ? _wikiDescriptions[currentGameOfMonth!] ?? ''
                : (currentGameDescription ?? ''),
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
                onPressed: _wikipediaUrl != null
                    ? () async {
                        final uri = Uri.parse(_wikipediaUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      }
                    : null,
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
                'Wähle dein Lieblingsspiel für ${_getCurrentMonthYearString()}. Die Abstimmung läuft noch 12 Tage.',
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
                        _hasVoted
                            ? (_votedForGame != null
                                ? 'Du hast für "$_votedForGame" abgestimmt.'
                                : 'Du hast bereits abgestimmt.')
                            : 'Stimme für dein Lieblingsspiel ab.',
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
                    _showVotingOptionsDialog();
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
    return Container(
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
                  (_wikiDescriptions[game['name']] != null)
                      ? _wikiDescriptions[game['name']]!
                      : (game['description'] ?? ''),
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
    );
  }

  void _showVotingOptionsDialog() {
    if (_hasVoted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Du hast bereits abgestimmt', style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
          content: Text(
            _votedForGame != null
                ? 'Du hast für "$_votedForGame" abgestimmt.'
                : 'Du hast bereits abgestimmt.',
            style: GoogleFonts.roboto(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Wähle dein Lieblingsspiel',
            style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: votingCandidates.map((game) {
              return ListTile(
                title: Text(game['name'], style: GoogleFonts.roboto(fontWeight: FontWeight.w500)),
                subtitle: Text(game['description'], style: GoogleFonts.roboto(fontSize: 12)),
                trailing: Text('${game['votes']} Stimmen', style: GoogleFonts.roboto(fontSize: 12, color: Colors.blue)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showVoteDialog(game);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showVoteDialog(Map<String, dynamic> game) {
    if (_hasVoted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Du hast bereits abgestimmt', style: GoogleFonts.roboto(fontWeight: FontWeight.w600)),
          content: Text(
            _votedForGame != null
                ? 'Du hast für "$_votedForGame" abgestimmt.'
                : 'Du hast bereits abgestimmt.',
            style: GoogleFonts.roboto(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    bool isVoting = false;
    bool hasVoted = false;
    showDialog(
      context: context,
      barrierDismissible: !isVoting,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              hasVoted ? 'Abgestimmt!' : 'Stimme für ${game['name']} ab',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                if (isVoting)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(),
                  ),
                if (hasVoted)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      'Danke für deine Stimme für ${game['name']}!',
                      style: GoogleFonts.roboto(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              if (!isVoting && !hasVoted)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Abbrechen'),
                ),
              if (!isVoting && !hasVoted)
                ElevatedButton(
                  onPressed: () async {
                    setState(() => isVoting = true);
                    // Simulate a network call for demo purposes
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {
                      hasVoted = true;
                      isVoting = false;
                    });
                    await _saveVoteStatus(game['name']);
                    await Future.delayed(const Duration(seconds: 1));
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
      },
    );
  }
}
