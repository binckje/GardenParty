import 'package:flutter/material.dart';

/// Écran provisoire en attendant l'implémentation de la fonctionnalité.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, required this.emoji, required this.todo});

  final String title;
  final String emoji;
  final String todo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(todo, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
