import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/views/LoginPage.dart';
import 'package:kvis_sf/views/PrimaryHomepage.dart';
import 'package:kvis_sf/views/widgets/TriggerableWidgets.dart';

void main() async {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KVIS Science Fair',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        accentColor: Colors.blueAccent,
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

class _FirebaseHandlerState extends State<FirebaseHandler>
    with WidgetsBindingObserver {
  final FirebaseMessaging _firebaseCloudMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _firebaseCloudMessaging.requestNotificationPermissions();

    _firebaseCloudMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        FlashNotification.TopNotification(
          context,
          title: Text(message["notification"]["title"] ?? "New Notification"),
          message: Text(message["notification"]["body"] ?? ""),
        );
      },
      onResume: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {},
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FlashNotification.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.suspending:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    FlashNotification.init(context);

    // Overlay is used to create FlashNotification Barrier Effect
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) =>
              StreamBuilder<FirebaseUser>(
                stream: authService.user,
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.active) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.hasError) {
                      // TODO: Handle this error
                    }

                    if (snapshot.hasData) {
                      return PrimaryHomepage();
                    }

                    return LoginPage();
                  }
                },
              ),
        ),
      ],
    );
  }
}
