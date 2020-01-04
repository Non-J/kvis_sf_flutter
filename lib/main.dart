import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kvis_sf/models/InAppLogging.dart';
import 'package:kvis_sf/models/Notification.dart';
import 'package:kvis_sf/views/DebugMenu.dart';
import 'package:kvis_sf/views/Landings.dart';
import 'package:kvis_sf/views/LoginPage.dart';
import 'package:kvis_sf/views/PrimaryHomepage.dart';
import 'package:kvis_sf/views/ProfilePage.dart';
import 'package:kvis_sf/views/QRPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails error) {
    loggingService
        .pushLogs({'source': 'FlutterErrorHandler', 'error': error.toString()});
    Crashlytics.instance.recordFlutterError(error);
  };

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _firebaseCloudMessaging = FirebaseMessaging();

  @override
  void initState() {
    if (Platform.isIOS) {
      _firebaseCloudMessaging.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true));
    }

    _firebaseCloudMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        // App is in foreground while notification is received
        loggingService
            .pushLogs({'source': 'fcmNotificationMessage', 'message': message});
        localNotificationService.sendMessage(
            title: 'Test Message', body: message.toString(), payload: null);
      },
      onResume: (Map<String, dynamic> message) async {
        // App is in background while notification is received
        // Also happens when user clicks the notification, even if the app is now in foreground
        loggingService
            .pushLogs({'source': 'fcmNotificationResume', 'message': message});
      },
      onLaunch: (Map<String, dynamic> message) async {
        // App is terminated while notification is received
        loggingService
            .pushLogs({'source': 'fcmNotificationLaunch', 'message': message});
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KVIS Science Fair',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade900,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue.shade700,
        ),
        typography: Typography(
          platform: TargetPlatform.android,
          englishLike: Typography.englishLike2018,
          dense: Typography.dense2018,
          tall: Typography.tall2018,
        ),
      ),
      home: LandingWidget(),
      routes: {
        '/home': (context) => primaryHomepage(),
        '/profile': (context) => ProfilePage(),
        '/QRPage': (context) => QRPage(),
        '/debug': (context) => DebugPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
