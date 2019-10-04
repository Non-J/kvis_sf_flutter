import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import "package:flutter/services.dart";
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
    AuthSystem.init();

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
  final Stream<AuthUser> authStateChanged = AuthSystem.onAuthStateChanged;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _firebaseCloudMessaging.requestNotificationPermissions();

    _firebaseCloudMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        triggerAlert(context,
            title: Text(message["notification"]["title"] ?? "New Notification"),
            child: Text(message["notification"]["body"] ?? ""),
            actions: [
              FlatButton(
                child: new Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
            backgroundDismissible: false);
      },
      onResume: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {},
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
    return StreamBuilder<AuthUser>(
      stream: authStateChanged,
      initialData: AuthSystem.authUser,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          if (snapshot.hasData &&
              snapshot.data.logInMode != LogInMode.notLoggedIn) {
            return PrimaryHomepage();
          }

          return LoginPage();
        }
      },
    );
  }
}
