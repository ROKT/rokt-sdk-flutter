import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:rokt_sdk/rokt_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  Map<int, String> placeholders = Map();

  @override
  void initState() {
    super.initState();
  }

  Map getAttributes() {
    return {"email": "j.smithasd123@example.com",
      "firstname": "Jenny",
      "lastname": "Smith",
      "mobile": "(555)867-5309",
      "postcode": "90210",
      "sandbox": "true",
      "country": "US"};
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Column(children: [
          TextButton(
            child: const Text('initial'),
            onPressed: () {
              print("initial before");
              RoktSdk.initialize('2570597781472571104', appVersion: '1.0.0');
            },
          ),
          TextButton(
            child: const Text('execute'),
            onPressed: () {
              print("execute before");
              RoktSdk.execute("test", getAttributes(), (dynamic msg) { print("rokt_sdk $msg"); }, placeholders: placeholders);
            },
          ),
          Flexible(
              child:
                  RoktWidget(viewName: "Location1")
          ),
          Flexible(
              child:
                  RoktWidget(viewName: "Location2")
          )
        ]),
      ),
    ));
  }
}
