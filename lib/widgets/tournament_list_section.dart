import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TournamentListSection extends StatefulWidget {
  const TournamentListSection({Key? key}) : super(key: key);

  @override
  State<TournamentListSection> createState() => _TournamentListSectionState();
}

class _TournamentListSectionState extends State<TournamentListSection> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _tournaments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTournaments();
  }

  Future<void> _fetchTournaments() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await supabase.from('tournaments').select();
      setState(() {
        _tournaments = List<Map<String, dynamic>>.from(data);
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Fehler: \n${_error!}'));
    }
    if (_tournaments.isEmpty) {
      return const Center(child: Text('Keine Turniere gefunden.'));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 700;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 3 : 1,
            childAspectRatio: isWide ? 2.5 : 1.5,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
          ),
          itemCount: _tournaments.length,
          itemBuilder: (context, index) {
            final t = _tournaments[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.pushNamed(context, '/tournament/${t['id']}');
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        t['name'] ?? 'Turnier',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (t['description'] != null && t['description'].toString().isNotEmpty)
                        Text(
                          t['description'],
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.people, size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${t['max_participants'] ?? '-'} Plätze'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
