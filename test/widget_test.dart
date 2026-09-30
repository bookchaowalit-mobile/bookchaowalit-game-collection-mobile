import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game_collection/main.dart';
import 'package:game_collection/screens/home_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('app shell shows collection and about tab', (tester) async {
    await tester.pumpWidget(const GameCollectionApp());
    await tester.pumpAndSettle();
    expect(find.text('Game Collection'), findsWidgets);
    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();
    expect(find.text('Features'), findsOneWidget);
  });

  testWidgets('add a game, mark completed and rate', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-game')));
    await tester.pump();
    expect(find.text('Title is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('title-input')), 'Hades');
    await tester.enterText(find.byKey(const Key('platform-input')), 'PC');
    await tester.tap(find.byKey(const Key('add-game')));
    await tester.pump();
    String stats() => tester.widget<Text>(find.byKey(const Key('stats'))).data!;
    expect(stats(), '1 game · 1 backlog · 0 playing · 0 completed');

    await tester.tap(find.byTooltip('Change Hades'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark completed'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Change Hades'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rate 4★'));
    await tester.pumpAndSettle();
    expect(stats(), '1 game · 0 backlog · 0 playing · 1 completed · avg 4.0★');
  });

  Widget home({double textScale = 1}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: const HomeScreen(),
        ),
      );

  Future<void> addGame(
      WidgetTester tester, String title, String platform) async {
    await tester.enterText(find.byKey(const Key('title-input')), title);
    await tester.enterText(find.byKey(const Key('platform-input')), platform);
    await tester.tap(find.byKey(const Key('add-game')));
    await tester.pump();
  }

  testWidgets('duplicate with extra spaces is rejected', (tester) async {
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await addGame(tester, 'Zelda BotW', 'Switch');
    await addGame(tester, '  zelda   botw ', 'switch');
    expect(
        find.text('That game is already in your collection'), findsOneWidget);
    expect(find.text('Zelda BotW'), findsOneWidget);
  });

  testWidgets('filter with no matches shows a message', (tester) async {
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await addGame(tester, 'Hades', 'PC');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Completed'));
    await tester.pump();
    expect(find.text('No games match this filter.'), findsOneWidget);
    expect(find.text('Your collection is empty.'), findsNothing);
  });

  testWidgets('rating can be cleared and delete can be undone', (
    tester,
  ) async {
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await addGame(tester, 'Hades', 'PC');
    await tester.tap(find.byTooltip('Change Hades'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rate 5★'));
    await tester.pumpAndSettle();
    expect(find.text('PC · 5★'), findsOneWidget);
    await tester.tap(find.byTooltip('Change Hades'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Clear rating'));
    await tester.pumpAndSettle();
    expect(find.text('PC · unrated'), findsOneWidget);

    await tester.tap(find.byTooltip('Change Hades'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Your collection is empty.'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Hades'), findsOneWidget);
  });

  testWidgets('ratings are announced in words', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await addGame(tester, 'Hades', 'PC');
    await tester.tap(find.byTooltip('Change Hades'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rate 3★'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp('rated 3 of 5 stars')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(home());
    await tester.pumpAndSettle();
    await addGame(tester, 'Hades', 'PC');
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('lays out at 200% text scale without overflow', (tester) async {
    await tester.pumpWidget(home(textScale: 2));
    await tester.pumpAndSettle();
    await addGame(tester, 'Hades', 'PC');
    expect(tester.takeException(), isNull);
  });
}
