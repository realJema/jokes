import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/joke.dart';

class FavoritesRepository {
  static const String _boxName = 'favorites';

  final Box<Joke> _box;

  FavoritesRepository() : _box = Hive.box<Joke>(_boxName);

  ValueListenable<Box<Joke>> get boxListenable => _box.listenable();

  List<Joke> getAllFavorites() {
    return _box.values.toList();
  }

  Future<void> addFavorite(Joke joke) async {
    await _box.put(joke.id, joke);
  }

  Future<void> removeFavorite(String jokeId) async {
    await _box.delete(jokeId);
  }

  bool isFavorite(String jokeId) {
    return _box.containsKey(jokeId);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
