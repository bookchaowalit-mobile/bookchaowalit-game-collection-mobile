import 'package:flutter_test/flutter_test.dart';
import 'package:game_collection/logic/collection.dart';

void main() {
  const games = [
    Game(
        id: 1,
        title: 'Zelda',
        platform: 'Switch',
        status: GameStatus.playing,
        rating: 5),
    Game(
        id: 2,
        title: 'celeste',
        platform: 'PC',
        status: GameStatus.completed,
        rating: 4),
    Game(id: 3, title: 'Hades', platform: 'PC'),
  ];

  test('validateGame', () {
    expect(validateGame(' ', 'PC', games), 'Title is required');
    expect(validateGame('X', '', games), 'Platform is required');
    expect(validateGame('HADES', 'pc', games), contains('already'));
    expect(validateGame('Hades', 'Switch', games), isNull);
  });

  test('filterGames sorts by title and filters', () {
    expect(filterGames(games).map((g) => g.id), [2, 3, 1]);
    expect(
        filterGames(games, status: GameStatus.backlog).map((g) => g.id), [3]);
    expect(filterGames(games, query: 'EL').map((g) => g.id), [2, 1]);
  });

  test('statsOf', () {
    final s = statsOf(games);
    expect(s.total, 3);
    expect(s.byStatus[GameStatus.backlog], 1);
    expect(s.averageRating, 4.5);
    expect(s.completionRate, closeTo(1 / 3, 1e-9));
    expect(statsOf(const []).averageRating, isNull);
    expect(statsOf(const []).completionRate, 0);
  });

  test('copyWith updates status and rating', () {
    final g = games[2].copyWith(status: GameStatus.completed, rating: 3);
    expect(g.status, GameStatus.completed);
    expect(g.rating, 3);
    expect(g.copyWith(clearRating: true).rating, isNull);
  });
}
