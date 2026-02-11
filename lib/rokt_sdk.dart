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

/// The main interface to Rokt SDK
///
/// Use the member methods to interact with the Rokt SDK
class RoktSdk {
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

  /// Select Rokt placements
  ///
  /// This is the entry point to select and display placements for a given view.
  /// Your app dictates which consumer attributes are passed through to Rokt
  /// - Parameters:
  ///   - viewName: The name that should be displayed in the widget
  ///   - attributes: A string map containing the parameters that should be displayed in the widget
  ///   - roktConfig: Rokt SDK configuration object
  static Future<void> selectPlacements(
      {required String viewName,
      Map<String, String> attributes = const {},
      RoktConfig? roktConfig}) async {
    await RoktSdkController.instance.selectPlacements(
        viewName: viewName,
        attributes: attributes,
        config: roktConfig);
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

  /// Set the session id to use for the next select placements call.
  ///
  /// This is useful for cases where you have a session id from a non-native integration,
  /// e.g. WebView, and you want the session to be consistent across integrations.
  ///
  /// - Note: Empty strings are ignored and will not update the session.
  ///
  /// - Parameters:
  ///   - sessionId: The session id to be set. Must be a non-empty string.
  static Future<void> setSessionId(String sessionId) async {
    await RoktSdkController.instance.setSessionId(sessionId: sessionId);
  }

  /// Get the session id to use within a non-native integration e.g. WebView.
  ///
  /// - Returns: The session id or null if no session is present.
  static Future<String?> getSessionId() async {
    return RoktSdkController.instance.getSessionId();
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
