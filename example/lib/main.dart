import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'package:rokt_sdk/rokt_sdk.dart';
import 'assets/constants.dart' as constants;

/* void main() {
  runApp(const MyApp());
} */

void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Open route'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
            );
          },
        ),
      ),
    );
  }
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
  static const EventChannel _stringEventChannel = EventChannel('rokt_event');
  String _stringFromNative = 'No string received yet';
  static const eventChannel = EventChannel('timeHandlerEvent');

  @override
  void initState() {
    super.initState();
    _receiveRoktEvent();
    streamTimeFromNative();
  }

  void streamTimeFromNative() {
    debugPrint("Sahil rokt_sdk streamTimeFromNative");
    const eventChannel = EventChannel('timeHandlerEvent');
    

     eventChannel.receiveBroadcastStream().listen((event) {
      debugPrint("Sahil rokt_sdk streamTimeFromNative" + event.toString());
    // some actions
     });

  }

  void _receiveRoktEvent() {
    _stringEventChannel.receiveBroadcastStream('PizzaHutLayout').listen((dynamic event) {
      debugPrint("Sahil rokt_sdk _receiveRoktEvent $event ");
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
                                      appVersion: '1.0.0');
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
                                    
                                  })
                            ]),
                        TextField(
                            controller: attributesController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null),
                        const Text("RoktEmbedded2"),
                        RoktWidget(
                            key: const ValueKey('widget1'),
                            placeholderName: "#rokt-placeholder",
                            onWidgetCreated: () {
                              debugPrint("rokt_widget widget is created ***");
                              Future.delayed(Duration(milliseconds: 6000), () {
                                      // Do something
                                      RoktSdk.execute(
                                        viewName: viewNameController.text,
                                        attributes: getAttributes(),
                                        onLoad: () {
                                          debugPrint("rokt_sdk loaded");
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
                                });
                            }),
                        const Text("Location 2"),
                        RoktWidget(
                            key: const ValueKey('widget2'),
                            placeholderName: "Location2",
                            onWidgetCreated: () {
                              debugPrint("rokt_widget widget is created");
                            }),
                        const Text("The end")
                      ],
                    ),
                  ),
                ),
              ]),
            )));
  }
}
