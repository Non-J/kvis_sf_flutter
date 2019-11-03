import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kvis_sf/views/DebugMenu.dart';
import 'package:kvis_sf/views/Landings.dart';
import 'package:kvis_sf/views/LoginPage.dart';
import 'package:kvis_sf/views/PrimaryHomepage.dart';
import 'package:kvis_sf/views/ProfilePage.dart';

void main() async {
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

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
  @override
  void initState() {
    super.initState();
  }

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
      home: LandingWidget(),
      routes: {
        '/home': (context) => primaryHomepage(),
        '/profile': (context) => ProfilePage(),
        '/debug': (context) => DebugPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}
