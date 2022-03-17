import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
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
  Map<int, String> placeholders = Map();

  @override
  void initState() {
    super.initState();
  }

  Map getAttributes() {
    final Map attributes = json.decode(attributesController.text);
    return attributes;
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
                                  child: const Text('Execute'),
                                  onPressed: () {
                                    RoktSdk.execute(viewNameController.text,
                                        getAttributes(), onLoad: () {
                                      print("rokt_sdk loaded");
                                    }, onUnLoad: () {
                                      print("rokt_sdk unloaded");
                                    }, onShouldShowLoadingIndicator: () {
                                      print(
                                          "rokt_sdk onShouldShowLoadingIndicator");
                                    }, onShouldHideLoadingIndicator: () {
                                      print(
                                          "rokt_sdk onShouldHideLoadingIndicator");
                                    });
                                  })
                            ]),
                        TextField(
                            controller: attributesController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null),
                        const Text("Location 1"),
                        const RoktWidget(placeholderName: "Location1"),
                        const Text("Location 2"),
                        const RoktWidget(placeholderName: "Location2"),
                        const Text("The end")
                      ],
                    ),
                  ),
                ),
              ]),
            )));
  }
}
