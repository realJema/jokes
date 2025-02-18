import 'package:hive/hive.dart';

part 'joke.g.dart';

@HiveType(typeId: 0)
class Joke extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final String source;

  @HiveField(3)
  final DateTime savedAt;

  Joke({
    required this.id,
    required this.content,
    required this.source,
    DateTime? savedAt,
  }) : savedAt = savedAt ?? DateTime.now();
}
