part of rokt_sdk;

typedef RoktWidgetCreatedCallback = void Function(int widgetId);
typedef RoktRegisterCallback = void Function({required int id});

class RoktWidget extends StatefulWidget {
  final String placeholderName;
  final RoktContainerState roktWidget;

  RoktWidget({Key? key, required this.placeholderName})
      : roktWidget = RoktContainerState(placeholderName: placeholderName),
        super(key: key);

  @override
  State<StatefulWidget> createState() => roktWidget;

  void registerWidget({required int id}) {
    MethodChannelRoktSdkFlutter.instance
        .attachPlaceholder(id: id, container: roktWidget);
  }

  void changeHeight(double newHeight) {
    roktWidget.changeHeight(newHeight);
  }
}

class RoktContainerState extends State<RoktWidget> {
  double _height = 0;
  String placeholderName;

  RoktContainerState({required this.placeholderName});

  @override
  void initState() {
    _height = 0;
    super.initState();
  }

  void changeHeight(double newHeight) {
    setState(() {
      _height = newHeight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: _height,
        child: _RoktStatelessWidget(
            placeholderName: placeholderName,
            registerCallback: widget.registerWidget));
  }
}

class _RoktStatelessWidget extends StatelessWidget {
  final String placeholderName;
  final RoktRegisterCallback registerCallback;

  const _RoktStatelessWidget(
      {Key? key, required this.placeholderName, required this.registerCallback})
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
    registerCallback(id: id);
  }
}
