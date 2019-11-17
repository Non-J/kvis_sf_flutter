import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';

class NotificationService {
  final FirebaseMessaging _firebaseCloudMessaging = FirebaseMessaging();

  PublishSubject<Map<String, dynamic>> _messagesSubject = PublishSubject();

  Observable<Map<String, dynamic>> get messagesStream =>
      _messagesSubject.stream;

  void dispose() {
    _messagesSubject.close();
  }

  NotificationService() {
    _firebaseCloudMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _messagesSubject.add(message);
      },
      onResume: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {},
    );
  }

  void requestPermission() {
    _firebaseCloudMessaging.requestNotificationPermissions();
  }
}

final NotificationService notificationService = NotificationService();
