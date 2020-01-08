import 'dart:collection';

import 'package:rxdart/rxdart.dart';

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
      while (collection.length >
          // CONFIG: In app log size
          (0)) {
        collection.removeFirst();
      }
      collection.addLast(val);
      return collection;
    }, Queue<Timestamped<Map<String, dynamic>>>()).map(
        (collection) => collection.toList()));
  }

  void pushLogs(Map<String, dynamic> newLog) {
    _logsInput.add(newLog);
  }
}

final LoggingService loggingService = LoggingService();
