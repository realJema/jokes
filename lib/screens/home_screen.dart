import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../models/joke.dart';
import '../models/joke_category.dart';
import '../services/jokes_service.dart';
import '../widgets/joke_card.dart';
import 'favorites_screen.dart';
import '../repositories/favorites_repository.dart';
import '../screens/settings_screen.dart';
import '../screens/categories_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? category;

  const HomeScreen({
    super.key,
    this.category,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final JokesService _jokesService = JokesService();
  final FavoritesRepository _favoritesRepository = FavoritesRepository();
  late MatchEngine _matchEngine;
  final List<SwipeItem> _swipeItems = [];
  final List<Joke> _jokes = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  static const int _minimumJokes = 5;
  static const int _batchSize = 10;

  @override
  void initState() {
    super.initState();
    _initialLoad();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initialLoad() async {
    await _loadJokes();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadJokes() async {
    if (!mounted || _isLoadingMore) return;

    try {
      setState(() => _isLoadingMore = true);

      final newJokes = await Future.wait(
        List.generate(
            _batchSize,
            (_) => _jokesService.getRandomJoke(
                  category: widget.category,
                )),
      );

      if (!mounted) return;

      setState(() {
        _jokes.addAll(newJokes);
        _addSwipeItems(newJokes);
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading jokes: $e')),
      );
    }
  }

  void _addSwipeItems(List<Joke> jokes) {
    for (var joke in jokes) {
      _swipeItems.add(
        SwipeItem(
          content: joke,
          likeAction: () async {
            await _favoritesRepository.addFavorite(joke);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Joke added to favorites!'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          nopeAction: () {
            // Optional: Add any logic for left swipe
          },
        ),
      );
    }
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null
            ? JokeCategory.allCategories
                .firstWhere((c) => c.id == widget.category)
                .name
            : 'Jokes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                if (_swipeItems.isEmpty)
                  const Center(child: Text('No more jokes!'))
                else
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SwipeCards(
                      matchEngine: _matchEngine,
                      itemBuilder: (context, index) {
                        final joke = _swipeItems[index].content as Joke;
                        return JokeCard(
                          joke: joke,
                          isFavorite: _favoritesRepository.isFavorite(joke.id),
                        );
                      },
                      onStackFinished: () {
                        setState(() {
                          _swipeItems.clear();
                        });
                        _loadJokes();
                      },
                      itemChanged: (SwipeItem item, int index) {
                        if (_swipeItems.length - index <= _minimumJokes &&
                            !_isLoadingMore) {
                          _loadJokes();
                        }
                      },
                    ),
                  ),
                if (_isLoadingMore)
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Loading more jokes...'),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _SwipeButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _SwipeButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
