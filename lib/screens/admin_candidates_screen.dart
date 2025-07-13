import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminCandidatesScreen extends StatefulWidget {
  const AdminCandidatesScreen({Key? key}) : super(key: key);

  @override
  State<AdminCandidatesScreen> createState() => _AdminCandidatesScreenState();
}

class _AdminCandidatesScreenState extends State<AdminCandidatesScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _candidates = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCandidates();
  }

  Future<void> _fetchCandidates() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await supabase.from('candidates').select();
      setState(() {
        _candidates = List<Map<String, dynamic>>.from(data);
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

  Future<void> _showEditDialog([Map<String, dynamic>? candidate]) async {
    final yearController = TextEditingController(text: candidate?['year']?.toString() ?? '');
    final monthController = TextEditingController(text: candidate?['month']?.toString() ?? '');
    final nameController = TextEditingController(text: candidate?['game_name'] ?? '');
    final descController = TextEditingController(text: candidate?['description'] ?? '');
    final isEdit = candidate != null;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Kandidat bearbeiten' : 'Kandidat hinzufügen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: 'Jahr'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: monthController,
                decoration: const InputDecoration(labelText: 'Monat'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Spielname'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Beschreibung'),
                minLines: 1,
                maxLines: 3,
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
              final year = int.tryParse(yearController.text);
              final month = int.tryParse(monthController.text);
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              if (year == null || month == null || name.isEmpty) return;
              if (isEdit) {
                await supabase.from('candidates').update({
                  'year': year,
                  'month': month,
                  'game_name': name,
                  'description': desc,
                }).eq('id', candidate['id']);
              } else {
                await supabase.from('candidates').insert({
                  'year': year,
                  'month': month,
                  'game_name': name,
                  'description': desc,
                });
              }
              if (mounted) Navigator.pop(context);
              _fetchCandidates();
            },
            child: Text(isEdit ? 'Speichern' : 'Hinzufügen'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCandidate(String id) async {
    await supabase.from('candidates').delete().eq('id', id);
    _fetchCandidates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kandidaten verwalten')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _fetchCandidates,
                  child: ListView.builder(
                    itemCount: _candidates.length,
                    itemBuilder: (context, i) {
                      final c = _candidates[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text('${c['game_name']} (${c['year']}/${c['month']})'),
                          subtitle: Text(c['description'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteCandidate(c['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Kandidat hinzufügen',
      ),
    );
  }
}
