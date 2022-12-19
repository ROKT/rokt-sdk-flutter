import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import '../lib/main.dart' as app;

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
      expect(tester.getSize(roktWidget1).height, equals(double.minPositive));

      final roktWidget2 = find.byKey(const ValueKey('widget2'));
      expect(tester.getSize(roktWidget2).height, equals(double.minPositive));

      final Finder execute = find.text('Execute');

      await tester.tap(execute);
      await addDelay(3000);
      await tester.pumpAndSettle();

      //expect(tester.getSize(roktWidget1).height, greaterThan(200.0));

      final scrollView = find.byType(CustomScrollView);
      await tester.dragUntilVisible(roktWidget2, scrollView, Offset(0, -500));
      expect(roktWidget2, findsOneWidget);
      //expect(tester.getSize(roktWidget2).height, greaterThan(200.0));
    });
  });
}

Future<void> addDelay(int ms) async {
  await Future<void>.delayed(Duration(milliseconds: ms));
}
