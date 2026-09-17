import 'package:flutter/material.dart';
import 'editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0D13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF14161F),
        title: const Text('Video Editor'),
      ),
      body: Center(
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C5CE7),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          icon: const Icon(Icons.add),
          label: const Text('New Project'),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditorScreen()),
            );
          },
        ),
      ),
    );
  }
}
