import 'dart:io' show Platform;

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
  final attributesController = TextEditingController(
      text: Platform.isIOS
          ? constants.iOSAttributes
          : constants.androidAttributes);
  final stripeKeyController = TextEditingController(text: "");
  Map<int, String> placeholders = {};
  static const EventChannel roktEventChannel = EventChannel('RoktEvents');

  @override
  void initState() {
    super.initState();
    receiveRoktEvent();
  }

  void receiveRoktEvent() {
    try {
      roktEventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          debugPrint("rokt_sdk _receiveRoktEvent $event ");
        },
        onError: (error) {
          debugPrint("rokt_sdk event channel error: $error");
        },
      );
    } catch (e) {
      debugPrint("rokt_sdk event channel setup failed: $e");
    }
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
                                child: const Text('Initialize'),
                                onPressed: () {
                                  RoktSdk.initialize(tagIdController.text,
                                      appVersion: '1.0.0');
                                },
                              )
                            ]),
                        TextField(
                            controller: attributesController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null),
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: TextField(
                                      controller: viewNameController,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                          hintText: "View Name"))),
                              TextButton(
                                  child: const Text('Select Placements'),
                                  onPressed: () {
                                    RoktSdk.selectPlacements(
                                        viewName: viewNameController.text,
                                        attributes: getAttributes());
                                  })
                            ]),
                        const Divider(),
                        const Text("Shoppable Ads (iOS only)",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: stripeKeyController,
                                decoration: const InputDecoration(
                                    hintText: "Stripe Key (pk_...)"),
                              ),
                            ),
                            TextButton(
                              child: const Text('Register'),
                              onPressed: () {
                                RoktSdk.registerPaymentExtension(
                                  extensionType: 'stripe',
                                  config: {
                                    'stripeKey': stripeKeyController.text,
                                  },
                                );
                                debugPrint(
                                    "rokt_sdk payment extension registered");
                              },
                            ),
                          ],
                        ),
                        TextButton(
                          child: const Text('Shoppable Ads'),
                          onPressed: () {
                            RoktSdk.selectShoppableAds(
                              viewName: viewNameController.text,
                              attributes: getAttributes(),
                            );
                            debugPrint("rokt_sdk shoppable ads triggered");
                          },
                        ),
                        const Divider(),
                        const Text("Location 1"),
                        const RoktWidget(
                            key: ValueKey('widget1'),
                            placeholderName: "Location1"),
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
