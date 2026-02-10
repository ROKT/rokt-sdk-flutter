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
  final placementIdController = TextEditingController(text: "");
  final catalogItemIdController = TextEditingController(text: "");
  bool purchaseSuccess = false;
  Map<int, String> placeholders = {};
  static const EventChannel roktEventChannel = EventChannel('RoktEvents');

  @override
  void initState() {
    super.initState();
    receiveRoktEvent();
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
                                  child: const Text('Select Placements'),
                                  onPressed: () {
                                    RoktSdk.selectPlacements(
                                        viewName: viewNameController.text,
                                        attributes: getAttributes());
                                  })
                            ]),
                        TextField(
                            controller: attributesController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null),
                        const Divider(),
                        const Text("Purchase Finalized Test",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Placement ID"),
                                  TextField(controller: placementIdController),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Catalog Item ID"),
                                  TextField(
                                      controller: catalogItemIdController),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text("Success: "),
                            Switch(
                              value: purchaseSuccess,
                              onChanged: (value) {
                                setState(() {
                                  purchaseSuccess = value;
                                });
                              },
                            ),
                            Expanded(
                              child: TextButton(
                                child: const Text('Call Purchase Finalized'),
                                onPressed: () {
                                  RoktSdk.purchaseFinalized(
                                    placementId: placementIdController.text,
                                    catalogItemId: catalogItemIdController.text,
                                    success: purchaseSuccess,
                                  );
                                },
                              ),
                            ),
                          ],
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
