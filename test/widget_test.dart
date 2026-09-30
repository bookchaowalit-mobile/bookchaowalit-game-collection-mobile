import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:game_collection/main.dart';
import 'package:game_collection/screens/home_screen.dart';

void main() {
  testWidgets('app shell shows collection and about tab', (tester) async {
    await tester.pumpWidget(const GameCollectionApp());
    expect(find.text('Game Collection'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('add a game, mark completed and rate', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.tap(find.byKey(const Key('add-game')));
    await tester.pump();
    expect(find.text('Title is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('title-input')), 'Hades');
    await tester.enterText(find.byKey(const Key('platform-input')), 'PC');
    await tester.tap(find.byKey(const Key('add-game')));
    await tester.pump();
    String stats() => tester.widget<Text>(find.byKey(const Key('stats'))).data!;
    expect(stats(), '1 games · 1 backlog · 0 playing · 0 completed');

    await tester.tap(find.byTooltip('Change Hades'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark completed'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Change Hades'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rate 4★'));
    await tester.pumpAndSettle();
    expect(stats(), '1 games · 0 backlog · 0 playing · 1 completed · avg 4.0★');
  });
}
