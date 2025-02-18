import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/joke.dart';
import '../repositories/favorites_repository.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final repository = FavoritesRepository();
  String? _selectedSource;
  _SortOrder _sortOrder = _SortOrder.newest;

  List<Joke> _getFilteredAndSortedJokes(List<Joke> jokes) {
    var filteredJokes = _selectedSource == null
        ? jokes
        : jokes.where((joke) => joke.source == _selectedSource).toList();

    switch (_sortOrder) {
      case _SortOrder.newest:
        filteredJokes.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      case _SortOrder.oldest:
        filteredJokes.sort((a, b) => a.savedAt.compareTo(b.savedAt));
      case _SortOrder.shortest:
        filteredJokes
            .sort((a, b) => a.content.length.compareTo(b.content.length));
      case _SortOrder.longest:
        filteredJokes
            .sort((a, b) => b.content.length.compareTo(a.content.length));
    }

    return filteredJokes;
  }

  List<String> _getUniqueSources(List<Joke> jokes) {
    return jokes.map((joke) => joke.source).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearDialog(context, repository),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: repository.boxListenable,
        builder: (context, box, _) {
          final allJokes = repository.getAllFavorites();
          final jokes = _getFilteredAndSortedJokes(allJokes);
          final sources = _getUniqueSources(allJokes);

          if (allJokes.isEmpty) {
            return const EmptyFavoritesView();
          }

          return Column(
            children: [
              _buildFilterBar(sources),
              Expanded(
                child: ListView.builder(
                  itemCount: jokes.length,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemBuilder: (context, index) => _buildJokeCard(jokes[index]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(List<String> sources) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedSource == null,
                  onSelected: (selected) {
                    setState(() => _selectedSource = null);
                  },
                ),
                const SizedBox(width: 8),
                ...sources.map(
                  (source) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(source),
                      selected: _selectedSource == source,
                      onSelected: (selected) {
                        setState(() {
                          _selectedSource = selected ? source : null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SortChip(
                  label: 'Newest',
                  icon: Icons.arrow_upward,
                  selected: _sortOrder == _SortOrder.newest,
                  onSelected: () =>
                      setState(() => _sortOrder = _SortOrder.newest),
                ),
                const SizedBox(width: 8),
                _SortChip(
                  label: 'Oldest',
                  icon: Icons.arrow_downward,
                  selected: _sortOrder == _SortOrder.oldest,
                  onSelected: () =>
                      setState(() => _sortOrder = _SortOrder.oldest),
                ),
                const SizedBox(width: 8),
                _SortChip(
                  label: 'Shortest',
                  icon: Icons.short_text,
                  selected: _sortOrder == _SortOrder.shortest,
                  onSelected: () =>
                      setState(() => _sortOrder = _SortOrder.shortest),
                ),
                const SizedBox(width: 8),
                _SortChip(
                  label: 'Longest',
                  icon: Icons.subject,
                  selected: _sortOrder == _SortOrder.longest,
                  onSelected: () =>
                      setState(() => _sortOrder = _SortOrder.longest),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJokeCard(Joke joke) {
    return Dismissible(
      key: Key(joke.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: Icon(
          Icons.delete,
          color: Colors.red.shade700,
        ),
      ),
      onDismissed: (_) {
        repository.removeFavorite(joke.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Joke removed from favorites'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showJokeDetails(context, joke),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        joke.source,
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeago.format(joke.savedAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  joke.content,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (joke.content.length > 150) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap to read more',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showJokeDetails(BuildContext context, Joke joke) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      joke.source,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    timeago.format(joke.savedAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    joke.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showClearDialog(
    BuildContext context,
    FavoritesRepository repository,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear all favorites?'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to remove all your favorite jokes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );

    if (result == true) {
      await repository.clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All favorites cleared')),
        );
      }
    }
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onSelected;

  const _SortChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected
                ? Theme.of(context).colorScheme.onSecondaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class EmptyFavoritesView extends StatelessWidget {
  const EmptyFavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Swipe right on jokes you like to save them',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

enum _SortOrder {
  newest,
  oldest,
  shortest,
  longest,
}
