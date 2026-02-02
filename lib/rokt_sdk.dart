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
      {String appVersion = '',
      Map<String, String> fontFilePathMap = const {}}) async {
    await RoktSdkController.instance.initialize(
        roktTagId: roktTagId,
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
  ///   - roktConfig: Rokt SDK configuration object
  ///   - onLoad: Function to execute right after the widget is successfully loaded and displayed
  ///   - onUnLoad: Function to execute right after widget is unloaded, there is no widget or there is an exception
  ///   - onShouldShowLoadingIndicator: Function to execute when the loading indicator should be shown
  ///   - onShouldHideLoadingIndicator: Function to execute when the loading indicator should be hidden
  static Future<void> execute(
      {required String viewName,
      Map<String, String> attributes = const {},
      RoktConfig? roktConfig,
      RoktCallback onLoad = _defaultRoktCallBack,
      RoktCallback onUnLoad = _defaultRoktCallBack,
      RoktCallback onShouldShowLoadingIndicator = _defaultRoktCallBack,
      RoktCallback onShouldHideLoadingIndicator = _defaultRoktCallBack}) async {
    _onLoad = onLoad;
    _onUnLoad = onUnLoad;
    _onShouldShowLoadingIndicator = onShouldShowLoadingIndicator;
    _onShouldHideLoadingIndicator = onShouldHideLoadingIndicator;

    await RoktSdkController.instance.execute(
        viewName: viewName,
        attributes: attributes,
        config: roktConfig,
        callback: _defaultRoktCallBackInternal);
  }

  /// Enable or disable debug logging from the library
  /// - Parameters:
  ///   - enable: enables or disables debug logging
  static Future<void> setLoggingEnabled({required bool enable}) async {
    await RoktSdkController.instance.setLoggingEnabled(enable: enable);
  }

  /// Notifies Rokt that a purchase has been finalized
  ///
  /// Use this method to inform Rokt that a purchase has been completed or failed
  /// - Parameters:
  ///   - placementId: The placement ID associated with the purchase
  ///   - catalogItemId: The catalog item ID that was purchased
  ///   - success: Whether the purchase was successful
  ///
  /// Note: This method requires iOS 15+.
  static Future<void> purchaseFinalized({
    required String placementId,
    required String catalogItemId,
    required bool success,
  }) async {
    await RoktSdkController.instance.purchaseFinalized(
      placementId: placementId,
      catalogItemId: catalogItemId,
      success: success,
    );
  }
}

/// Cache configuration for the Rokt SDK
///
/// - Attributes
///  - [int] cacheDurationInSeconds: duration in seconds for which the Rokt SDK should cache the experience. Default is 90 minutes
///  - [Map<String, String>]? cacheAttributes: optional attributes to be used as cache key. If null, all the attributes will be used as the cache key
@immutable
class CacheConfig {
  /// Duration in seconds for which the Rokt SDK should cache the experience
  final int cacheDurationInSeconds;

  /// Optional attributes to be used as cache key
  final Map<String, String>? cacheAttributes;

  /// Constructor
  ///
  /// - Parameters
  ///  - [int] cacheDurationInSeconds: duration in seconds for which the Rokt SDK should cache the experience. Default is 90 minutes
  ///  - [Map<String, String>]? cacheAttributes: optional attributes to be used as cache key. If null, all the attributes will be used as the cache key
  const CacheConfig(
      {this.cacheDurationInSeconds = 0, this.cacheAttributes = null});
}

/// Configuration settings for the Rokt SDK <br>
///
/// - Attributes
///   - [ColorMode]? colorMode: preferred device color mode configuration
///   - [CacheConfig]? cacheConfig: cache configuration for the Rokt SDK
@immutable
class RoktConfig {
  /// The device color mode your application is using
  final ColorMode colorMode;

  /// The cache configuration for the Rokt SDK
  final CacheConfig? cacheConfig;

  /// Constructor
  ///
  /// - Parameters
  ///   - [ColorMode]? colorMode: preferred device color mode configuration
  ///   - [CacheConfig]? cacheConfig: cache configuration for the Rokt SDK
  const RoktConfig(
      {this.colorMode = ColorMode.system, this.cacheConfig = null});
}

/// Enum representing device color modes
enum ColorMode {
  /// Request Light mode configuration
  light,

  /// Request Dark mode configuration
  dark,

  /// Request System's current configuration
  system
}
