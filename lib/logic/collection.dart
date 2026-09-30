/// Game collection model, filtering and stats.
library;

enum GameStatus {
  backlog('Backlog'),
  playing('Playing'),
  completed('Completed');

  const GameStatus(this.label);
  final String label;
}

class Game {
  const Game({
    required this.id,
    required this.title,
    required this.platform,
    this.status = GameStatus.backlog,
    this.rating,
  }) : assert(rating == null || (rating >= 1 && rating <= 5));

  final int id;
  final String title;
  final String platform;
  final GameStatus status;

  /// 1-5 stars, or null when unrated.
  final int? rating;

  Game copyWith({GameStatus? status, int? rating, bool clearRating = false}) =>
      Game(
        id: id,
        title: title,
        platform: platform,
        status: status ?? this.status,
        rating: clearRating ? null : (rating ?? this.rating),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'platform': platform,
        'status': status.name,
        'rating': rating,
      };

  /// Throws on malformed input (wrong types, unknown status, rating out of
  /// range) so the repository can skip the record.
  static Game fromJson(Map<String, Object?> json) {
    final rating = json['rating'] as int?;
    if (rating != null && (rating < 1 || rating > 5)) {
      throw FormatException('Rating out of range: $rating');
    }
    return Game(
      id: json['id'] as int,
      title: json['title'] as String,
      platform: json['platform'] as String,
      status: GameStatus.values.byName(json['status'] as String),
      rating: rating,
    );
  }
}

Map<String, Object?> gameToJson(Game game) => game.toJson();

String? validateGame(String title, String platform, Iterable<Game> existing) {
  final t = title.trim();
  if (t.isEmpty) return 'Title is required';
  if (t.length > 100) return 'Title must be at most 100 characters';
  if (platform.trim().isEmpty) return 'Platform is required';
  final dup = existing.any(
    (g) =>
        g.title.toLowerCase() == t.toLowerCase() &&
        g.platform.toLowerCase() == platform.trim().toLowerCase(),
  );
  if (dup) return 'That game is already in your collection';
  return null;
}

List<Game> filterGames(
  Iterable<Game> games, {
  GameStatus? status,
  String query = '',
}) {
  final q = query.trim().toLowerCase();
  final list = games
      .where((g) => status == null || g.status == status)
      .where((g) => q.isEmpty || g.title.toLowerCase().contains(q))
      .toList()
    ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  return list;
}

class CollectionStats {
  const CollectionStats(this.total, this.byStatus, this.averageRating);

  final int total;
  final Map<GameStatus, int> byStatus;

  /// Mean of rated games, or null if none are rated.
  final double? averageRating;

  double get completionRate =>
      total == 0 ? 0 : (byStatus[GameStatus.completed] ?? 0) / total;
}

CollectionStats statsOf(Iterable<Game> games) {
  final by = {for (final s in GameStatus.values) s: 0};
  var total = 0;
  var ratedSum = 0;
  var ratedCount = 0;
  for (final g in games) {
    total++;
    by[g.status] = by[g.status]! + 1;
    if (g.rating != null) {
      ratedSum += g.rating!;
      ratedCount++;
    }
  }
  return CollectionStats(
    total,
    by,
    ratedCount == 0 ? null : ratedSum / ratedCount,
  );
}
