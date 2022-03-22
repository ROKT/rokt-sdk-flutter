import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../rokt_sdk.dart';


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
  Future<void> initialize({required String roktTagId, String appVersion = ''}) async {
    await _channel.invokeMethod(
        'initialize', {'roktTagId': roktTagId, 'appVersion': appVersion});
  }

  /// Call Rokt Execute method in Native SDK
  Future<void> execute(
      {required String viewName,
      required Map attributes,
      required RoktCallbackInternal callback}) async {
    final int currentCallbackId = _nextCallbackId++;
    _callbacksById[currentCallbackId] = callback;
    await _channel.invokeMethod('execute', {
      'viewName': viewName,
      'attributes': attributes,
      'placeholders': instance._placeholders,
      'callbackId': currentCallbackId
    });
  }

  /// Call Rokt logging method in Native SDK
  Future<void> setLoggingEnabled({required bool enable}) async {
    await _channel.invokeMethod('logging', {'enable': enable});
  }

  /// Placeholders are attached to be passed to Rokt Execute
  void attachPlaceholder({required int id, required String name}) {
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
}
