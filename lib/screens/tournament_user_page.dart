import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TournamentUserPage extends StatefulWidget {
  final String tournamentId;
  const TournamentUserPage({Key? key, required this.tournamentId}) : super(key: key);

  @override
  State<TournamentUserPage> createState() => _TournamentUserPageState();
}

class _TournamentUserPageState extends State<TournamentUserPage> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _tournament;
  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _matches = [];
  Map<String, dynamic>? _userParticipant;
  bool _loading = true;
  String? _error;
  bool _canSeeScores = true;

  @override
  void initState() {
    super.initState();
    _fetchTournament();
  }

  Future<void> _fetchTournament() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final t = await supabase.from('tournaments').select().eq('id', widget.tournamentId).single();
      final p = await supabase.from('tournament_participants').select().eq('tournament_id', widget.tournamentId);
      final m = await supabase.from('tournament_matches').select().eq('tournament_id', widget.tournamentId);
      final user = supabase.auth.currentUser;
      Map<String, dynamic>? userParticipant;
      if (user != null) {
        try {
          userParticipant = (p as List).cast<Map<String, dynamic>>().firstWhere(
            (part) => part['user_id'] == user.id,
          );
        } catch (_) {
          userParticipant = null;
        }
      }
      bool canSeeScores = true;
      if (m.isNotEmpty) {
        canSeeScores = m[0]['visible_to_players'] != false;
      }
      setState(() {
        _tournament = t;
        _participants = List<Map<String, dynamic>>.from(p);
        _matches = List<Map<String, dynamic>>.from(m);
        _userParticipant = userParticipant;
        _canSeeScores = canSeeScores;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _enterScoreDialog(Map<String, dynamic> match) async {
    final user = supabase.auth.currentUser;
    if (user == null || _userParticipant == null) return;
    final isP1 = match['participant1_id'] == _userParticipant!['id'];
    final isP2 = match['participant2_id'] == _userParticipant!['id'];
    if (!isP1 && !isP2) return;
    final isScore = (match['is_score'] ?? true) as bool;
    final scoreController = TextEditingController();
    bool won = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isScore ? 'Score eintragen' : 'Sieg/Niederlage eintragen'),
        content: isScore
            ? TextField(
                controller: scoreController,
                decoration: const InputDecoration(labelText: 'Dein Score'),
                keyboardType: TextInputType.number,
              )
            : CheckboxListTile(
                title: const Text('Ich habe gewonnen'),
                value: won,
                onChanged: (v) {
                  if (v != null) {
                    won = v;
                    setState(() {});
                  }
                },
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (isScore) {
                final score = int.tryParse(scoreController.text);
                if (score == null) return;
                if (isP1) {
                  await supabase.from('tournament_matches').update({'score1': score}).eq('id', match['id']);
                } else if (isP2) {
                  await supabase.from('tournament_matches').update({'score2': score}).eq('id', match['id']);
                }
              } else {
                if (isP1) {
                  await supabase.from('tournament_matches').update({'won1': won, 'won2': !won, 'winner_id': won ? _userParticipant!['id'] : match['participant2_id']}).eq('id', match['id']);
                } else if (isP2) {
                  await supabase.from('tournament_matches').update({'won2': won, 'won1': !won, 'winner_id': won ? _userParticipant!['id'] : match['participant1_id']}).eq('id', match['id']);
                }
              }
              if (mounted) Navigator.pop(context);
              _fetchTournament();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!, style: TextStyle(color: Colors.red))));
    }
    if (_tournament == null) {
      return const Scaffold(body: Center(child: Text('Turnier nicht gefunden.')));
    }
    return Scaffold(
      appBar: AppBar(title: Text(_tournament!['name'] ?? 'Turnier')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_tournament!['description'] != null && _tournament!['description'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(_tournament!['description'], style: const TextStyle(fontSize: 16)),
            ),
          if (_userParticipant != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text('Du bist Teilnehmer: ${_userParticipant!['display_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          const Text('Teilnehmer:', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._participants.map((p) => ListTile(title: Text(p['display_name']))),
          const SizedBox(height: 24),
          const Text('Deine Spiele:', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._matches.where((m) => _userParticipant != null && (m['participant1_id'] == _userParticipant!['id'] || m['participant2_id'] == _userParticipant!['id'])).map((m) {
            final p1 = _participants.firstWhere((p) => p['id'] == m['participant1_id'], orElse: () => {'display_name': 'TBD'});
            final p2 = _participants.firstWhere((p) => p['id'] == m['participant2_id'], orElse: () => {'display_name': 'TBD'});
            final score1 = m['score1']?.toString() ?? '-';
            final score2 = m['score2']?.toString() ?? '-';
            final isScore = (m['is_score'] ?? true) as bool;
            final won1 = m['won1'] == true;
            final won2 = m['won2'] == true;
            String resultText;
            if (isScore) {
              resultText = 'Ergebnis: $score1 : $score2';
            } else {
              if (won1) {
                resultText = '${p1['display_name']} hat gewonnen';
              } else if (won2) {
                resultText = '${p2['display_name']} hat gewonnen';
              } else {
                resultText = 'Noch kein Ergebnis';
              }
            }
            return Card(
              child: ListTile(
                title: Text('${p1['display_name']} vs ${p2['display_name']}'),
                subtitle: _canSeeScores ? Text(resultText) : null,
                trailing: ElevatedButton(
                  onPressed: () => _enterScoreDialog(m),
                  child: Text(isScore ? 'Score eintragen' : 'Sieg/Niederlage'),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          if (_canSeeScores) ...[
            const Text('Alle Spiele:', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._matches.map((m) {
              final p1 = _participants.firstWhere((p) => p['id'] == m['participant1_id'], orElse: () => {'display_name': 'TBD'});
              final p2 = _participants.firstWhere((p) => p['id'] == m['participant2_id'], orElse: () => {'display_name': 'TBD'});
              final score1 = m['score1']?.toString() ?? '-';
              final score2 = m['score2']?.toString() ?? '-';
              return Card(
                child: ListTile(
                  title: Text('${p1['display_name']} vs ${p2['display_name']}'),
                  subtitle: Text('Ergebnis: $score1 : $score2'),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
