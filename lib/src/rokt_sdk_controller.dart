import 'package:flutter/services.dart';
import 'package:rokt_sdk/rokt_sdk.dart';

/// Rokt SDK Controller to handle callbacks and Method channels
class RoktSdkController {
  final MethodChannel _channel;
  final Map<int, String> _placeholders;

  static final RoktSdkController _instance = RoktSdkController._();

  /// Singleton RoktSdkController instance
  static RoktSdkController get instance => _instance;

  RoktSdkController._()
      : _channel = const MethodChannel('rokt_sdk'),
        _placeholders = {};

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

  /// Call Rokt selectPlacements method in Native SDK
  Future<void> selectPlacements(
      {required String viewName,
      required Map<String, String> attributes,
      RoktConfig? config}) async {
    await _channel.invokeMethod('selectPlacements', {
      'viewName': viewName,
      'attributes': attributes,
      'placeholders': instance._placeholders,
      'config': _roktConfigToMap(config: config),
    });
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

  /// Placeholders are attached to be passed to Rokt placement selection.
  void attachPlaceholder({required int id, required String name}) {
    // Prevent duplicate placeholders with same name
    instance._placeholders.removeWhere((key, value) => value == name);
    instance._placeholders[id] = name;
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
