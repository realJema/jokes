import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/joke.dart';

class JokesService {
  static const String _chuckNorrisApi =
      'https://api.chucknorris.io/jokes/random';
  static const String _dadJokeApi = 'https://icanhazdadjoke.com/';
  static const String _programmingJokeApi =
      'https://v2.jokeapi.dev/joke/Programming?type=single';
  static const String _punJokeApi =
      'https://v2.jokeapi.dev/joke/Pun?type=single';
  static const String _miscJokeApi =
      'https://v2.jokeapi.dev/joke/Miscellaneous?type=single';
  static const String _darkJokeApi =
      'https://v2.jokeapi.dev/joke/Dark?type=single';
  static const String _spookyJokeApi =
      'https://v2.jokeapi.dev/joke/Spooky?type=single';

  Future<Joke> getRandomJoke({String? category}) async {
    try {
      switch (category) {
        case 'programming':
          return await _getProgrammingJoke();
        case 'dad':
          return await _getDadJoke();
        case 'chuck':
          return await _getChuckNorrisJoke();
        case 'puns':
          return await _getPunJoke();
        case 'oneliners':
          return await _getDarkJoke();
        case 'misc':
          return await _getMiscJoke();
        case 'general':
          // For general category, randomly choose between all APIs
          final random = DateTime.now().millisecondsSinceEpoch % 6;
          switch (random) {
            case 0:
              return await _getProgrammingJoke();
            case 1:
              return await _getDadJoke();
            case 2:
              return await _getChuckNorrisJoke();
            case 3:
              return await _getPunJoke();
            case 4:
              return await _getDarkJoke();
            default:
              return await _getMiscJoke();
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

  Future<Joke> _getJokeFromJokeAPI(String url, String source) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Joke(
        id: data['id'].toString(),
        content: data['joke'],
        source: source,
      );
    }
    throw Exception('Failed to load $source joke');
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
    return _getJokeFromJokeAPI(_programmingJokeApi, 'Programming Jokes');
  }

  Future<Joke> _getPunJoke() async {
    return _getJokeFromJokeAPI(_punJokeApi, 'Pun Jokes');
  }

  Future<Joke> _getMiscJoke() async {
    return _getJokeFromJokeAPI(_miscJokeApi, 'Miscellaneous Jokes');
  }

  Future<Joke> _getDarkJoke() async {
    return _getJokeFromJokeAPI(_darkJokeApi, 'One Liner Jokes');
  }

  Future<Joke> _getSpookyJoke() async {
    return _getJokeFromJokeAPI(_spookyJokeApi, 'Spooky Jokes');
  }
}
