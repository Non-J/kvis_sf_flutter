import 'dart:collection';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

final FirebaseMessaging _firebaseCloudMessaging = FirebaseMessaging();

class NotificationService {
  PublishSubject<Map<String, dynamic>> _messagesSubject = PublishSubject();

  Observable<Map<String, dynamic>> get messagesStream =>
      _messagesSubject.stream;

  void dispose() {
    _messagesSubject.close();
  }

  NotificationService() {
    _firebaseCloudMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        // App is in foreground while notification is received
        _messagesSubject.add(message);
        loggingService
            .pushLogs({'source': 'fcmNotificationMessage', 'message': message});
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
  }

  void requestPermission() {
    _firebaseCloudMessaging.requestNotificationPermissions();
  }
}

final NotificationService notificationService = NotificationService();

class LoggingService {
  PublishSubject<Map<String, dynamic>> _logsInput = PublishSubject();

  BehaviorSubject<List<Timestamped<Map<String, dynamic>>>> _logsSubject =
  BehaviorSubject.seeded([]);

  Observable<List<Timestamped<Map<String, dynamic>>>> get logsStream =>
      _logsSubject.stream;

  void dispose() {
    _logsSubject.close();
    _logsInput.close();
  }

  LoggingService() {
    // Add Timestamp and Queue Buffering to logs
    _logsSubject.addStream(_logsInput.timestamp().scan(
            (Queue<Timestamped<Map<String, dynamic>>> collection,
            Timestamped<Map<String, dynamic>> val, int idx) {
          while (collection.length > 100) {
            collection.removeFirst();
          }
          collection.addLast(val);
          return collection;
        }, Queue<Timestamped<Map<String, dynamic>>>()).map(
            (collection) => collection.toList(growable: false)));
  }

  void pushLogs(Map<String, dynamic> newLog) {
    _logsInput.add(newLog);
  }
}

final LoggingService loggingService = LoggingService();
