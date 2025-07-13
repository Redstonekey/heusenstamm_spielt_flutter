import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminWinnersScreen extends StatefulWidget {
  const AdminWinnersScreen({Key? key}) : super(key: key);

  @override
  State<AdminWinnersScreen> createState() => _AdminWinnersScreenState();
}

class _AdminWinnersScreenState extends State<AdminWinnersScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _winners = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWinners();
  }

  Future<void> _fetchWinners() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await supabase.from('winners').select();
      setState(() {
        _winners = List<Map<String, dynamic>>.from(data);
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

  Future<void> _showEditDialog([Map<String, dynamic>? winner]) async {
    final yearController = TextEditingController(text: winner?['year']?.toString() ?? '');
    final monthController = TextEditingController(text: winner?['month']?.toString() ?? '');
    final nameController = TextEditingController(text: winner?['game_name'] ?? '');
    final descController = TextEditingController(text: winner?['description'] ?? '');
    final isEdit = winner != null;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Gewinner bearbeiten' : 'Gewinner hinzufügen'),
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
                await supabase.from('winners').update({
                  'year': year,
                  'month': month,
                  'game_name': name,
                  'description': desc,
                }).eq('id', winner['id']);
              } else {
                await supabase.from('winners').insert({
                  'year': year,
                  'month': month,
                  'game_name': name,
                  'description': desc,
                });
              }
              if (mounted) Navigator.pop(context);
              _fetchWinners();
            },
            child: Text(isEdit ? 'Speichern' : 'Hinzufügen'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWinner(String id) async {
    await supabase.from('winners').delete().eq('id', id);
    _fetchWinners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gewinner verwalten')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _fetchWinners,
                  child: ListView.builder(
                    itemCount: _winners.length,
                    itemBuilder: (context, i) {
                      final w = _winners[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text('${w['game_name']} (${w['year']}/${w['month']})'),
                          subtitle: Text(w['description'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(w),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteWinner(w['id']),
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
        tooltip: 'Gewinner hinzufügen',
      ),
    );
  }
}
