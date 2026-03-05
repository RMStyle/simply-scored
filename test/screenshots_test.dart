library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_screenshot/golden_screenshot.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simply_scored/components/scoreboard.dart';
import 'package:simply_scored/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Screenshot:', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    Map<String, Object> mockValues = {
      'players': ['Me', 'You', 'Somebody'],
    };
    setUpAll(() async {
      SharedPreferences.setMockInitialValues(mockValues);
      PackageInfo.setMockInitialValues(
        appName: 'Simply Scored',
        packageName: 'com.simplyscored',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: 'signature',
      );
    });
    _screenshot('PlayerSelect', home: HomePage());
    _screenshot(
      'Scoresheet',
      home: ScoreSheetsTable(players: ['Me', 'You', 'Somebody']),
      beforeScreenshot: (tester) async {
        await tester.enterText(find.byType(TextField).at(0), '10');
        await tester.enterText(find.byType(TextField).at(1), '20');
        await tester.enterText(find.byType(TextField).at(2), '30');
        await tester.pumpAndSettle();
      },
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

      final app = ScreenshotApp(device: device, home: home);

      await tester.pumpWidget(app);

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
