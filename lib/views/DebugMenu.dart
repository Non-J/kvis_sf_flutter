import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/views/widgets/GradientAppBar.dart';
import 'package:kvis_sf/views/widgets/TriggerableWidgets.dart';

class DebugPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlashNotificationOverlay(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GradientAppBar(
              title: Text(
                'Debug Menu (For Developers)',
                style: Theme.of(context).textTheme.headline,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 1.0],
                colors: [
                  Color.fromRGBO(203, 53, 108, 1.0),
                  Color.fromRGBO(189, 64, 50, 1.0),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(15.0),
                scrollDirection: Axis.vertical,
                primary: true,
                child: DebugPageContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DebugPageContent extends StatefulWidget {
  const DebugPageContent({
    Key key,
  }) : super(key: key);

  @override
  _DebugPageContentState createState() => _DebugPageContentState();
}

class _DebugPageContentState extends State<DebugPageContent> {
  StreamSubscription _profileSubscription;

  final FirebaseMessaging _firebaseCloudMessaging = FirebaseMessaging();
  String fcmToken = '';
  UserProfile _profile;

  @override
  initState() {
    super.initState();

    _profileSubscription =
        authService.profileStream.listen((state) =>
            setState(() {
              _profile = state;
            }));

    _firebaseCloudMessaging.getToken().then((token) {
      setState(() {
        fcmToken = token;
      });
    });
  }

  @override
  void dispose() {
    _profileSubscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('FCM Token: ', style: Theme
            .of(context)
            .textTheme
            .title),
        SelectableText(fcmToken, style: Theme
            .of(context)
            .textTheme
            .body2),
        Divider(height: 10.0),
        Text('Profile Data', style: Theme
            .of(context)
            .textTheme
            .title),
        SelectableText(authService.user.toString(),
            style: Theme
                .of(context)
                .textTheme
                .body2),
        SelectableText(_profile.toString(),
            style: Theme
                .of(context)
                .textTheme
                .body2),
        (_profile == null || _profile.profilePicture == null)
            ? Text(
          'No Profile Picture',
          style: Theme
              .of(context)
              .textTheme
              .display1,
        )
            : Image.file(
          _profile.profilePicture,
          height: 250.0,
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          child: RaisedButton(
            onPressed: () {
              authService.signOut();
            },
            child: Text('Logout'),
            color: Colors.redAccent,
            textColor: Colors.white,
          ),
        ),
        Divider(height: 10.0),
        Text('Trigger Tests', style: Theme
            .of(context)
            .textTheme
            .title),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(horizontal: 2.0),
                child: RaisedButton(
                  onPressed: () {
                    FlashNotification.SimpleDialog(
                      context,
                      title: Text('Test Notification'),
                      message: Text('Test Content'),
                    );
                  },
                  child: Text('Dialog Test'),
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: RaisedButton(
                  onPressed: () {
                    FlashNotification.TopNotification(
                      context,
                      title: Text('Test Notification'),
                      message: Text('Test Content'),
                    );
                  },
                  child: Text('Notification Test'),
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: RaisedButton(
                  onPressed: () {
                    FlashNotification.TopNotificationCritical(
                      context,
                      title: Text('Test Notification'),
                      message: Text('Test Content'),
                    );
                  },
                  child: Text('Critical Notification Test'),
                  color: Colors.blueAccent,
                  textColor: Colors.white,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                child: RaisedButton(
                  onPressed: () {
                    Crashlytics.instance.crash();
                  },
                  child: Text('Crash App'),
                  color: Colors.deepOrange.shade800,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
