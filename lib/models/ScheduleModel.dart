import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class ScheduledEvent {
  final String id, name, location, details;
  final DateTime begin, end;

  ScheduledEvent(
      {this.id, this.name, this.location, this.details, this.begin, this.end});

  DateTime get beginDate => DateTime(this.begin.toLocal().year,
      this.begin.toLocal().month, this.begin.toLocal().day);

  DateTime get endDate => DateTime(this.end.toLocal().year,
      this.end.toLocal().month, this.end.toLocal().day);

  String get beginTimeString => DateFormat('Hm').format(this.begin.toLocal());

  String get endTimeString => (this.beginDate == this.endDate
      ? DateFormat('Hm').format(this.end.toLocal())
      : '${DateFormat('d/MMM').format(this.end.toLocal())} ${DateFormat('Hm')
      .format(this.end.toLocal())} ');
}

class ScheduleService {
  final Firestore _db = Firestore.instance;

  List<ScheduledEvent> _data;

  BehaviorSubject<List<ScheduledEvent>> scheduledEvents;

  ScheduleService() {
    _data = [];
    scheduledEvents = BehaviorSubject<List<ScheduledEvent>>.seeded(_data);
    reload();
  }

  Future reload() {
    _data.clear();
    return _db
        .collection('schedules')
        .getDocuments()
        .then((collectionSnapshot) {
      collectionSnapshot.documents.forEach((document) {
        if (document.data['events'] is List) {
          document.data['events'].forEach((elm) {
            _data.add(ScheduledEvent(
                id: document.documentID,
                name: elm['name'] ?? 'No Name',
                location: elm['location'] ?? 'No Specified Location',
                details: elm['details'] ?? 'No Specified Details',
                begin: DateTime.fromMillisecondsSinceEpoch(elm['begin'] ?? 0),
                end: DateTime.fromMillisecondsSinceEpoch(elm['end'] ?? 0)));
          });
        } else {
          _data.add(ScheduledEvent(
              id: document.documentID,
              name: document.data['name'] ?? 'No Name',
              location: document.data['location'] ?? 'No Specified Location',
              details: document.data['details'] ?? 'No Specified Details',
              begin: DateTime.fromMillisecondsSinceEpoch(
                  document.data['begin'] ?? 0),
              end: DateTime.fromMillisecondsSinceEpoch(
                  document.data['end'] ?? 0)));
        }
      });
    }).then((_) {
      scheduledEvents.add(_data);
    }).catchError((err) {
      // TODO: Handle DB errors
      throw err;
    });
  }
}

final ScheduleService scheduleService = ScheduleService();
