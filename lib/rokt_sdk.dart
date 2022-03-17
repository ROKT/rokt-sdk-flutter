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
  static const _load = "load";
  static const _unload = "unload";
  static const _shouldShowLoadingIndicator = "onShouldShowLoadingIndicator";
  static const _shouldHideLoadingIndicator = "onShouldHideLoadingIndicator";

  static void _defaultRoktCallBackInternal(dynamic msg) {
    switch (msg) {
      case _load:
        {
          _onLoad?.call();
          break;
        }
      case _unload:
        {
          _onUnLoad?.call();
          break;
        }
      case _shouldShowLoadingIndicator:
        {
          _onShouldShowLoadingIndicator?.call();
          break;
        }
      case _shouldHideLoadingIndicator:
        {
          _onShouldHideLoadingIndicator?.call();
          break;
        }
    }
  }

  static void _defaultRoktCallBack() {}

  static RoktCallback? _onLoad;

  static RoktCallback? _onUnLoad;

  static RoktCallback? _onShouldShowLoadingIndicator;

  static RoktCallback? _onShouldHideLoadingIndicator;

  static Future<void> initialize(String roktTagId, {appVersion = ''}) async {
    await RoktSdkController.instance
        .initialize(roktTagId: roktTagId, appVersion: appVersion);
  }

  static Future<void> execute({
    required String viewName,
    Map attributes = const { },
    RoktCallback onLoad = _defaultRoktCallBack,
    RoktCallback onUnLoad = _defaultRoktCallBack,
    RoktCallback onShouldShowLoadingIndicator = _defaultRoktCallBack,
    RoktCallback onShouldHideLoadingIndicator = _defaultRoktCallBack,
  }) async {
    _onLoad = onLoad;
    _onUnLoad = onUnLoad;
    _onShouldShowLoadingIndicator = onShouldShowLoadingIndicator;
    _onShouldHideLoadingIndicator = onShouldHideLoadingIndicator;

    await RoktSdkController.instance.execute(
        viewName: viewName,
        attributes: attributes,
        callback: _defaultRoktCallBackInternal);
  }
}
