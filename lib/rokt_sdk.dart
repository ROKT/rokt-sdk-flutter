library rokt_sdk;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:rokt_sdk/src/method_channel_rokt_sdk_flutter.dart';

part 'src/rokt_widget.dart';

typedef RoktCallback = void Function(dynamic msg);

class RoktSdk {

  static Future<void> initialize(String roktTagId, {appVersion = ''}) async {
    await MethodChannelRoktSdkFlutter.instance
        .initialize(roktTagId: roktTagId, appVersion: appVersion);
  }

  static Future<void> execute(
      String viewName, Map attributes, RoktCallback callback,
      {Map placeholders = const {}}) async {
    await MethodChannelRoktSdkFlutter.instance.execute(
        viewName: viewName,
        attributes: attributes,
        callback: callback);
  }
}
