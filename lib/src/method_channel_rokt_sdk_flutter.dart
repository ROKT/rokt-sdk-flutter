import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../rokt_sdk.dart';

class MethodChannelRoktSdkFlutter {
  final MethodChannel _channel;
  final Map<int, RoktCallback> _callbacksById;
  final Set _viewIds;
  int _nextCallbackId = 0;

  static final MethodChannelRoktSdkFlutter _instance =
      MethodChannelRoktSdkFlutter._();

  static MethodChannelRoktSdkFlutter get instance => _instance;

  MethodChannelRoktSdkFlutter._()
      : _channel = const MethodChannel('rokt_sdk'),
        _callbacksById = {},
        _viewIds = {} {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> initialize({required String roktTagId, appVersion = ''}) async {
    // remove all the existing id's during initialization
    _viewIds.clear();
    await _channel.invokeMethod(
        'initialize', {'roktTagId': roktTagId, 'appVersion': appVersion});
  }

  Future<void> execute(
      {required String viewName,
      required Map attributes,
      required RoktCallback callback,
      Map placeholders = const {}}) async {
    int currentCallbackId = _nextCallbackId++;
    _callbacksById[currentCallbackId] = callback;
    // will use _viewIds here
    await _channel.invokeMethod('execute', {
      'viewName': viewName,
      'attributes': attributes,
      'placeholders': placeholders,
      'callbackId': currentCallbackId
    });
  }

  void setWidgetId({required int id}) => _viewIds.add(id);

  Future<void> _methodCallHandler(MethodCall call) async {
    print("_methodCallHandler $call");
    switch (call.method) {
      case 'callListener':
        _callbacksById[call.arguments["id"]]?.call(call.arguments["args"]);
        break;
      default:
        print('No method matching !!');
    }
  }
}
