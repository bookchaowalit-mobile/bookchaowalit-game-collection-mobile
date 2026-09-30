import 'package:flutter/material.dart';

import '../logic/collection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Game> _games = [];
  final _title = TextEditingController();
  final _platform = TextEditingController();
  final _query = TextEditingController();
  GameStatus? _filter;
  String? _error;
  int _nextId = 1;

  @override
  void dispose() {
    _title.dispose();
    _platform.dispose();
    _query.dispose();
    super.dispose();
  }

  void _add() {
    final error = validateGame(_title.text, _platform.text, _games);
    setState(() {
      _error = error;
      if (error != null) return;
      _games.add(
        Game(
          id: _nextId++,
          title: _title.text.trim(),
          platform: _platform.text.trim(),
        ),
      );
      _title.clear();
    });
  }

  void _update(Game g, Game updated) {
    setState(() => _games[_games.indexOf(g)] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stats = statsOf(_games);
    final visible = filterGames(_games, status: _filter, query: _query.text);
    return Scaffold(
      appBar: AppBar(title: const Text('Game Collection')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  key: const Key('title-input'),
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  key: const Key('platform-input'),
                  controller: _platform,
                  decoration: const InputDecoration(labelText: 'Platform'),
                ),
              ),
              IconButton(
                key: const Key('add-game'),
                tooltip: 'Add game',
                icon: const Icon(Icons.add),
                onPressed: _add,
              ),
            ],
          ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 12),
          Text(
            '${stats.total} games · '
            '${GameStatus.values.map((s) => '${stats.byStatus[s]} ${s.label.toLowerCase()}').join(' · ')}'
            '${stats.averageRating == null ? '' : ' · avg ${stats.averageRating!.toStringAsFixed(1)}★'}',
            key: const Key('stats'),
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              for (final s in GameStatus.values)
                ChoiceChip(
                  label: Text(s.label),
                  selected: _filter == s,
                  onSelected: (_) => setState(() => _filter = s),
                ),
            ],
          ),
          TextField(
            controller: _query,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search titles',
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_games.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('Your collection is empty.',
                  textAlign: TextAlign.center),
            ),
          for (final g in visible)
            Card(
              child: ListTile(
                title: Text(g.title),
                subtitle: Text(
                  '${g.platform} · ${g.rating == null ? 'unrated' : '${g.rating}★'}',
                ),
                trailing: PopupMenuButton<String>(
                  tooltip: 'Change ${g.title}',
                  onSelected: (v) {
                    if (v == 'delete') {
                      setState(() => _games.remove(g));
                    } else if (v.startsWith('status:')) {
                      _update(
                        g,
                        g.copyWith(
                            status: GameStatus.values.byName(v.substring(7))),
                      );
                    } else if (v.startsWith('rate:')) {
                      _update(g, g.copyWith(rating: int.parse(v.substring(5))));
                    }
                  },
                  itemBuilder: (_) => [
                    for (final s in GameStatus.values)
                      PopupMenuItem(
                          value: 'status:${s.name}',
                          child: Text('Mark ${s.label.toLowerCase()}')),
                    for (var r = 1; r <= 5; r++)
                      PopupMenuItem(value: 'rate:$r', child: Text('Rate $r★')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  child: Chip(label: Text(g.status.label)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
