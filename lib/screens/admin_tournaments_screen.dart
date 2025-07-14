import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tournament_admin_detail_screen.dart';

class AdminTournamentsScreen extends StatefulWidget {
  const AdminTournamentsScreen({Key? key}) : super(key: key);

  @override
  State<AdminTournamentsScreen> createState() => _AdminTournamentsScreenState();
}

class _AdminTournamentsScreenState extends State<AdminTournamentsScreen> {
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

  Future<void> _showEditDialog([Map<String, dynamic>? tournament]) async {
    final nameController = TextEditingController(text: tournament?['name'] ?? '');
    final descController = TextEditingController(text: tournament?['description'] ?? '');
    String method = tournament?['method'] ?? 'manual';
    String schemaType = tournament?['schema_type'] ?? 'tree';
    final isEdit = tournament != null;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Turnier bearbeiten' : 'Turnier erstellen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Beschreibung'),
              ),
              DropdownButtonFormField<String>(
                value: method,
                items: const [
                  DropdownMenuItem(value: 'manual', child: Text('Manuell')),
                  DropdownMenuItem(value: 'schema', child: Text('Schema (Baum/Duell)')),
                ],
                onChanged: (v) => method = v ?? 'manual',
                decoration: const InputDecoration(labelText: 'Methode'),
              ),
              if (method == 'schema')
                DropdownButtonFormField<String>(
                  value: schemaType,
                  items: const [
                    DropdownMenuItem(value: 'tree', child: Text('Baum (K.O.)')),
                    DropdownMenuItem(value: 'duel', child: Text('Duell')),
                  ],
                  onChanged: (v) => schemaType = v ?? 'tree',
                  decoration: const InputDecoration(labelText: 'Schema-Typ'),
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
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              if (name.isEmpty) return;
              if (isEdit) {
                await supabase.from('tournaments').update({
                  'name': name,
                  'description': desc,
                  'method': method,
                  'schema_type': method == 'schema' ? schemaType : null,
                }).eq('id', tournament['id']);
              } else {
                await supabase.from('tournaments').insert({
                  'name': name,
                  'description': desc,
                  'method': method,
                  'schema_type': method == 'schema' ? schemaType : null,
                });
              }
              if (mounted) Navigator.pop(context);
              _fetchTournaments();
            },
            child: Text(isEdit ? 'Speichern' : 'Erstellen'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTournament(String id) async {
    await supabase.from('tournaments').delete().eq('id', id);
    _fetchTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Turniere verwalten')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _fetchTournaments,
                  child: ListView.builder(
                    itemCount: _tournaments.length,
                    itemBuilder: (context, i) {
                      final t = _tournaments[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(t['name'] ?? ''),
                          subtitle: Text(t['description'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(t),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteTournament(t['id']),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TournamentAdminDetailScreen(tournamentId: t['id']),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Turnier erstellen',
      ),
    );
  }
}
