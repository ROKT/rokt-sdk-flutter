import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Callback when Rokt widget size gets changed
typedef RoktWidgetSizeChangeCallback = void Function(double size);

/// Widget Controller to handle callbacks and Method channels of view
class WidgetController {
  /// Id of the Rokt widget view
  final int id;
  final MethodChannel _channel;

  /// callback for the roktWidget size change
  final RoktWidgetSizeChangeCallback sizeChangeCallback;

  /// Initialize WidgetController with a specific method channel
  WidgetController({required this.id, required this.sizeChangeCallback})
      : _channel = MethodChannel('rokt_widget_$id') {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'viewHeightListener':
        sizeChangeCallback.call(call.arguments['size']);
        break;
      default:
        if (kDebugMode) {
          print('No method matching !!');
        }
    }
  }
}
