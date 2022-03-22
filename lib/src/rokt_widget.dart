part of rokt_sdk;

typedef RoktWidgetCreatedCallback = void Function(int widgetId);

/// Rokt embedded widget custom view
class RoktWidget extends StatefulWidget {
  static final Map<int, _RoktContainerState> _states = {};
  final String placeholderName;

  const RoktWidget({Key? key, required this.placeholderName}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    debugPrint('_Sahil createState RoktWidget $placeholderName $hashCode');
    return _RoktContainerState();
    /*_RoktContainerState? state = _states[hashCode];
    if (state == null) {
      state = _RoktContainerState();
      _states[hashCode] = state;
    }
    return state;*/
  }
}

class _RoktContainerState extends State<RoktWidget> with
    AutomaticKeepAliveClientMixin<RoktWidget> {
  @override
  bool get wantKeepAlive => true;
  double _height = 0;

  @override
  void initState() {
    debugPrint('_Sahil _RoktContainerState initState ${widget.hashCode}');
    _height = 0;
    super.initState();
  }

  @override
  void deactivate() {
    debugPrint('_Sahil _RoktContainerState deactivate ${widget.hashCode}');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('_Sahil _RoktContainerState dispose ${widget.hashCode}');
    super.dispose();
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
        _RoktStatelessWidget(placeHolder: widget.placeholderName, widgetCreatedCallback: _onWidgetViewCreated));
  }

  void _onWidgetViewCreated(int id) {
    debugPrint('_onPlatformViewCreated $id ${widget.placeholderName}');
    RoktSdkController.instance
        .attachPlaceholder(id: id, name: widget.placeholderName);
    WidgetController(id: id, sizeChangeCallback: _changeHeight);
  }
}

class _RoktStatelessWidget extends StatelessWidget {
  final RoktWidgetCreatedCallback widgetCreatedCallback;
  static final Map<String, PlatformViewLink> _views = {};
  final String placeHolder;

  _RoktStatelessWidget({Key? key, required this.placeHolder, required this.widgetCreatedCallback})
      :  super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    const String viewType = "rokt_sdk.rokt.com/rokt_widget";

    if (defaultTargetPlatform == TargetPlatform.android) {
      return getAndroidView();
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

  PlatformViewLink getAndroidView() {
    var view = /*_views[placeHolder] ??*/ PlatformViewLink(
        viewType: "rokt_sdk.rokt.com/rokt_widget",
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
          debugPrint('onCreatePlatformView ${params.id}');
          final SurfaceAndroidViewController controller =
          PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: "rokt_sdk.rokt.com/rokt_widget",
            layoutDirection: TextDirection.ltr,
            creationParams: {},
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
    _views[placeHolder] = view;
    return view;
  }

}
