import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
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
            Container(
              margin: EdgeInsets.all(10.0),
              child: SingleChildScrollView(
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
  final FirebaseMessaging _firebaseCloudMessaging = FirebaseMessaging();
  String fcmToken = '';
  Map<String, dynamic> _profile;

  @override
  initState() {
    super.initState();

    authService.profile.listen((state) => setState(() => _profile = state));

    _firebaseCloudMessaging.getToken().then((token) {
      setState(() {
        fcmToken = token;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('FCM Token: ', style: Theme.of(context).textTheme.title),
          SelectableText(fcmToken, style: Theme.of(context).textTheme.body2),
          Divider(height: 10.0),
          Text('Profile Data', style: Theme.of(context).textTheme.title),
          SelectableText(_profile.toString(),
              style: Theme.of(context).textTheme.body2),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 2.0),
            child: RaisedButton(
              onPressed: () {
                authService.signOut();
              },
              child: Text('Logout'),
              color: Colors.redAccent,
            ),
          ),
          Divider(height: 10.0),
          Text('Trigger Tests', style: Theme.of(context).textTheme.title),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
