import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:rokt_sdk/rokt_sdk.dart';
import 'assets/constants.dart' as constants;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final tagIdController = TextEditingController(text: constants.defaultTagId);
  final viewNameController =
      TextEditingController(text: constants.defaultViewName);
  final attributesController =
      TextEditingController(text: constants.defaultAttributes);
  Map<int, String> placeholders = {};
  final EventChannel roktEventChannel = EventChannel('RoktEvents');
  double _height = 0;

  @override
  void initState() {
    super.initState();
    _height = 0;
    receiveRoktEvent();
  }

  void _changeContainerHeight() {
    setState(() {
      _height = 300;
    });
  }

  void receiveRoktEvent() {
    roktEventChannel.receiveBroadcastStream().listen((dynamic event) {
      debugPrint("rokt_sdk _receiveRoktEvent $event ");
    });
  }

  Map<String, String> getAttributes() {
    return Map<String, String>.from(json.decode(attributesController.text));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(children: [
                  Expanded(
                    child: CustomScrollView(shrinkWrap: true, slivers: <Widget>[
                      SliverPadding(
                        padding: const EdgeInsets.all(20.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            <Widget>[
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: TextField(
                                            controller: tagIdController,
                                            textAlign: TextAlign.center)),
                                    TextButton(
                                      child: const Text('Initial'),
                                      onPressed: () {
                                        RoktSdk.setLoggingEnabled(enable: true);
                                        RoktSdk.initialize(tagIdController.text,
                                            appVersion: '1.0.0',
                                            fontFilePathMap: {'LINESeedJPApp_OTF-Bold-AlphaNum': 'packages/test_font/fonts/LINESeedJP_A_OTF_Bd.otf'});
                                      },
                                    )
                                  ]),
                              Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        child: TextField(
                                            controller: viewNameController,
                                            textAlign: TextAlign.center)),
                                    TextButton(
                                        child: const Text('Execute'),
                                        onPressed: () {
                                          RoktSdk.execute(
                                              viewName: viewNameController.text,
                                              attributes: getAttributes(),
                                              onLoad: () {
                                                debugPrint("rokt_sdk loaded");
                                                _changeContainerHeight();
                                              },
                                              onUnLoad: () {
                                                debugPrint("rokt_sdk unloaded");
                                              },
                                              onShouldShowLoadingIndicator: () {
                                                debugPrint(
                                                    "rokt_sdk onShouldShowLoadingIndicator");
                                              },
                                              onShouldHideLoadingIndicator: () {
                                                debugPrint(
                                                    "rokt_sdk onShouldHideLoadingIndicator");
                                              });
                                        })
                                  ]),
                              TextField(
                                  controller: attributesController,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null),
                              const Text("Location 1"),
                              Material(
                                  child: RoktWidget(
                                      key: const ValueKey('widget1'),
                                      placeholderName: "RoktEmbedded1")),
                              const Text("Location 2"),
                              RoktWidget(
                                key: const ValueKey('widget2'),
                                placeholderName: "RoktEmbedded2"
                              ),
                              const Text("Container"),
                              Container(
                                height: 300.0,
                                width: 300.0,
                                color: Colors.red,
                              ),
                              const Text("The end")
                            ],
                          ),
                        ),
                      ),
                    ]),
                  )
                ]))));
  }
}
