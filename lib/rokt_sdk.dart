library rokt_sdk;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:rokt_sdk/src/rokt_sdk_controller.dart';
import 'package:rokt_sdk/src/widget_controller.dart';

part 'src/rokt_widget.dart';

/// callback for the rokt sdk
typedef RoktCallback = void Function();

/// The main interface to Rokt SDK
///
/// Use the member methods to interact with the Rokt SDK
class RoktSdk {
  static const _load = 'load';
  static const _unload = 'unload';
  static const _shouldShowLoadingIndicator = 'onShouldShowLoadingIndicator';
  static const _shouldHideLoadingIndicator = 'onShouldHideLoadingIndicator';

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

  /// Initializes Rokt SDK
  ///
  /// Initialize the Rokt SDK prior to using it.
  /// The recommended way of calling the initialize method is early in the application.
  /// - Parameters:
  ///   - roktTagId: The tag id provided by Rokt, associated with your account.
  ///   - appVersion: App version string
  ///   - fontFilePathMap: Optional. A map of custom font postscript name to font file. Eg: "Arial-bold": "fonts/Arial-Bold.ttf"
  static Future<void> initialize(String roktTagId,
      {String appVersion = '', Map<String, String> fontFilePathMap = const {}}) async {
    await RoktSdkController.instance
        .initialize(roktTagId: roktTagId,
        appVersion: appVersion,
        fontFilePathMap: fontFilePathMap);
  }

  /// Execute Rokt widget
  ///
  /// This is the entry point to display a widget to the consumer.
  /// The Rokt widget view displays after a short delay, configurable via the Rokt platform.
  /// The SDK provides optional callback events for when the view loads and unloads.
  /// Your app dictates which consumer attributes are passed through to Rokt
  /// - Parameters:
  ///   - viewName: The name that should be displayed in the widget
  ///   - attributes: A string map containing the parameters that should be displayed in the widget
  ///   - onLoad: Function to execute right after the widget is successfully loaded and displayed
  ///   - onUnLoad: Function to execute right after widget is unloaded, there is no widget or there is an exception
  ///   - onShouldShowLoadingIndicator: Function to execute when the loading indicator should be shown
  ///   - onShouldHideLoadingIndicator: Function to execute when the loading indicator should be hidden
  static Future<void> execute({
    required String viewName,
    Map<String, String> attributes = const {},
    RoktCallback onLoad = _defaultRoktCallBack,
    RoktCallback onUnLoad = _defaultRoktCallBack,
    RoktCallback onShouldShowLoadingIndicator = _defaultRoktCallBack,
    RoktCallback onShouldHideLoadingIndicator = _defaultRoktCallBack
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

  /// Enable or disable debug logging from the library
  /// - Parameters:
  ///   - enable: enables or disables debug logging
  static Future<void> setLoggingEnabled({required bool enable}) async {
    await RoktSdkController.instance.setLoggingEnabled(enable: enable);
  }
}
