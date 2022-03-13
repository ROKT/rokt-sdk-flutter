import 'package:flutter/services.dart';

typedef RoktWidgetSizeChangeCallback = void Function(double size);

class WidgetController {
  final int id;
  final MethodChannel _channel;
  final RoktWidgetSizeChangeCallback sizeChangeCallback;

  WidgetController({required this.id, required this.sizeChangeCallback})
      : _channel = MethodChannel('rokt_widget_$id') {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    print("_methodCallHandler in widget controller $call");
    switch (call.method) {
      case 'viewHeightListener':
        sizeChangeCallback.call(call.arguments["size"]);
        break;
      default:
        print('No method matching !!');
    }
  }
}
