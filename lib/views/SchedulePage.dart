import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kvis_sf/models/ScheduleModel.dart';

class ScheduleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: IntrinsicWidth(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              CurrentEventDisplayWidget(),
              CalendarDateList(),
            ],
          ),
        ),
      ),
    );
  }
}

class CalendarDateList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: scheduleService.datedEventsStream,
      builder: (context,
          AsyncSnapshot<Map<DateTime, List<ScheduledEvent>>> snapshot) {
        if (snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: (snapshot.data.keys.toList()
              ..sort((x, y) => x.compareTo(y)))
                .map((date) {
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
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          DateFormat('EEEE').format(date),
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1,
                        ),
                        Text(
                          DateFormat('d MMMM y').format(date),
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1,
                          textScaleFactor: 0.7,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(growable: false),
          );
        }

        return Container();
      },
    );
  }
}

class CurrentEventDisplayWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: scheduleService.eventsStream,
      builder: (context, AsyncSnapshot<List<ScheduledEvent>> snapshot) {
        if (snapshot.hasData) {
          return Card(
            elevation: 0,
            color: Color.fromRGBO(255, 255, 255, 0.7),
            margin: EdgeInsets.symmetric(vertical: 5.0),
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Current Events',
                    style: Theme
                        .of(context)
                        .textTheme
                        .display1,
                  ),
                  ...snapshot.data.map((entry) {
                    UniqueKey _key = UniqueKey();
                    return CurrentEventDisplayWidgetEntry(
                      key: _key,
                      event: entry,
                      timeDisplayBegin: entry.begin,
                      timeDisplayEnd: entry.end,
                    );
                  }).toList(growable: false),
                  Divider(
                    height: 25.0,
                    thickness: 3.0,
                  ),
                  Text(
                    'Upcoming Events',
                    style: Theme
                        .of(context)
                        .textTheme
                        .display1,
                  ),
                  ...snapshot.data.map((entry) {
                    UniqueKey _key = UniqueKey();
                    return CurrentEventDisplayWidgetEntry(
                      key: _key,
                      event: entry,
                      timeDisplayBegin: entry.begin.add(Duration(hours: -2)),
                      timeDisplayEnd: entry.begin,
                    );
                  }).toList(growable: false),
                  Divider(
                    height: 25.0,
                    thickness: 3.0,
                  ),
                  Text(
                    'Time shown is in the timezone of your device.\nWe recommend that you chage it to Thailand\'s local time.',
                    style: Theme
                        .of(context)
                        .textTheme
                        .body2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 0,
          color: Color.fromRGBO(255, 255, 255, 0.7),
          margin: EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text('Retrieving current events.'),
                Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CurrentEventDisplayWidgetEntry extends StatefulWidget {
  @override
  _CurrentEventDisplayWidgetEntryState createState() =>
      _CurrentEventDisplayWidgetEntryState();

  final ScheduledEvent event;
  final DateTime timeDisplayBegin, timeDisplayEnd;

  CurrentEventDisplayWidgetEntry({@required this.event,
    @required this.timeDisplayBegin,
    @required this.timeDisplayEnd,
    Key key})
      : super(key: key);
}

class _CurrentEventDisplayWidgetEntryState
    extends State<CurrentEventDisplayWidgetEntry> {
  Timer _begin, _end;
  bool _active = false;

  void _changeActiveState() {
    final DateTime time = DateTime.now();
    if (time.isAfter(widget.timeDisplayBegin) &&
        time.isBefore(widget.timeDisplayEnd)) {
      setState(() {
        _active = true;
      });
    } else {
      setState(() {
        _active = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final DateTime time = DateTime.now();

    _begin =
        Timer(widget.timeDisplayBegin.difference(time), _changeActiveState);
    _end = Timer(widget.timeDisplayEnd.difference(time), _changeActiveState);

    _changeActiveState();
  }

  @override
  void dispose() {
    _begin.cancel();
    _end.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _active,
      child: Container(
        padding: EdgeInsets.fromLTRB(10.0, 0, 0, 0),
        child: ListTile(
          title: Text(widget.event.name),
          subtitle: Text(
              'Location: ${widget.event.location}\nBegin: ${widget.event
                  .beginTimeString}\nEnd: ${widget.event.endTimeString}'),
        ),
      ),
    );
  }
}

/*
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
              DateFormat('EEEE').format(date),
              style: Theme.of(context).textTheme.display1,
            ),
            Text(
              DateFormat('d MMMM y').format(date),
              style: Theme.of(context).textTheme.display1,
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

  ScheduleCalendarEntry(this.event, {Key key}) : super(key: key);
}

class _ScheduleCalendarEntryState extends State<ScheduleCalendarEntry> {
  void _onTap() {
    _changeOnGoingState();
  }

  bool _onGoing = false;
  StreamSubscription<List<ScheduledEvent>> _reloadEvent;

  Timer _begin, _end;

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
    super.initState();

    _begin = Timer(
        widget.event.begin.difference(DateTime.now()) +
            Duration(milliseconds: 10),
        _changeOnGoingState);

    _end = Timer(
        widget.event.end.difference(DateTime.now()) +
            Duration(milliseconds: 10),
        _changeOnGoingState);

    _changeOnGoingState();

    _reloadEvent = scheduleService.scheduledEventsLegacyList.listen((list) {
      // For some reason, if the function is called immediately, the changes doesn't take effect.
      Timer(Duration(milliseconds: 10), _changeOnGoingState);
    });
  }

  @override
  void dispose() {
    _reloadEvent.cancel();
    _begin.cancel();
    _end.cancel();

    super.dispose();
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
                          label: Text('On Going'),
                          backgroundColor: Colors.lightGreenAccent,
                        )
                      : Text('')),
                  Text(
                    widget.event.name,
                    style: Theme.of(context).textTheme.headline,
                    textScaleFactor: 1.2,
                  ),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.event.beginTimeString} - ${widget.event.endTimeString} at ${widget.event.location}',
                  style: Theme.of(context).textTheme.headline,
                  textScaleFactor: 0.8,
                ),
                Text(
                  widget.event.details,
                  style: Theme.of(context).textTheme.body1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
