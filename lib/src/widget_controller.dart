import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Callback when Rokt widget size gets changed
typedef RoktWidgetSizeChangeCallback = void Function(double size);

/// Callback when Rokt widget padding gets changed
typedef RoktWidgetPaddingChangeCallback = void Function(
    BoundingBox boundingBox);

/// Widget Controller to handle callbacks and Method channels of view
class WidgetController {
  /// Id of the Rokt widget view
  final int id;
  final MethodChannel _channel;

  /// callback for the roktWidget size change
  final RoktWidgetSizeChangeCallback sizeChangeCallback;

  /// callback for the roktWidget padding change
  final RoktWidgetPaddingChangeCallback paddingChangeCallback;

  /// Initialize WidgetController with a specific method channel
  WidgetController(
      {required this.id,
      required this.sizeChangeCallback,
      required this.paddingChangeCallback})
      : _channel = MethodChannel('rokt_widget_$id') {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'viewHeightListener':
        sizeChangeCallback.call(call.arguments['size']);
        break;
      case 'viewPaddingListener':
        paddingChangeCallback.call(BoundingBox(
            left: call.arguments['left'],
            top: call.arguments['top'],
            right: call.arguments['right'],
            bottom: call.arguments['bottom']));
        break;
      default:
        if (kDebugMode) {
          print('No method matching !!');
        }
    }
  }
}

/// Padding box
class BoundingBox {
  /// left padding
  final double left;

  /// top padding
  final double top;

  /// right padding
  final double right;

  /// bottom padding
  final double bottom;

  /// Initialize Bound box with LTRB padding
  const BoundingBox(
      {required this.left,
      required this.top,
      required this.right,
      required this.bottom});
}
