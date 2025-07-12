import 'package:flutter/material.dart';

class TestImageScreen extends StatelessWidget {
  const TestImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Testing Image Load:'),
            const SizedBox(height: 20),
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Image.asset(
                'assets/images/board_game_hero.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.red[100],
                    child: const Center(
                      child: Text(
                        'Image failed to load',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
