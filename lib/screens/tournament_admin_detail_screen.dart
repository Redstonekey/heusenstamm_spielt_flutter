import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TournamentAdminDetailScreen extends StatefulWidget {
  final String tournamentId;
  const TournamentAdminDetailScreen({Key? key, required this.tournamentId}) : super(key: key);

  @override
  State<TournamentAdminDetailScreen> createState() => _TournamentAdminDetailScreenState();
}

class _TournamentAdminDetailScreenState extends State<TournamentAdminDetailScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _tournament;
  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;
  String? _error;

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
      setState(() {
        _tournament = t;
        _participants = List<Map<String, dynamic>>.from(p);
        _matches = List<Map<String, dynamic>>.from(m);
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

  Future<void> _showParticipantDialog([Map<String, dynamic>? participant]) async {
    final nameController = TextEditingController(text: participant?['display_name'] ?? '');
    String? userId = participant?['user_id'];
    final isEdit = participant != null;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Teilnehmer bearbeiten' : 'Teilnehmer hinzufügen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: TextEditingController(text: userId ?? ''),
              decoration: const InputDecoration(labelText: 'User-ID (optional)'),
              onChanged: (v) => userId = v.isEmpty ? null : v,
            ),
            if (userId != null && userId!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    const Text('Mit Benutzer verknüpft', style: TextStyle(fontSize: 12, color: Colors.green)),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              if (isEdit) {
                await supabase.from('tournament_participants').update({
                  'display_name': name,
                  'user_id': userId,
                }).eq('id', participant['id']);
              } else {
                await supabase.from('tournament_participants').insert({
                  'tournament_id': widget.tournamentId,
                  'display_name': name,
                  'user_id': userId,
                });
              }
              if (mounted) Navigator.pop(context);
              _fetchTournament();
            },
            child: Text(isEdit ? 'Speichern' : 'Hinzufügen'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteParticipant(String id) async {
    await supabase.from('tournament_participants').delete().eq('id', id);
    _fetchTournament();
  }

  // TODO: Add match editing/creation dialogs and admin controls

  Future<void> _showMatchDialog([Map<String, dynamic>? match]) async {
    String? participant1Id = match?['participant1_id'];
    String? participant2Id = match?['participant2_id'];
    final score1Controller = TextEditingController(text: match?['score1']?.toString() ?? '');
    final score2Controller = TextEditingController(text: match?['score2']?.toString() ?? '');
    final roundController = TextEditingController(text: match?['round']?.toString() ?? '1');
    final matchIndexController = TextEditingController(text: match?['match_index']?.toString() ?? '0');
    final isEdit = match != null;
    bool useScore = (match?['is_score'] ?? true) as bool;
    bool won1 = (match?['won1'] ?? false) as bool;
    bool won2 = (match?['won2'] ?? false) as bool;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Match bearbeiten' : 'Match hinzufügen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: participant1Id,
                items: _participants.map<DropdownMenuItem<String>>((p) => DropdownMenuItem<String>(
                  value: p['id'] as String,
                  child: Text(p['display_name']),
                )).toList(),
                onChanged: (v) => participant1Id = v,
                decoration: const InputDecoration(labelText: 'Teilnehmer 1'),
              ),
              DropdownButtonFormField<String>(
                value: participant2Id,
                items: _participants.map<DropdownMenuItem<String>>((p) => DropdownMenuItem<String>(
                  value: p['id'] as String,
                  child: Text(p['display_name']),
                )).toList(),
                onChanged: (v) => participant2Id = v,
                decoration: const InputDecoration(labelText: 'Teilnehmer 2'),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Score'),
                      value: true,
                      groupValue: useScore,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            useScore = v;
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Nur Sieg/Niederlage'),
                      value: false,
                      groupValue: useScore,
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            useScore = v;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (useScore) ...[
                TextField(
                  controller: score1Controller,
                  decoration: const InputDecoration(labelText: 'Score 1'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: score2Controller,
                  decoration: const InputDecoration(labelText: 'Score 2'),
                  keyboardType: TextInputType.number,
                ),
              ] else ...[
                CheckboxListTile(
                  title: const Text('Teilnehmer 1 hat gewonnen'),
                  value: won1,
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        won1 = v;
                        won2 = !v;
                      });
                    }
                  },
                ),
                CheckboxListTile(
                  title: const Text('Teilnehmer 2 hat gewonnen'),
                  value: won2,
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        won2 = v;
                        won1 = !v;
                      });
                    }
                  },
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: roundController,
                      decoration: const InputDecoration(labelText: 'Runde'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: TextField(
                      controller: matchIndexController,
                      decoration: const InputDecoration(labelText: 'Match-Index'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              if (isEdit)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.admin_panel_settings, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      const Text('Admin-Override aktiv', style: TextStyle(fontSize: 12, color: Colors.orange)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (participant1Id == null || participant2Id == null) return;
              int? score1;
              int? score2;
              String? winnerId;
              if (useScore) {
                score1 = int.tryParse(score1Controller.text);
                score2 = int.tryParse(score2Controller.text);
                if (score1 != null && score2 != null) {
                  if (score1 > score2) winnerId = participant1Id;
                  else if (score2 > score1) winnerId = participant2Id;
                }
              } else {
                score1 = null;
                score2 = null;
                if (won1) winnerId = participant1Id;
                else if (won2) winnerId = participant2Id;
              }
              final round = int.tryParse(roundController.text) ?? 1;
              final matchIndex = int.tryParse(matchIndexController.text) ?? 0;
              if (isEdit) {
                await supabase.from('tournament_matches').update({
                  'participant1_id': participant1Id,
                  'participant2_id': participant2Id,
                  'score1': score1,
                  'score2': score2,
                  'winner_id': winnerId,
                  'round': round,
                  'match_index': matchIndex,
                  'is_score': useScore,
                  'won1': won1,
                  'won2': won2,
                }).eq('id', match['id']);
              } else {
                await supabase.from('tournament_matches').insert({
                  'tournament_id': widget.tournamentId,
                  'participant1_id': participant1Id,
                  'participant2_id': participant2Id,
                  'score1': score1,
                  'score2': score2,
                  'winner_id': winnerId,
                  'round': round,
                  'match_index': matchIndex,
                  'is_score': useScore,
                  'won1': won1,
                  'won2': won2,
                });
              }
              if (mounted) Navigator.pop(context);
              _fetchTournament();
            },
            child: Text(isEdit ? 'Speichern' : 'Hinzufügen'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMatch(String id) async {
    await supabase.from('tournament_matches').delete().eq('id', id);
    _fetchTournament();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))));
    }
    if (_tournament == null) {
      return const Scaffold(body: Center(child: Text('Turnier nicht gefunden.')));
    }

    // Score visibility toggle handler
    Future<void> _toggleScoreVisibility(bool value) async {
      await supabase.from('tournaments').update({'score_visible': value}).eq('id', widget.tournamentId);
      setState(() {
        if (_tournament != null) _tournament!['score_visible'] = value;
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text('Admin: ${_tournament!['name']}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_tournament!['description'] != null && _tournament!['description'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(_tournament!['description'], style: const TextStyle(fontSize: 16)),
            ),

          // Score visibility toggle
          SwitchListTile(
            title: const Text('Spieler dürfen Ergebnisse sehen'),
            value: (_tournament!['score_visible'] ?? false) as bool,
            onChanged: (val) => _toggleScoreVisibility(val),
            secondary: const Icon(Icons.visibility),
          ),
          const Divider(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Teilnehmer:', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showParticipantDialog(),
                tooltip: 'Teilnehmer hinzufügen',
              ),
            ],
          ),
          ..._participants.map((p) => ListTile(
                title: Row(
                  children: [
                    Text(p['display_name']),
                    if (p['user_id'] != null && (p['user_id'] as String).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.link, color: Colors.green, size: 16),
                            Text(' (User)', style: TextStyle(fontSize: 12, color: Colors.green)),
                          ],
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showParticipantDialog(p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteParticipant(p['id']),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Spiele:', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showMatchDialog(),
                tooltip: 'Match hinzufügen',
              ),
            ],
          ),
          ..._matches.map((m) {
            final p1 = _participants.firstWhere((p) => p['id'] == m['participant1_id'], orElse: () => {'display_name': 'TBD'});
            final p2 = _participants.firstWhere((p) => p['id'] == m['participant2_id'], orElse: () => {'display_name': 'TBD'});
            final score1 = m['score1']?.toString() ?? '-';
            final score2 = m['score2']?.toString() ?? '-';
            final round = m['round']?.toString() ?? '-';
            final matchIndex = m['match_index']?.toString() ?? '-';
            return Card(
              child: ListTile(
                title: Text('${p1['display_name']} vs ${p2['display_name']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ergebnis: $score1 : $score2'),
                    Text('Runde: $round, Match-Index: $matchIndex', style: const TextStyle(fontSize: 12)),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showMatchDialog(m),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteMatch(m['id']),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
