library rokt_sdk;

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:rokt_sdk/src/rokt_sdk_controller.dart';
import 'package:rokt_sdk/src/widget_controller.dart';

part 'src/rokt_widget.dart';


typedef RoktCallbackInternal = void Function(dynamic msg);
typedef RoktCallback = void Function();

class RoktSdk {

  static const load = "load";
  static const unload = "unload";
  static const shouldShowLoadingIndicator = "onShouldShowLoadingIndicator";
  static const shouldHideLoadingIndicator = "onShouldHideLoadingIndicator";

  static void defaultRoktCallBackInternal(dynamic msg) {
    switch (msg) {
      case load:
        {
          _onLoad?.call();
          break;
        }
      case unload:
        {
          _onUnLoad?.call();
          break;
        }
      case shouldShowLoadingIndicator:
        {
          _onShouldShowLoadingIndicator?.call();
          break;
        }
      case shouldHideLoadingIndicator:
        {
          _onShouldHideLoadingIndicator?.call();
          break;
        }
    }
  }

  static void defaultRoktCallBack() {}

  static RoktCallback? _onLoad;

  static RoktCallback? _onUnLoad;

  static RoktCallback? _onShouldShowLoadingIndicator;

  static RoktCallback? _onShouldHideLoadingIndicator;

  static Future<void> initialize(String roktTagId, {appVersion = ''}) async {
    await RoktSdkController.instance
        .initialize(roktTagId: roktTagId, appVersion: appVersion);
  }

  static Future<void> execute(
      String viewName,
      Map attributes, {
        RoktCallback onLoad = defaultRoktCallBack,
        RoktCallback onUnLoad = defaultRoktCallBack,
        RoktCallback onShouldShowLoadingIndicator = defaultRoktCallBack,
        RoktCallback onShouldHideLoadingIndicator = defaultRoktCallBack,
      }) async {
    _onLoad = onLoad;
    _onUnLoad = onUnLoad;
    _onShouldShowLoadingIndicator = onShouldShowLoadingIndicator;
    _onShouldHideLoadingIndicator = onShouldHideLoadingIndicator;


    await RoktSdkController.instance.execute(
        viewName: viewName,
        attributes: attributes,
        callback: defaultRoktCallBackInternal);
  }
}
