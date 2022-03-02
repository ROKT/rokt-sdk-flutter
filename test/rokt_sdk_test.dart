import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rokt_sdk/rokt_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('rokt_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await RoktSdk.platformVersion, '42');
  });
}
