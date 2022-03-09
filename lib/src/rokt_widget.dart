part of rokt_sdk;

typedef RoktWidgetCreatedCallback = void Function(
    int widgetId);

class RoktWidget extends StatelessWidget {

  final RoktWidgetCreatedCallback onRoktWidgetCreated;

  const RoktWidget({Key? key, required this.onRoktWidgetCreated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    const String viewType = "rokt_sdk.rokt.com/rokt_widget";

    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (
            BuildContext context,
            PlatformViewController controller,
            ) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers:
                const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          final SurfaceAndroidViewController controller =
          PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          );
          controller.addOnPlatformViewCreatedListener(
            params.onPlatformViewCreated,
          );
          controller.addOnPlatformViewCreatedListener(
            _onPlatformViewCreated,
          );
          controller.create();
          return controller;
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the rokt sdk plugin');
  }

  void _onPlatformViewCreated(int id) {
    onRoktWidgetCreated(id);
    MethodChannelRoktSdkFlutter.instance.setWidgetId(id: id);
  }
}