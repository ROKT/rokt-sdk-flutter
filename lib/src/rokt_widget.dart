part of rokt_sdk;

typedef RoktWidgetCreatedCallback = void Function(int widgetId);

/// Rokt embedded widget custom view
class RoktWidget extends StatefulWidget {
  final String placeholderName;

  const RoktWidget({Key? key, required this.placeholderName}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RoktContainerState();
}

class _RoktContainerState extends State<RoktWidget>
    with AutomaticKeepAliveClientMixin<RoktWidget> {
  double _height = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _height = 0;
    super.initState();
  }

  void _changeHeight(double newHeight) {
    setState(() {
      _height = newHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: _height,
        child:
            _RoktStatelessWidget(widgetCreatedCallback: _onWidgetViewCreated));
  }

  void _onWidgetViewCreated(int id) {
    debugPrint('_onPlatformViewCreated $id ');
    RoktSdkController.instance
        .attachPlaceholder(id: id, name: widget.placeholderName);
    WidgetController(id: id, sizeChangeCallback: _changeHeight);
  }
}

class _RoktStatelessWidget extends StatelessWidget {
  final RoktWidgetCreatedCallback widgetCreatedCallback;

  const _RoktStatelessWidget({Key? key, required this.widgetCreatedCallback})
      : super(key: key);

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
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
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
            widgetCreatedCallback,
          );
          controller.create();
          return controller;
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: widgetCreatedCallback,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the rokt sdk plugin');
  }
}
