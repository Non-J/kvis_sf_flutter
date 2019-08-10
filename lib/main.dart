import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:kvis_sf/views/PrimaryHomepage.dart';
import 'package:kvis_sf/views/LoginPage.dart';
import 'package:kvis_sf/views/widgets/TriggerableWidgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KVIS Science Fair',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.purple,
        accentColor: Colors.purple,
        typography: Typography(
          platform: TargetPlatform.android,
          englishLike: Typography.englishLike2018,
          dense: Typography.dense2018,
          tall: Typography.tall2018,
        ),
      ),
      home: FirebaseHandler(),
    );
  }
}

class FirebaseHandler extends StatefulWidget {
  @override
  createState() => _FirebaseHandlerState();
}

class _FirebaseHandlerState extends State<FirebaseHandler> {
  final FirebaseMessaging _firebaseCloudMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    _firebaseCloudMessaging.requestNotificationPermissions();

    _firebaseCloudMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        triggerAlert(
            context, Text("New Notification"), Text(message.toString()), []);
      },
      onResume: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return Center(
            child: Column(
              children: <Widget>[
                CircularProgressIndicator(),
                Text(
                  "Loading...",
                  style: Theme
                      .of(context)
                      .textTheme
                      .subtitle,
                ),
              ],
            ),
          );
        } else {
          if (snapshot.hasData) {
            return PrimaryHomepage();
          }

          return LoginPage();
        }
      },
    );
  }
}
