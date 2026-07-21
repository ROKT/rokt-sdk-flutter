import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rokt_sdk_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets(
        'given the default account when selectPlacements is called verify embedded rokt widget loads',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Initialize'), findsOneWidget);

      final Finder init = find.text('Initialize');
      await tester.tap(init);
      await addDelay(5000);
      await tester.pumpAndSettle();

      final roktWidget1 = find.byKey(const ValueKey('widget1'));
      expect(tester.getSize(roktWidget1).height, equals(1));

      final Finder selectPlacements = find.text('Select Placements');
      await tester.tap(selectPlacements);

      final widget1Height = await pollWidgetHeight(
        tester: tester,
        widget: roktWidget1,
        timeout: const Duration(seconds: 90),
      );

      // ignore: avoid_print
      print('Widget1 height after selectPlacements: $widget1Height');
      expect(widget1Height, greaterThan(2.0));
    });
  });
}

Future<void> addDelay(int ms) async {
  await Future<void>.delayed(Duration(milliseconds: ms));
}

Future<double> pollWidgetHeight({
  required WidgetTester tester,
  required Finder widget,
  required Duration timeout,
}) async {
  final deadline = DateTime.now().add(timeout);
  var height = tester.getSize(widget).height;

  while (height <= 2.0 && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(seconds: 1));
    height = tester.getSize(widget).height;
  }

  return height;
}
