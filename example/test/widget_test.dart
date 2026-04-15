import 'package:flutter/material.dart';
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

    // Mock the EventChannel's internal MethodChannel to prevent
    // MissingPluginException during receiveBroadcastStream().
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('RoktEvents'),
      (MethodCall methodCall) async => null,
    );

    await tester.pumpWidget(const MyApp());

    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget is Text && widget.data!.startsWith('Location 1'),
      ),
      findsOneWidget,
    );

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
