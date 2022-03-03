import 'dart:async';

import 'package:flutter/services.dart';

class RoktSdk {
  static const MethodChannel _channel = MethodChannel('rokt_sdk');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<void> initialize(String roktTagId,{appVersion = ''}) async {
    await _channel.invokeMethod('initialize', {'roktTagId': roktTagId, 'appVersion': appVersion});
  }

  static Future<void> execute(String viewName, Map attributes, {Map placeholders = const {}}) async {
    await _channel.invokeMethod('execute', {'viewName': viewName,
      'attributes': attributes, 'placeholders': placeholders});
  }
}
