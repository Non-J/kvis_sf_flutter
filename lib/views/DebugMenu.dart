import 'dart:io';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kvis_sf/models/Authentication.dart';
import 'package:kvis_sf/models/InAppLogging.dart';
import 'package:kvis_sf/views/widgets/TriggerableWidgets.dart';
import 'package:rxdart/rxdart.dart';

class DebugPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlashNotificationOverlay(
      child: Scaffold(
        appBar: AppBar(title: Text('Debug Menu (For Developers)')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(15.0),
            scrollDirection: Axis.vertical,
            primary: true,
            child: DebugPageContent(),
          ),
        ),
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
                return Text(
                    'User Data Not Available\nStatus: ${snapshot.connectionState
                        .toString()}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body2);
              },
            ),
            Divider(height: 25.0, thickness: 3.0),
            StreamBuilder(
              stream: authService.dataStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SelectableText(snapshot.data.toString(),
                      style: Theme
                          .of(context)
                          .textTheme
                          .body2);
                }
                return Text(
                    'User Profile Not Available\nStatus: ${snapshot
                        .connectionState.toString()}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body2);
              },
            ),
            Divider(height: 25.0, thickness: 3.0),
            FutureBuilder<File>(
              future: authService.getProfilePicture(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.file(
                    snapshot.data,
                    height: 250.0,
                  );
                }
                return Text(
                    'No Profile Picture Data\nStatus: ${snapshot.connectionState
                        .toString()}',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body2);
              },
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 2.0),
              child: RaisedButton(
                onPressed: () {
                  authService.signOut();
                },
                child: Text('Sign Out'),
                color: Theme
                    .of(context)
                    .errorColor,
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
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              child: RaisedButton(
                onPressed: () {
                  Crashlytics.instance.crash();
                },
                child: Text('Crash App'),
                color: Theme
                    .of(context)
                    .errorColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
