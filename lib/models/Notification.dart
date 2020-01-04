import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'InAppLogging.dart';

class LocalNotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  NotificationDetails messagesChannel;

  void dispose() {}

  LocalNotificationService() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {
      //TODO: On iOS notification received in the foreground should be handled by the app
    });

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String payload) async {
      loggingService
          .pushLogs({'source': 'localNotificationSelect', 'message': payload});
    });

    var messagesChannelAndroid = AndroidNotificationDetails(
      'Messages',
      'Messages',
      'Various messages and anouncements.',
    );
    var messagesChannelIOS = IOSNotificationDetails();
    messagesChannel =
        NotificationDetails(messagesChannelAndroid, messagesChannelIOS);
  }

  Future sendMessage(
      {@required String title,
      @required String body,
      @required String payload}) {
    var randomizer = Random();
    return flutterLocalNotificationsPlugin.show(
        randomizer.nextInt(10000), title, body, messagesChannel,
        payload: payload);
  }
}

final LocalNotificationService localNotificationService =
    LocalNotificationService();
