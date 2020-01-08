import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class ContentService {
  final Firestore _db = Firestore.instance;

  BehaviorSubject<QuerySnapshot> _featuredContentSubject = BehaviorSubject();

  Observable<QuerySnapshot> get featuredContentStream =>
      _featuredContentSubject.stream;

  BehaviorSubject<List<DocumentSnapshot>> _scheduleSubject = BehaviorSubject();

  Observable<List<DocumentSnapshot>> get scheduleStream =>
      _scheduleSubject.stream;

  BehaviorSubject<List<Map<String, dynamic>>> _fullScheduleSubject =
      BehaviorSubject();

  Observable<List<Map<String, dynamic>>> get fullScheduleStream =>
      _fullScheduleSubject.stream;

  ContentService() {
    _featuredContentSubject.addStream(_db
        .collection('contents')
        .where('is_featured', isEqualTo: true)
        .orderBy("priority", descending: true)
        .snapshots());

    _scheduleSubject.addStream(_db
        .collection('schedules')
        .where('is_featured', isEqualTo: true)
        .orderBy("priority", descending: true)
        .snapshots()
        .map((query) {
      return query.documents;
    }));

    _fullScheduleSubject.addStream(_scheduleSubject.stream.map((docs) {
      List<Map<String, dynamic>> result = [];
      docs.forEach((doc) {
        if (doc.data['content_type'] != 'list_content') {
          return;
        }
        (doc.data['content'] ?? []).forEach((entry) {
          var newEntry = Map<String, dynamic>.from(entry);
          newEntry.addAll({
            'begin': (entry['begin'] is Timestamp
                ? entry['begin'].toDate()
                : DateTime.now()),
            'end': (entry['end'] is Timestamp
                ? entry['end'].toDate()
                : DateTime.now()),
          });
          if (newEntry['content_type'] == 'schedulec') {
            result.add(newEntry);
          }
        });
      });
      return result;
    }));
  }

  void dispose() {
    _featuredContentSubject.close();
    _scheduleSubject.close();
    _fullScheduleSubject.close();
  }
}

final ContentService contentService = ContentService();
