// dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simply_scored/components/gamecreation.dart';
import 'package:simply_scored/components/scoreboard.dart';

Future<void> pumpGameCreation(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(home: PlayerNameInputList()));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('shows "No players yet!" when list is empty', (
    WidgetTester tester,
  ) async {
    await pumpGameCreation(tester);
    expect(find.text('No players yet!'), findsOneWidget);
  });

  testWidgets('adding a player updates UI and persists', (
    WidgetTester tester,
  ) async {
    await pumpGameCreation(tester);

    final nameField = find.byType(TextField);
    final addButton = find.widgetWithText(ElevatedButton, 'Add Player');

    await tester.enterText(nameField, 'Alice');
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // UI contains the player
    expect(find.text('Alice'), findsOneWidget);

    // TextField cleared
    final TextField tf = tester.widget(nameField);
    expect(tf.controller?.text ?? '', isEmpty);

    // Prefs persisted
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('players') ?? [];
    expect(stored, contains('Alice'));
    expect(stored.length, 1);
  });

  // testWidgets('adding duplicate name is ignored', (WidgetTester tester) async {
  //   await pumpGameCreation(tester);

  //   final nameField = find.byType(TextField);
  //   final addButton = find.widgetWithText(ElevatedButton, 'Add Player');

  //   await tester.enterText(nameField, 'Bob');
  //   await tester.tap(addButton);
  //   await tester.pumpAndSettle();

  //   await tester.enterText(nameField, 'Bob');
  //   await tester.tap(addButton);
  //   await tester.pumpAndSettle();

  //   // Only one Bob appears
  //   expect(find.text('Bob'), findsOneWidget);

  //   final prefs = await SharedPreferences.getInstance();
  //   final stored = prefs.getStringList('players') ?? [];
  //   expect(stored.where((s) => s == 'Bob').length, 1);
  // });

  testWidgets('removing a player updates UI and prefs', (
    WidgetTester tester,
  ) async {
    await pumpGameCreation(tester);

    final nameField = find.byType(TextField);
    final addButton = find.widgetWithText(ElevatedButton, 'Add Player');

    await tester.enterText(nameField, 'Carol');
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Find the Remove button next to Carol
    final removeButton = find.widgetWithText(FilledButton, 'Remove').first;
    await tester.tap(removeButton);
    await tester.pumpAndSettle();

    expect(find.text('Carol'), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('players') ?? [];
    expect(stored, isEmpty);
  });

  testWidgets('pressing FAB with no players shows snackbar', (
    WidgetTester tester,
  ) async {
    await pumpGameCreation(tester);

    final fab = find.byType(FloatingActionButton);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.text('Please add at least one player.'), findsOneWidget);
  });

  testWidgets('pressing FAB with players navigates to ScoreSheetsTable', (
    WidgetTester tester,
  ) async {
    await pumpGameCreation(tester);

    final nameField = find.byType(TextField);
    final addButton = find.widgetWithText(ElevatedButton, 'Add Player');

    await tester.enterText(nameField, 'Dave');
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // ScoreSheetsTable uses AppBar title 'Score Sheets'
    expect(find.text('Score Sheets'), findsOneWidget);
    // Also verify the passed player name appears as a column header
    expect(find.text('Dave'), findsOneWidget);
  });
}
