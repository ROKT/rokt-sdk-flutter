import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rokt_sdk_example/main.dart';

void main() {
  testWidgets('Verify Platform version', (WidgetTester tester) async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('rokt_sdk'),
      (MethodCall methodCall) async => 'success',
    );

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('RoktEvents'),
      (MethodCall methodCall) async => null,
    );

    await tester.pumpWidget(const MyApp());

    expect(find.text('Plugin example app'), findsOneWidget);
    expect(find.text('Initialize'), findsOneWidget);
    expect(find.text('Select Placements'), findsOneWidget);

    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('rokt_sdk'),
      null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('RoktEvents'),
      null,
    );
  });
}
