part of rokt_sdk;

/// Callback when Rokt platform view gets created and returns platform view id
typedef RoktPlatformViewCreatedCallback = void Function(int widgetId);

/// Callback when Rokt widget is created
typedef WidgetCreatedCallback = void Function();

/// Rokt embedded widget custom view
class RoktWidget extends StatefulWidget {
  /// name for the Rokt widget
  final String placeholderName;

  /// callback when widget is created
  final WidgetCreatedCallback onWidgetCreated;

  /// Initializes [key] for subclasses, [placeholderName] is the location name
  const RoktWidget(
      {Key? key,
      required this.placeholderName,
      this.onWidgetCreated = _defaultWidgetCreatedCallback})
      : super(key: key);

  static void _defaultWidgetCreatedCallback() {}

  @override
  State<StatefulWidget> createState() => _RoktContainerState();
}

class _RoktContainerState extends State<RoktWidget>
    with AutomaticKeepAliveClientMixin<RoktWidget> {
  double _height = 0;
  double _left = 0;
  double _top = 0;
  double _right = 0;
  double _bottom = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _height = 1;
    _left = 0;
    _top = 0;
    _right = 0;
    _bottom = 0;
    super.initState();
  }

  void _changeHeight(double newHeight) {
    setState(() {
      _height = newHeight;
    });
  }

  void _changePadding(BoundingBox box) {
    setState(() {
      _left = box.left;
      _top = box.top;
      _right = box.right;
      _bottom = box.bottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(_left, _top, _right, _bottom),
      child: SizedBox(
          height: _height,
          child: _RoktStatelessWidget(
              platformViewCreatedCallback: _onPlatformViewCreated)),
    );
  }

  void _onPlatformViewCreated(int id) {
    RoktSdkController.instance
        .attachPlaceholder(id: id, name: widget.placeholderName);
    WidgetController(
        id: id,
        sizeChangeCallback: _changeHeight,
        paddingChangeCallback: _changePadding);
    widget.onWidgetCreated();
  }
}

class _RoktStatelessWidget extends StatelessWidget {
  final RoktPlatformViewCreatedCallback platformViewCreatedCallback;

  const _RoktStatelessWidget(
      {Key? key, required this.platformViewCreatedCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    const String viewType = 'rokt_sdk.rokt.com/rokt_widget';

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
          )
                ..addOnPlatformViewCreatedListener(
                  params.onPlatformViewCreated,
                )
                ..addOnPlatformViewCreatedListener(
                  platformViewCreatedCallback,
                )
                ..create();
          return controller;
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: platformViewCreatedCallback,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the rokt sdk plugin');
  }
}
