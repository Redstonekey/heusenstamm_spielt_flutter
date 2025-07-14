import 'package:flutter/material.dart';
import 'admin_candidates_screen.dart';
import 'admin_winners_screen.dart';
import 'admin_tournaments_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Gewinner verwalten'),
            subtitle: const Text('Gewinner des Monats ansehen und bearbeiten'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AdminWinnersScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Kandidaten verwalten'),
            subtitle: const Text('Kandidaten für Spiel des Monats verwalten'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AdminCandidatesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.emoji_events),
            title: const Text('Turniere verwalten'),
            subtitle: const Text('Turniere anlegen und bearbeiten'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AdminTournamentsScreen()),
            ),
          ),
          // Add more admin features here as needed
        ],
      ),
    );
  }
}
