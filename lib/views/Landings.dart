import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/views/widgets/TriggerableWidgets.dart';

class LandingWidget extends StatefulWidget {
  @override
  _LandingWidgetState createState() => _LandingWidgetState();
}

class _LandingWidgetState extends State<LandingWidget> {
  final FirebaseMessaging _firebaseCloudMessaging = FirebaseMessaging();
  StreamSubscription _authServiceRedirect;

  @override
  void initState() {
    super.initState();

    _firebaseCloudMessaging.requestNotificationPermissions();

    _firebaseCloudMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        FlashNotification.TopNotification(
          context,
          title: Text(message['notification']['title'] ?? 'New Notification'),
          message: Text(message['notification']['body'] ?? ''),
        );
      },
      onResume: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {},
    );

    _authServiceRedirect = authService.userStream.listen((user) {
      if (user == null) {
        Future(() {
          Navigator.of(context).pushReplacementNamed('/login');
        });
      } else {
        Future(() {
          Navigator.of(context).pushReplacementNamed('/home');
        });
      }
    });
  }

  @override
  void dispose() {
    _authServiceRedirect.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 1.0],
            colors: [
              Color.fromRGBO(212, 234, 209, 1.0),
              Color.fromRGBO(184, 213, 233, 1.0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
