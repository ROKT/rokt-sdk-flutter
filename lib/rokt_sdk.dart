
library rokt_sdk;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

part 'src/rokt_widget.dart';

typedef RoktCallback = void Function(dynamic msg);

class RoktSdk {
  static const MethodChannel _channel = MethodChannel('rokt_sdk');
  static final Map<int, RoktCallback> _callbacksById = {};
  static bool _isChannelSetup = false;
  static int _nextCallbackId = 0;

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> initialize(String roktTagId, {appVersion = ''}) async {
    if (!_isChannelSetup) {
      _channel.setMethodCallHandler(_methodCallHandler);
      _isChannelSetup = true;
    }
    await _channel.invokeMethod(
        'initialize', {'roktTagId': roktTagId, 'appVersion': appVersion});
  }

  static Future<void> execute(
      String viewName, Map attributes, RoktCallback callback,
      {Map placeholders = const {}}) async {
    int currentCallbackId = _nextCallbackId++;
    _callbacksById[currentCallbackId] = callback;
    await _channel.invokeMethod('execute', {
      'viewName': viewName,
      'attributes': attributes,
      'placeholders': placeholders,
      'callbackId': currentCallbackId
    });
  }

  static Future<void> _methodCallHandler(MethodCall call) async {
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
