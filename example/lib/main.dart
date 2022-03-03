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

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await RoktSdk.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
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
              RoktSdk.initialize('2754655826098840951', appVersion: '1.0.0');
            },
          ),
          TextButton(
            child: const Text('execute'),
            onPressed: () {
              print("execute before");
              RoktSdk.execute("iOSOverlay", getAttributes(), placeholders: Map());
            },
          ),
        ]),
      ),
    ));
  }
}
