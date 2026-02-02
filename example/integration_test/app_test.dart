import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:rokt_sdk_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets(
        'given the default account when execute is called verify embedded rokt widgets are loading',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Initial'), findsOneWidget);

      final Finder init = find.text('Initial');
      await tester.tap(init);
      await addDelay(3000);
      await tester.pumpAndSettle();

      final roktWidget1 = find.byKey(const ValueKey('widget1'));
      expect(tester.getSize(roktWidget1).height, equals(1));

      final roktWidget2 = find.byKey(const ValueKey('widget2'));
      expect(tester.getSize(roktWidget2).height, equals(1));

      final Finder execute = find.text('Execute');
      await tester.tap(execute);

      // Add longer delay after execute to ensure placement is fully ready
      await addDelay(8000);
      await tester.pumpAndSettle();

      // Add additional pump to ensure widget rebuilds
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify widget1 height
      final widget1Height = tester.getSize(roktWidget1).height;
      // ignore: avoid_print
      print('Widget1 height after execute: $widget1Height');
      expect(widget1Height, greaterThan(2.0));

      final scrollView = find.byType(CustomScrollView);
      await tester.dragUntilVisible(
          roktWidget2, scrollView, const Offset(0, -500));

      // Add delay after scrolling
      await addDelay(2000);
      await tester.pumpAndSettle();

      expect(roktWidget2, findsOneWidget);

      // Verify widget2 height
      final widget2Height = tester.getSize(roktWidget2).height;
      // ignore: avoid_print
      print('Widget2 height after scroll: $widget2Height');
      expect(widget2Height, greaterThan(2.0));
    });
  });
}

Future<void> addDelay(int ms) async {
  await Future<void>.delayed(Duration(milliseconds: ms));
}
