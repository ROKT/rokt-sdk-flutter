import 'package:flutter/services.dart';

import '../rokt_sdk.dart';

class MethodChannelRoktSdkFlutter {
  final MethodChannel _channel;
  final Map<int, RoktCallback> _callbacksById;
  final Map<int, RoktContainerState> _placeholders;
  int _nextCallbackId = 0;

  static final MethodChannelRoktSdkFlutter _instance =
      MethodChannelRoktSdkFlutter._();

  static MethodChannelRoktSdkFlutter get instance => _instance;

  MethodChannelRoktSdkFlutter._()
      : _channel = const MethodChannel('rokt_sdk'),
        _callbacksById = {},
        _placeholders = {} {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> initialize({required String roktTagId, appVersion = ''}) async {
    // remove all the existing id's during initialization
    // _placeholders.clear();
    await _channel.invokeMethod(
        'initialize', {'roktTagId': roktTagId, 'appVersion': appVersion});
  }

  Future<void> execute(
      {required String viewName,
      required Map attributes,
      required RoktCallback callback}) async {
    int currentCallbackId = _nextCallbackId++;
    _callbacksById[currentCallbackId] = callback;
    await _channel.invokeMethod('execute', {
      'viewName': viewName,
      'attributes': attributes,
      'placeholders': instance._placeholders.map((key, value) => MapEntry(key, value.placeholderName)),
      'callbackId': currentCallbackId
    });
  }

  void attachPlaceholder({required int id, required RoktContainerState container}) {
    instance._placeholders[id] = container;
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    print("_methodCallHandler $call");
    switch (call.method) {
      case 'callListener':
        _callbacksById[call.arguments["id"]]?.call(call.arguments["args"]);
        break;
      case 'viewHeightListener':
        String selectedPlacement = call.arguments["selectedPlacement"];
        double widgetHeight = call.arguments["widgetHeight"];
        for (var placeholder in instance._placeholders.values) {
          if (placeholder.placeholderName == selectedPlacement) {
            placeholder.changeHeight(widgetHeight);
          }
        }
        break;
      default:
        print('No method matching !!');
    }
  }
}
