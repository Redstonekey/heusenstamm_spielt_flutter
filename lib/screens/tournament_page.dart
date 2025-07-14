import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TournamentPage extends StatefulWidget {
  final String tournamentId;
  const TournamentPage({Key? key, required this.tournamentId}) : super(key: key);

  @override
  State<TournamentPage> createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage> {
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
          const Text('Teilnehmer:', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._participants.map((p) => ListTile(title: Text(p['display_name']))),
          const SizedBox(height: 24),
          const Text('Spiele:', style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}
