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
    return {
      "email": "j.smithasd123@example.com",
      "firstname": "Jenny",
      "lastname": "Smith",
      "mobile": "(555)867-5309",
      "postcode": "90210",
      "sandbox": "true",
      "country": "US"
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: CustomScrollView(shrinkWrap: true, slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  TextButton(
                    child: const Text('initial'),
                    onPressed: () {
                      RoktSdk.initialize('2570597781472571104',
                          appVersion: '1.0.0');
                    },
                  ),
                  TextButton(
                    child: const Text('execute'),
                    onPressed: () {
                      RoktSdk.execute("test", getAttributes(), (dynamic msg) {
                        print("rokt_sdk $msg");
                      });
                  },
                ),
                const Text("Location 1"),
                RoktWidget(placeholderName: "Location1"),
                const Text("Location 2"),
                RoktWidget(placeholderName: "Location2"),
                const Text("The end")
              ],
              ),
            ),
          ),
        ]),
    ));
  }
}
