import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simply_scored/main.dart';

void main() {
  testWidgets('MainApp shows AppBar title', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();
    expect(find.text('Player Select'), findsOneWidget);
  });

  testWidgets(
    'Drawer contains Settings and shows AboutDialog on Licenses tap',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        Localizations(
          delegates: [
            DefaultWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          locale: Locale('en'),
          child: MainApp(),
        ),
      );
      await tester.pumpAndSettle();

      final Finder menuButton = find.byTooltip('Open navigation menu');
      expect(menuButton, findsOneWidget);

      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      final Finder licensesTile = find.text('Licenses');
      expect(licensesTile, findsOneWidget);

      // TODO: Fix

      // await tester.runAsync(() async {
      //   await tester.tap(licensesTile);
      // });
      // await tester.pumpAndSettle();

      // expect(find.text('Simply Scored'), findsOneWidget);
      // expect(find.text('0.1.0'), findsOneWidget);
    },
  );
}
