library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:simply_scored/components/scoreboard.dart';
import 'package:simply_scored/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Screenshot:', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
    });
    _screenshot('PlayerSelect', home: MainApp());
    _screenshot(
      'Scoresheet',
      home: MaterialApp(
        home: ScoreSheetsTable(players: ['Me', 'You', 'Somebody']),
      ),
    );
  });
}

void _screenshot(
  String description, {
  required Widget home,
  Future<void> Function(WidgetTester tester)? beforeScreenshot,
}) {
  group(description, () {
    testGoldens('for ${GoldenScreenshotDevices.androidPhone.name}', (
      tester,
    ) async {
      final device = GoldenScreenshotDevices.androidPhone.device;

      await tester.pumpWidget(home);

      // One of our tests needs to interact with the UI before taking the screenshot.
      await beforeScreenshot?.call(tester);

      // Precache the images and fonts so they're ready for the screenshot.
      await tester.loadAssets();

      await tester.pumpAndSettle();

      // Take the screenshot and compare it to the golden file.
      await tester.expectScreenshot(device, description);
    });
  });
}
