import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/models/Notification.dart';
import 'package:kvis_sf/views/widgets/GradientAppBar.dart';
import 'package:kvis_sf/views/widgets/TriggerableWidgets.dart';
import 'package:rxdart/rxdart.dart';

class DebugPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GradientAppBar(
            title: Text(
              'Debug Menu (For Developers)',
              style: Theme
                  .of(context)
                  .textTheme
                  .headline,
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
    );
  }
}

class DebugPageContent extends StatelessWidget {
  final FirebaseMessaging _firebaseCloudMessaging = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ExpansionTile(
          title: Text('FCM Token', style: Theme
              .of(context)
              .textTheme
              .title),
          children: <Widget>[
            FutureBuilder<String>(
              future: _firebaseCloudMessaging.getToken(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SelectableText(snapshot.data,
                      style: Theme
                          .of(context)
                          .textTheme
                          .body2);
                }
                return Text('No Data',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body2);
              },
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Profile and Account',
              style: Theme
                  .of(context)
                  .textTheme
                  .title),
          children: <Widget>[
            StreamBuilder(
              stream: authService.userStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SelectableText(snapshot.data.toString(),
                      style: Theme
                          .of(context)
                          .textTheme
                          .body2);
                }
                return Text('User Data Not Available',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body2);
              },
            ),
            StreamBuilder(
              stream: authService.profileStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SelectableText(snapshot.data.toString(),
                      style: Theme
                          .of(context)
                          .textTheme
                          .body2);
                }
                return Text('User Profile Not Available',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body2);
              },
            ),
            StreamBuilder(
              stream: authService.profileStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data == null ||
                      snapshot.data.profilePicture == null) {
                    return Text('No Profile Picture',
                        style: Theme
                            .of(context)
                            .textTheme
                            .display1);
                  } else {
                    return Image.file(
                      snapshot.data.profilePicture,
                      height: 250.0,
                    );
                  }
                }
                return Text('No Profile Picture Data',
                    style: Theme
                        .of(context)
                        .textTheme
                        .display1);
              },
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
          ],
        ),
        ExpansionTile(
          title: Text('Logs', style: Theme
              .of(context)
              .textTheme
              .title),
          children: <Widget>[
            StreamBuilder(
              stream: loggingService.logsStream,
              builder: (context,
                  AsyncSnapshot<List<Timestamped<Map<String, dynamic>>>>
                  snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    shrinkWrap: true,
                    reverse: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      ...snapshot.data.map((entry) {
                        return ListTile(
                            title: Text(entry.timestamp.toLocal().toString()),
                            subtitle: SelectableText(entry.value.toString(),
                                style: Theme
                                    .of(context)
                                    .textTheme
                                    .body2));
                      })
                    ],
                  );
                }
                return Text('Logs Not Available',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body2);
              },
            ),
          ],
        ),
        ExpansionTile(
          title:
          Text('Trigger Tests', style: Theme
              .of(context)
              .textTheme
              .title),
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
                  loggingService.pushLogs({
                    'source': 'userTriggeredTest',
                    'message': 'This is a sample test log.',
                    'attachments': null
                  });
                },
                child: Text('Push New Log'),
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
      ],
    );
  }
}
