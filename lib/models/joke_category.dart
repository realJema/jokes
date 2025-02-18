import 'package:flutter/material.dart' show IconData, Icons, Color, Colors;

class JokeCategory {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color? color;

  const JokeCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.color,
  });

  static final List<JokeCategory> allCategories = [
    JokeCategory(
      id: 'programming',
      name: 'Programming',
      description: 'Jokes about coding and technology',
      icon: Icons.code,
      color: Colors.blue,
    ),
    JokeCategory(
      id: 'dad',
      name: 'Dad Jokes',
      description: 'Classic dad jokes that make you groan',
      icon: Icons.face,
      color: Colors.green,
    ),
    JokeCategory(
      id: 'chuck',
      name: 'Chuck Norris',
      description: 'Legendary Chuck Norris jokes',
      icon: Icons.sports_martial_arts,
      color: Colors.red,
    ),
    JokeCategory(
      id: 'puns',
      name: 'Puns',
      description: 'Wordplay and clever puns',
      icon: Icons.lightbulb,
      color: Colors.orange,
    ),
    JokeCategory(
      id: 'oneliners',
      name: 'One Liners',
      description: 'Short and sweet jokes',
      icon: Icons.short_text,
      color: Colors.purple,
    ),
    JokeCategory(
      id: 'misc',
      name: 'Miscellaneous',
      description: 'Random funny jokes',
      icon: Icons.shuffle,
      color: Colors.teal,
    ),
  ];
}
