// lib/components/scoreboard_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simply_scored/components/scoreboard.dart';

void main() {
  Future<void> pumpScoreboard(
    WidgetTester tester, {
    required List<String> players,
    int initialTurns = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScoreSheetsTable(players: players, initialTurns: initialTurns),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders header and initial turns', (WidgetTester tester) async {
    await pumpScoreboard(tester, players: ['Alice', 'Bob'], initialTurns: 2);

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Turn 1'), findsOneWidget);
    expect(find.text('Turn 2'), findsOneWidget);
  });

  // TODO: Fix

  // testWidgets('add and remove turns update rows', (WidgetTester tester) async {
  //   await pumpScoreboard(tester, players: ['P1', 'P2'], initialTurns: 2);

  //   final addButton = find.widgetWithText(ElevatedButton, 'Add Turn');
  //   final removeButton = find.widgetWithText(ElevatedButton, 'Remove Turn');

  //   expect(find.text('Turn 3'), findsNothing);

  //   await tester.tap(addButton);
  //   await tester.pumpAndSettle();

  //   expect(find.text('Turn 3'), findsOneWidget);

  //   await tester.tap(removeButton);
  //   await tester.pumpAndSettle();

  //   expect(find.text('Turn 3'), findsNothing);
  // });

  testWidgets('entering scores updates totals', (WidgetTester tester) async {
    await pumpScoreboard(tester, players: ['Alice', 'Bob'], initialTurns: 2);

    // There should be 4 TextFields (2 turns * 2 players)
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(4));

    // Enter scores in row-major order: [5,3,2,4]
    await tester.enterText(fields.at(0), '5'); // Turn1 Alice
    await tester.pump();
    await tester.enterText(fields.at(1), '3'); // Turn1 Bob
    await tester.pump();
    await tester.enterText(fields.at(2), '2'); // Turn2 Alice
    await tester.pump();
    await tester.enterText(fields.at(3), '4'); // Turn2 Bob
    await tester.pumpAndSettle();

    // Totals row should show 7 for Alice and 7 for Bob
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('7'), findsNWidgets(2));
  });

  testWidgets('submitting last field adds a new turn', (
    WidgetTester tester,
  ) async {
    await pumpScoreboard(tester, players: ['Solo'], initialTurns: 1);

    // Initially 1 TextField
    expect(find.byType(TextField), findsOneWidget);

    final field = find.byType(TextField).first;
    await tester.tap(field);
    await tester.pumpAndSettle();

    // Enter text and simulate submit action
    tester.testTextInput.enterText('9');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // A new turn should have been added, resulting in 2 TextFields
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
