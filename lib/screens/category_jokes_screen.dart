import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../models/joke.dart';
import '../models/joke_category.dart';
import '../services/jokes_service.dart';
import '../widgets/joke_card.dart';
import '../repositories/favorites_repository.dart';

class CategoryJokesScreen extends StatefulWidget {
  final String categoryId;

  const CategoryJokesScreen({
    super.key,
    required this.categoryId,
  });

  @override
  State<CategoryJokesScreen> createState() => _CategoryJokesScreenState();
}

class _CategoryJokesScreenState extends State<CategoryJokesScreen> {
  final JokesService _jokesService = JokesService();
  final FavoritesRepository _favoritesRepository = FavoritesRepository();
  late MatchEngine _matchEngine;
  final List<SwipeItem> _swipeItems = [];
  final List<Joke> _jokes = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  static const int _minimumJokes = 5;
  static const int _batchSize = 10;
  late final JokeCategory category;

  @override
  void initState() {
    super.initState();
    category = JokeCategory.allCategories.firstWhere(
      (c) => c.id == widget.categoryId,
    );
    _initialLoad();
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
          (_) => _jokesService.getRandomJoke(category: widget.categoryId),
        ),
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
        title: Row(
          children: [
            Icon(category.icon, color: category.color),
            const SizedBox(width: 8),
            Text(category.name),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  if (_swipeItems.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sentiment_dissatisfied,
                            size: 64,
                            color: Theme.of(context).disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No more jokes!',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SwipeCards(
                        matchEngine: _matchEngine,
                        itemBuilder: (context, index) {
                          final joke = _swipeItems[index].content as Joke;
                          return JokeCard(
                            joke: joke,
                            isFavorite:
                                _favoritesRepository.isFavorite(joke.id),
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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
      ),
    );
  }
}
