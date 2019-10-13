import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kvis_sf/models/ScheduleModel.dart';

class ScheduleWidget extends StatefulWidget {
  ScheduleWidget({Key key}) : super(key: key);

  @override
  _ScheduleWidgetState createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends State<ScheduleWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: ScheduleCalendar(),
    );
  }
}

class ScheduleCalendar extends StatefulWidget {
  @override
  _ScheduleCalendarState createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  final ScrollController _scheduleScroller = ScrollController();
  StreamSubscription<List<ScheduledEvent>> _scheduleServiceSubscription;
  List<ScheduledEvent> _scheduledEvents;
  List<Widget> _entries;

  @override
  void initState() {
    super.initState();

    _scheduledEvents = <ScheduledEvent>[];
    _entries = <Widget>[];

    _scheduleServiceSubscription =
        scheduleService.scheduledEvents.listen((list) {
          setState(() {
            _scheduledEvents = list;
            _entries = _getScheduleWidgets();
          });
        });
  }

  @override
  void dispose() {
    _scheduleScroller.dispose();
    _scheduleServiceSubscription.cancel();

    super.dispose();
  }

  List<Widget> _getScheduleWidgets() {
    List<Widget> result = [];

    Map<DateTime, List<ScheduledEvent>> datedEvents = {};

    for (var event in _scheduledEvents) {
      if (datedEvents.containsKey(event.beginDate)) {
        datedEvents[event.beginDate].add(event);
      } else {
        datedEvents.putIfAbsent(event.beginDate, () => [event]);
      }
    }

    List<DateTime> sortedKeys = datedEvents.keys.toList()
      ..sort((x, y) => x.compareTo(y));

    for (var date in sortedKeys) {
      result.add(ScheduleCalendarDate(date));

      for (var event in datedEvents[date]) {
        result.add(ScheduleCalendarEntry(event));
      }

      result.add(Divider());
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return (_entries.isEmpty
        ? Center(
      child: CircularProgressIndicator(),
    )
        : Container(
      child: RefreshIndicator(
        onRefresh: scheduleService.reload,
        child: ListView(
          controller: _scheduleScroller,
          children: _entries,
          physics: AlwaysScrollableScrollPhysics(),
        ),
      ),
    ));
  }
}

class ScheduleCalendarDate extends StatelessWidget {
  final DateTime date;

  ScheduleCalendarDate(this.date);

  @override
  Widget build(BuildContext context) {
    Color _color;

    switch (date.weekday) {
      case DateTime.monday:
        _color = Colors.yellowAccent.shade100.withAlpha(128);
        break;
      case DateTime.tuesday:
        _color = Colors.pinkAccent.shade100.withAlpha(128);
        break;
      case DateTime.wednesday:
        _color = Colors.greenAccent.shade100.withAlpha(128);
        break;
      case DateTime.thursday:
        _color = Colors.orangeAccent.shade100.withAlpha(128);
        break;
      case DateTime.friday:
        _color = Colors.blueAccent.shade100.withAlpha(128);
        break;
      case DateTime.saturday:
        _color = Colors.purpleAccent.shade100.withAlpha(128);
        break;
      case DateTime.sunday:
        _color = Colors.redAccent.shade100.withAlpha(128);
        break;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      elevation: 0,
      color: _color,
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              DateFormat("EEEE").format(date),
              style: Theme
                  .of(context)
                  .textTheme
                  .display1,
            ),
            Text(
              DateFormat("d MMMM y").format(date),
              style: Theme
                  .of(context)
                  .textTheme
                  .display1,
              textScaleFactor: 0.7,
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleCalendarEntry extends StatefulWidget {
  @override
  _ScheduleCalendarEntryState createState() => _ScheduleCalendarEntryState();

  final ScheduledEvent event;

  ScheduleCalendarEntry(this.event);
}

class _ScheduleCalendarEntryState extends State<ScheduleCalendarEntry> {
  void _onTap() {
    _changeOnGoingState();
  }

  bool _onGoing = false;

  void _changeOnGoingState() {
    if (DateTime.now().isAfter(widget.event.begin) &&
        DateTime.now().isBefore(widget.event.end)) {
      setState(() {
        _onGoing = true;
      });
    } else {
      setState(() {
        _onGoing = false;
      });
    }
  }

  @override
  void initState() {
    _changeOnGoingState();

    if (DateTime.now().isBefore(widget.event.begin)) {
      Timer(
          widget.event.begin.difference(DateTime.now()) + Duration(seconds: 2),
          _changeOnGoingState);
    }

    if (DateTime.now().isBefore(widget.event.end)) {
      Timer(widget.event.end.difference(DateTime.now()) + Duration(seconds: 2),
          _changeOnGoingState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Color.fromRGBO(255, 255, 255, 0.7),
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: InkWell(
        onTap: _onTap,
        child: Container(
          child: ListTile(
            isThreeLine: true,
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  (_onGoing
                      ? Chip(
                    label: Text("On Going"),
                    backgroundColor: Colors.lightGreenAccent,
                  )
                      : Text("")),
                  Text(
                    widget.event.name,
                    style: Theme
                        .of(context)
                        .textTheme
                        .headline,
                    textScaleFactor: 1.2,
                  ),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.event.beginTimeString} - ${widget.event
                      .endTimeString} at ${widget.event.location}",
                  style: Theme
                      .of(context)
                      .textTheme
                      .headline,
                  textScaleFactor: 0.8,
                ),
                Text(
                  widget.event.details,
                  style: Theme
                      .of(context)
                      .textTheme
                      .body1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
