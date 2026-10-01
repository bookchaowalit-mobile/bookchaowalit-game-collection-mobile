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

  group('edge cases (pass 3)', () {
    test('duplicates ignore case and repeated whitespace', () {
      expect(validateGame('  zelda ', ' SWITCH ', games), isNotNull);
      expect(validateGame('Zel  da', 'Switch', games), isNull);
      const spaced = [Game(id: 9, title: 'Hollow  Knight', platform: 'PC')];
      expect(validateGame('hollow knight', 'pc', spaced), isNotNull);
      expect(validateGame('Zelda', 'Wii U', games), isNull);
    });

    test('title limit counts visible characters', () {
      expect(validateGame('🎮' * 100, 'PC', const []), isNull);
      expect(validateGame('🎮' * 101, 'PC', const []), contains('at most'));
      expect(validateGame(' \t ', 'PC', const []), 'Title is required');
      expect(validateGame('X', '  ', const []), 'Platform is required');
    });

    test('empty collection stats', () {
      final s = statsOf(const []);
      expect(s.total, 0);
      expect(s.averageRating, isNull);
      expect(s.completionRate, 0);
      expect(s.byStatus.values, everyElement(0));
    });

    test('average ignores unrated games', () {
      expect(statsOf(games).averageRating, 4.5);
      expect(statsOf(games).completionRate, closeTo(1 / 3, 1e-12));
    });

    test('filter handles Thai titles and whitespace queries', () {
      const thai = [
        Game(id: 1, title: 'ผจญภัย', platform: 'PC'),
        Game(id: 2, title: 'Abc', platform: 'PC'),
      ];
      expect(filterGames(thai, query: 'ผจญ').single.id, 1);
      expect(filterGames(thai, query: '   '), hasLength(2));
    });

    test('fromJson rejects bad records', () {
      final base = const Game(id: 1, title: 't', platform: 'p').toJson();
      expect(
          () => Game.fromJson({...base, 'rating': 0}), throwsFormatException);
      expect(
          () => Game.fromJson({...base, 'rating': 6}), throwsFormatException);
      expect(() => Game.fromJson({...base, 'status': 'lost'}),
          throwsArgumentError);
      expect(
          () => Game.fromJson({...base, 'id': '1'}), throwsA(isA<TypeError>()));
      expect(Game.fromJson({...base, 'title': 'ไทย 🎮'}).title, 'ไทย 🎮');
    });

    test('copyWith clearRating wins over a new rating', () {
      const g = Game(id: 1, title: 't', platform: 'p', rating: 3);
      expect(g.copyWith(rating: 5, clearRating: true).rating, isNull);
      expect(g.copyWith(status: GameStatus.playing).rating, 3);
    });
  });
}
