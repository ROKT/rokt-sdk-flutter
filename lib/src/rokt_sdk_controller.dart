import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rokt_sdk/rokt_sdk.dart';

/// Internal callBack for Rokt Sdk
typedef RoktCallbackInternal = void Function(dynamic msg);

/// Rokt SDK Controller to handle callbacks and Method channels
class RoktSdkController {
  final MethodChannel _channel;
  final Map<int, RoktCallbackInternal> _callbacksById;
  final Map<int, String> _placeholders;
  int _nextCallbackId = 0;

  static final RoktSdkController _instance = RoktSdkController._();

  /// Singleton RoktSdkController instance
  static RoktSdkController get instance => _instance;

  RoktSdkController._()
      : _channel = const MethodChannel('rokt_sdk'),
        _callbacksById = {},
        _placeholders = {} {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  /// Call Rokt Initialize method in Native SDK
  Future<void> initialize(
      {required String roktTagId,
      String appVersion = '',
      Map<String, String> fontFilePathMap = const {}}) async {
    await _channel.invokeMethod('initialize', {
      'roktTagId': roktTagId,
      'appVersion': appVersion,
      'fontFilePathMap': fontFilePathMap
    });
  }

  /// Call Rokt Execute method in Native SDK
  Future<void> execute(
      {required String viewName,
      required Map<String, String> attributes,
      required RoktCallbackInternal callback,
      RoktConfig? config}) async {
    final int currentCallbackId = _nextCallbackId++;
    _callbacksById[currentCallbackId] = callback;
    await _channel.invokeMethod('execute', {
      'viewName': viewName,
      'attributes': attributes,
      'placeholders': instance._placeholders,
      'callbackId': currentCallbackId,
      'config': _roktConfigToMap(config: config),
    });
  }

  /// Call Rokt logging method in Native SDK
  Future<void> setLoggingEnabled({required bool enable}) async {
    await _channel.invokeMethod('logging', {'enable': enable});
  }

  /// Call Rokt purchaseFinalized method in Native SDK
  ///
  /// Note: This method requires iOS 15+.
  Future<void> purchaseFinalized({
    required String placementId,
    required String catalogItemId,
    required bool success,
  }) async {
    await _channel.invokeMethod('purchaseFinalized', {
      'placementId': placementId,
      'catalogItemId': catalogItemId,
      'success': success,
    });
  }

  /// Call Rokt setSessionId method in Native SDK
  Future<void> setSessionId({required String sessionId}) async {
    await _channel.invokeMethod('setSessionId', {'sessionId': sessionId});
  }

  /// Call Rokt getSessionId method in Native SDK
  Future<String?> getSessionId() async {
    return _channel.invokeMethod<String?>('getSessionId');
  }

  /// Placeholders are attached to be passed to Rokt Execute
  void attachPlaceholder({required int id, required String name}) {
    // Prevent duplicate placeholders with same name
    instance._placeholders.removeWhere((key, value) => value == name);
    instance._placeholders[id] = name;
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'callListener':
        _callbacksById[call.arguments['id']]?.call(call.arguments['args']);
        break;
      default:
        if (kDebugMode) {
          print('No method matching !!');
        }
    }
  }

  Map<String, dynamic> _roktConfigToMap({required RoktConfig? config}) {
    return {
      'colorMode': config?.colorMode.name ?? ColorMode.system.name,
      'cacheConfig': config?.cacheConfig != null
          ? {
              'cacheDurationInSeconds':
                  config?.cacheConfig?.cacheDurationInSeconds,
              'cacheAttributes': config?.cacheConfig?.cacheAttributes
            }
          : null
    };
  }
}
