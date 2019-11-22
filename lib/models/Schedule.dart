import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:kvis_sf/models/Authentication.dart';
import 'package:rxdart/rxdart.dart';

class QueryProfilePair {
  QueryProfilePair(this.left, this.right);

  final List<DocumentSnapshot> left;
  final Map<String, dynamic> right;
}

class ScheduledEvent {
  final String id, name, location, details;
  final DateTime begin, end;

  ScheduledEvent(
      {this.id, this.name, this.location, this.details, this.begin, this.end});

  DateTime get beginDate => DateTime(this.begin.toLocal().year,
      this.begin.toLocal().month, this.begin.toLocal().day);

  DateTime get endDate => DateTime(this.end.toLocal().year,
      this.end.toLocal().month, this.end.toLocal().day);

  String get beginTimeString =>
      (this.beginDate == this.endDate
          ? DateFormat('Hm').format(this.begin.toLocal())
          : '${DateFormat('d/MMM').format(this.begin.toLocal())} ${DateFormat(
          'Hm').format(this.begin.toLocal())}');

  String get endTimeString => (this.beginDate == this.endDate
      ? DateFormat('Hm').format(this.end.toLocal())
      : '${DateFormat('d/MMM').format(this.end.toLocal())} ${DateFormat('Hm')
      .format(this.end.toLocal())}');

  @override
  String toString() {
    return 'ScheduledEvent: $name, $location, $details, ${begin
        .toString()}, ${end.toString()}';
  }
}

class ScheduleService {
  final Firestore _db = Firestore.instance;

  BehaviorSubject<List<ScheduledEvent>> _eventsSubject = BehaviorSubject();

  Observable<List<ScheduledEvent>> get eventsStream => _eventsSubject.stream;

  ScheduleService() {
    _eventsSubject.addStream(Observable.combineLatest2(
        _db.collection('schedules').snapshots(),
        authService.dataStream,
            (query, profile) => QueryProfilePair(query.documents, profile))
    // Filter for targeted audience
        .map((pair) =>
        pair.left
            .where((doc) => doc.data['audience'] == (pair.right['role']))
            .toList())
    // Extract individual event entry
        .map((docs) {
      List<Map<String, dynamic>> result = [];
      docs.forEach((doc) {
        (doc.data['events'] ?? []).forEach((entry) {
          result.add(Map<String, dynamic>.from(entry));
        });
      });
      return result;
      // Turn raw event entry into ScheduledEvent
    }).map((entries) {
      List<ScheduledEvent> result = [];
      entries.forEach((entry) {
        result.add(ScheduledEvent(
            id: '',
            name: entry['name'] ?? 'No Name',
            location: entry['location'] ?? 'No Specified Location',
            details: entry['details'] ?? 'No Specified Details',
            begin: DateTime.fromMillisecondsSinceEpoch(entry['begin'] ?? 0),
            end: DateTime.fromMillisecondsSinceEpoch(entry['end'] ?? 0)));
      });
      result.sort((x, y) => x.begin.compareTo(y.begin));
      return result;
    }));
  }

  void dispose() {
    _eventsSubject.close();
  }
}

final ScheduleService scheduleService = ScheduleService();