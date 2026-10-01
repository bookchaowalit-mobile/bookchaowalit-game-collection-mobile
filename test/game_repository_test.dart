import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_collection/data/list_repository.dart';
import 'package:game_collection/data/game_repository.dart';
import 'package:game_collection/logic/collection.dart';
import 'package:game_collection/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const sample = Game(
    id: 4,
    title: 'Zelda',
    platform: 'Switch',
    status: GameStatus.playing,
    rating: 5,
  );

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('round-trips games through shared_preferences', () async {
    await deviceGameRepository.save([sample]);
    final loaded = await deviceGameRepository.load();
    expect(loaded, hasLength(1));
    expect(loaded.single.toJson(), sample.toJson());
  });

  test('empty storage loads an empty list', () async {
    expect(await deviceGameRepository.load(), isEmpty);
  });

  test('skips malformed records and rejects non-list payloads', () async {
    SharedPreferences.setMockInitialValues({
      'game_collection_games_v1': jsonEncode([
        sample.toJson(),
        {'id': 'x'},
        42,
      ]),
    });
    expect(await deviceGameRepository.load(), hasLength(1));

    SharedPreferences.setMockInitialValues({'game_collection_games_v1': '{}'});
    expect(deviceGameRepository.load(), throwsFormatException);
  });

  testWidgets('home screen restores saved games and saves changes',
      (tester) async {
    final repo = InMemoryListRepository<Game>([sample]);
    await tester.pumpWidget(MaterialApp(home: HomeScreen(repository: repo)));
    await tester.pumpAndSettle();
    expect(find.text('Zelda'), findsWidgets);

    await tester.tap(find.byTooltip('Change Zelda'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(await repo.load(), isEmpty);
  });

  testWidgets('shows an error when saved games cannot be read', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(repository: _FailingRepository())),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('storage-error')), findsOneWidget);
  });
}

class _FailingRepository implements ListRepository<Game> {
  @override
  Future<List<Game>> load() async => throw const FormatException('bad');

  @override
  Future<void> save(List<Game> items) async => throw StateError('full');
}
