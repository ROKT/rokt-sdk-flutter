import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rokt_sdk/rokt_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('rokt_sdk');
  final List<MethodCall> log = <MethodCall>[];

  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    log.clear();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'getSessionId') {
        return 'test-session-id';
      }
      return 'success';
    });
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  group('initialize', () {
    test('sends correct arguments with defaults', () async {
      await RoktSdk.initialize('test-tag-id');

      expect(log, hasLength(1));
      expect(log.first.method, 'initialize');
      expect(log.first.arguments['roktTagId'], 'test-tag-id');
      expect(log.first.arguments['appVersion'], '');
      expect(log.first.arguments['fontFilePathMap'], isEmpty);
    });

    test('sends correct arguments with custom values', () async {
      await RoktSdk.initialize(
        'my-tag',
        appVersion: '2.0.0',
        fontFilePathMap: {'Arial-Bold': 'fonts/Arial-Bold.ttf'},
      );

      expect(log.first.arguments['roktTagId'], 'my-tag');
      expect(log.first.arguments['appVersion'], '2.0.0');
      expect(
        log.first.arguments['fontFilePathMap'],
        {'Arial-Bold': 'fonts/Arial-Bold.ttf'},
      );
    });
  });

  group('selectPlacements', () {
    test('sends correct arguments with defaults', () async {
      await RoktSdk.selectPlacements(viewName: 'TestView');

      expect(log, hasLength(1));
      expect(log.first.method, 'selectPlacements');
      expect(log.first.arguments['viewName'], 'TestView');
      expect(log.first.arguments['attributes'], isEmpty);
    });

    test('sends attributes and config', () async {
      await RoktSdk.selectPlacements(
        viewName: 'ConfirmationPage',
        attributes: {'email': 'test@example.com', 'firstname': 'John'},
        roktConfig: const RoktConfig(
          colorMode: ColorMode.dark,
          cacheConfig: CacheConfig(cacheDurationInSeconds: 3600),
        ),
      );

      expect(log.first.arguments['viewName'], 'ConfirmationPage');
      expect(log.first.arguments['attributes'], {
        'email': 'test@example.com',
        'firstname': 'John',
      });

      final config = log.first.arguments['config'] as Map<Object?, Object?>;
      expect(config['colorMode'], 'dark');

      final cacheConfig = config['cacheConfig']! as Map<Object?, Object?>;
      expect(cacheConfig['cacheDurationInSeconds'], 3600);
    });
  });

  group('selectShoppableAds', () {
    test('sends correct arguments with defaults', () async {
      await RoktSdk.selectShoppableAds(viewName: 'ShoppablePage');

      expect(log, hasLength(1));
      expect(log.first.method, 'selectShoppableAds');
      expect(log.first.arguments['viewName'], 'ShoppablePage');
      expect(log.first.arguments['attributes'], isEmpty);
    });

    test('sends attributes and config', () async {
      await RoktSdk.selectShoppableAds(
        viewName: 'ConfirmationPage',
        attributes: {'email': 'test@example.com'},
        roktConfig: const RoktConfig(colorMode: ColorMode.light),
      );

      expect(log.first.arguments['viewName'], 'ConfirmationPage');
      expect(log.first.arguments['attributes'], {'email': 'test@example.com'});

      final config = log.first.arguments['config'] as Map<Object?, Object?>;
      expect(config['colorMode'], 'light');
    });
  });

  group('registerPaymentExtension', () {
    test('sends correct arguments', () async {
      await RoktSdk.registerPaymentExtension(
        extensionType: 'stripe',
        config: {'stripeKey': 'pk_test_123'},
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'registerPaymentExtension');
      expect(log.first.arguments['extensionType'], 'stripe');
      expect(log.first.arguments['config'], {'stripeKey': 'pk_test_123'});
    });

    test('sends empty config by default', () async {
      await RoktSdk.registerPaymentExtension(extensionType: 'stripe');

      expect(log.first.arguments['config'], isEmpty);
    });
  });

  group('purchaseFinalized', () {
    test('sends correct arguments', () async {
      await RoktSdk.purchaseFinalized(
        placementId: 'placement-123',
        catalogItemId: 'item-456',
        success: true,
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'purchaseFinalized');
      expect(log.first.arguments['placementId'], 'placement-123');
      expect(log.first.arguments['catalogItemId'], 'item-456');
      expect(log.first.arguments['success'], true);
    });

    test('sends failure status', () async {
      await RoktSdk.purchaseFinalized(
        placementId: 'p-1',
        catalogItemId: 'c-1',
        success: false,
      );

      expect(log.first.arguments['success'], false);
    });
  });

  group('setSessionId', () {
    test('sends correct arguments', () async {
      await RoktSdk.setSessionId('my-session-id');

      expect(log, hasLength(1));
      expect(log.first.method, 'setSessionId');
      expect(log.first.arguments['sessionId'], 'my-session-id');
    });
  });

  group('getSessionId', () {
    test('returns session id from native', () async {
      final sessionId = await RoktSdk.getSessionId();

      expect(log, hasLength(1));
      expect(log.first.method, 'getSessionId');
      expect(sessionId, 'test-session-id');
    });
  });
}
