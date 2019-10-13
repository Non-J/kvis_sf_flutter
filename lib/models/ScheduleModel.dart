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

  String get beginTimeString => DateFormat("Hm").format(this.begin.toLocal());

  String get endTimeString => (this.beginDate == this.endDate
      ? DateFormat("Hm").format(this.end.toLocal())
      : "${DateFormat("d/MMM").format(this.end.toLocal())} ${DateFormat("Hm").format(this.end.toLocal())} ");
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
    _db.collection("schedules").getDocuments().then((collectionSnapshot) {
      collectionSnapshot.documents.forEach((document) {
        _data.add(ScheduledEvent(
            id: document.documentID,
            name: document.data["name"] ?? "No Name",
            location: document.data["location"] ?? "No Specified Location",
            details: document.data["details"] ?? "No Specified Details",
            begin: DateTime.fromMillisecondsSinceEpoch(
                document.data["begin"] ?? 0),
            end: DateTime.fromMillisecondsSinceEpoch(
                document.data["end"] ?? 0)));
      });
    }).then((_) {
      scheduledEvents.add(_data);
    }).catchError((err) {
      // TODO: Handle DB errors
      throw err;
    });
    return Future.value(null);
  }
}

final ScheduleService scheduleService = ScheduleService();

List<ScheduledEvent> getScheduledEvents() {
  // TODO Remove this
  return _officialSchedule;
}

final List<ScheduledEvent> _officialSchedule = [
  ScheduledEvent(
      id: "Awaiting",
      name: "Waiting for something AWESOME!",
      location: "Anywhere",
      details: "Get ready for an experience you'll never forget!",
      begin: DateTime.now(),
      end: DateTime.utc(2020, 1, 15, 2)),
  ScheduledEvent(
      id: "Arrival",
      name: "Arrival and Registration",
      location: "Domitory",
      details: "Meet your buddies and prepare your poster for presentation.",
      begin: DateTime.utc(2020, 1, 15, 2),
      end: DateTime.utc(2020, 1, 15, 10)),
  ScheduledEvent(
      id: "ThaiCulture",
      name: "Thai Culture Experience and Dinner",
      location: "Main Building",
      details:
          "Experience the wonderful Thai culture and taste award-winning Thai foods.",
      begin: DateTime.utc(2020, 1, 15, 8),
      end: DateTime.utc(2020, 1, 15, 11, 30)),
  ScheduledEvent(
      id: "Briefing",
      name: "Briefing",
      location: "Thongchai Chewprecha Auditorium",
      details: "Brienfing for the activities of ISSF 2020.",
      begin: DateTime.utc(2020, 1, 15, 11, 45),
      end: DateTime.utc(2020, 1, 15, 13)),
  ScheduledEvent(
      id: "Breakfast1",
      name: "Breakfast",
      location: "Cafeteria",
      details: "Have your breakfast.",
      begin: DateTime.utc(2020, 1, 16, 0),
      end: DateTime.utc(2020, 1, 16, 1)),
  ScheduledEvent(
      id: "Opening",
      name: "Opening Ceremony",
      location: "Thongchai Chewprecha Auditorium",
      details:
          "Opening Ceremony and Welcome Performances.\nKeynote by a Prominent Thai Scientist.",
      begin: DateTime.utc(2020, 1, 16, 2),
      end: DateTime.utc(2020, 1, 16, 4, 30)),
  ScheduledEvent(
      id: "Lunch1",
      name: "Lunch",
      location: "Cafeteria",
      details: "Have your lunch.",
      begin: DateTime.utc(2020, 1, 16, 4, 30),
      end: DateTime.utc(2020, 1, 16, 6)),
  ScheduledEvent(
      id: "Poster",
      name: "Poster Presentation",
      location: "Academic Resource Center",
      details: "Present your posters.",
      begin: DateTime.utc(2020, 1, 16, 6),
      end: DateTime.utc(2020, 1, 16, 9, 30)),
  ScheduledEvent(
      id: "DinnerCulture",
      name: "Dinner and Thai Cultural Performance",
      location: "Main Building",
      details: "Have your dinner while enjoying Thai cultural performances.",
      begin: DateTime.utc(2020, 1, 16, 10),
      end: DateTime.utc(2020, 1, 16, 13, 30)),
  ScheduledEvent(
      id: "Breakfast2",
      name: "Breakfast",
      location: "Cafeteria",
      details: "Have your brakfast.",
      begin: DateTime.utc(2020, 1, 17, 0),
      end: DateTime.utc(2020, 1, 17, 1, 30)),
  ScheduledEvent(
      id: "Presentation1",
      name: "Oral Presentation",
      location: "Main Building",
      details: "Present about your projects to a panel of judges.",
      begin: DateTime.utc(2020, 1, 17, 2),
      end: DateTime.utc(2020, 1, 17, 5, 30)),
  ScheduledEvent(
      id: "Lunch2",
      name: "Lunch",
      location: "Cafeteria",
      details: "Have your lunch.",
      begin: DateTime.utc(2020, 1, 17, 5, 30),
      end: DateTime.utc(2020, 1, 17, 6, 30)),
  ScheduledEvent(
      id: "Presentation2",
      name: "Oral Presentation",
      location: "Main Building",
      details: "Present about your projects to a panel of judges.",
      begin: DateTime.utc(2020, 1, 17, 6, 30),
      end: DateTime.utc(2020, 1, 17, 9, 30)),
  ScheduledEvent(
      id: "Acts",
      name: "Activities",
      location: "Around the campus",
      details: "Enjoy various activities around the campus.",
      begin: DateTime.utc(2020, 1, 17, 9, 30),
      end: DateTime.utc(2020, 1, 17, 11, 30)),
  ScheduledEvent(
      id: "Dinner2",
      name: "Dinner",
      location: "Cafeteria",
      details: "Have your dinner.",
      begin: DateTime.utc(2020, 1, 17, 11, 30),
      end: DateTime.utc(2020, 1, 17, 12, 30)),
  ScheduledEvent(
      id: "Briefing2",
      name: "Briefing",
      location: "Thongchai Chewprecha Auditorium",
      details: "Briefing about tomorrow's activites.",
      begin: DateTime.utc(2020, 1, 17, 12, 30),
      end: DateTime.utc(2020, 1, 17, 15)),
  ScheduledEvent(
      id: "Breakfast3",
      name: "Breakfast",
      location: "Cafeteria",
      details: "Have your breakfast.",
      begin: DateTime.utc(2020, 1, 18, 0),
      end: DateTime.utc(2020, 1, 18, 1, 30)),
  ScheduledEvent(
      id: "SciAct",
      name: "Scientific Activities",
      location: "Main Building",
      details: "Have fun with various scientific activiites.",
      begin: DateTime.utc(2020, 1, 18, 2),
      end: DateTime.utc(2020, 1, 18, 5)),
  ScheduledEvent(
      id: "Lunch3",
      name: "Lunch",
      location: "Cafeteria",
      details: "Have your lunch.",
      begin: DateTime.utc(2020, 1, 18, 5),
      end: DateTime.utc(2020, 1, 18, 6)),
  ScheduledEvent(
      id: "SciAct2",
      name: "Scientific Activities",
      location: "Main Building",
      details: "Have fun with various scientific activiites.",
      begin: DateTime.utc(2020, 1, 18, 6),
      end: DateTime.utc(2020, 1, 18, 9)),
  ScheduledEvent(
      id: "RecAct",
      name: "Recreational Activities",
      location: "Around the Campus",
      details: "Relax with various recrational activities around the campus.",
      begin: DateTime.utc(2020, 1, 18, 9),
      end: DateTime.utc(2020, 1, 18, 11)),
  ScheduledEvent(
      id: "Dinner3",
      name: "Dinner",
      location: "Cafeteria",
      details: "Have your dinner.",
      begin: DateTime.utc(2020, 1, 18, 11),
      end: DateTime.utc(2020, 1, 18, 12, 30)),
  ScheduledEvent(
      id: "Briefing3",
      name: "Briefing",
      location: "Thongchai Chewprecha Auditorium",
      details: "Briefing on scientific and cultural excursions.",
      begin: DateTime.utc(2020, 1, 18, 12, 30),
      end: DateTime.utc(2020, 1, 18, 14)),
  ScheduledEvent(
      id: "Excursion",
      name: "Scientific and Cultural Excursions",
      location: "Thailand",
      details: "Explore culture of Thailand through excursions.",
      begin: DateTime.utc(2020, 1, 18, 23),
      end: DateTime.utc(2020, 1, 19, 9, 30)),
  ScheduledEvent(
      id: "Closing",
      name: "Closing Ceremony",
      location: "Thongchai Chewprecha Auditorium",
      details: "Closing ceremony for ISSF 2020.",
      begin: DateTime.utc(2020, 1, 19, 10, 15),
      end: DateTime.utc(2020, 1, 19, 11, 30)),
  ScheduledEvent(
      id: "Farewell",
      name: "Cultural Performances and Farewell Party",
      location: "Main Building",
      details:
          "Share your culture though performances.\nSay goodbye to new friends.",
      begin: DateTime.utc(2020, 1, 19, 11, 30),
      end: DateTime.utc(2020, 1, 19, 15, 30)),
  ScheduledEvent(
      id: "Breakfast4",
      name: "Breakfast",
      location: "Cafeteria",
      details: "Have your breakfast.",
      begin: DateTime.utc(2020, 1, 20, 0),
      end: DateTime.utc(2020, 1, 20, 1, 30)),
  ScheduledEvent(
      id: "Depart",
      name: "Departure",
      location: "Meeting Point",
      details: "Hope to see you soon!",
      begin: DateTime.utc(2020, 1, 20, 1),
      end: DateTime.utc(2020, 1, 20, 5)),
];
