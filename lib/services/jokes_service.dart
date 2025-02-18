import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/joke.dart';

class JokesService {
  static const String _chuckNorrisApi =
      'https://api.chucknorris.io/jokes/random';
  static const String _dadJokeApi = 'https://icanhazdadjoke.com/';
  static const String _programmingJokeApi =
      'https://v2.jokeapi.dev/joke/Programming?type=single';

  Future<Joke> getRandomJoke({String? category}) async {
    try {
      switch (category) {
        case 'programming':
          return await _getProgrammingJoke();
        case 'dad':
          return await _getDadJoke();
        case 'chuck':
          return await _getChuckNorrisJoke();
        case 'general':
          // For general category, randomly choose between all APIs
          final random = DateTime.now().millisecondsSinceEpoch % 3;
          switch (random) {
            case 0:
              return await _getProgrammingJoke();
            case 1:
              return await _getDadJoke();
            default:
              return await _getChuckNorrisJoke();
          }
        default:
          // If no category selected, use dad jokes as fallback
          return await _getDadJoke();
      }
    } catch (e) {
      // If an API fails, try dad jokes as fallback
      try {
        return await _getDadJoke();
      } catch (_) {
        throw Exception('Failed to load jokes from all sources');
      }
    }
  }

  Future<Joke> _getChuckNorrisJoke() async {
    final response = await http.get(Uri.parse(_chuckNorrisApi));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Joke(
        id: data['id'],
        content: data['value'],
        source: 'Chuck Norris Jokes',
      );
    }
    throw Exception('Failed to load Chuck Norris joke');
  }

  Future<Joke> _getDadJoke() async {
    final response = await http.get(
      Uri.parse(_dadJokeApi),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Joke(
        id: data['id'],
        content: data['joke'],
        source: 'Dad Jokes',
      );
    }
    throw Exception('Failed to load Dad joke');
  }

  Future<Joke> _getProgrammingJoke() async {
    final response = await http.get(Uri.parse(_programmingJokeApi));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Joke(
        id: data['id'].toString(),
        content: data['joke'],
        source: 'Programming Jokes',
      );
    }
    throw Exception('Failed to load Programming joke');
  }
}
