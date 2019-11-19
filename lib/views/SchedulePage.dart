import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kvis_sf/models/Config.dart';
import 'package:kvis_sf/models/ScheduleModel.dart';
import 'package:kvis_sf/views/widgets/GradientAppBar.dart';

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
                      timeDisplayBegin: entry.begin.add(Duration(
                          hours: -configService
                              .getValue('scheduleUpcomingEventsDisplayHours'))),
                      timeDisplayEnd: entry.begin,
                    );
                  }).toList(growable: false),
                  Divider(
                    height: 25.0,
                    thickness: 3.0,
                  ),
                  Text(
                    'Time shown is in the timezone of your device.\nWe recommend that you change it to Thailand\'s local time.',
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
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(15.0),
                  child: Text('Retrieving current events.'),
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
              '${widget.event.beginTimeString} - ${widget.event
                  .endTimeString} at ${widget.event.location}'),
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
                  _color = Colors.yellow.shade400.withAlpha(128);
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

              final DateTime begin = DateTime.fromMillisecondsSinceEpoch(
                  configService.getValue('scheduleDayOffsetTime'));
              final DateTime firstDate = DateTime(begin
                  .toLocal()
                  .year,
                  begin
                      .toLocal()
                      .month, begin
                      .toLocal()
                      .day);
              final int dayOffset = date
                  .difference(firstDate)
                  .inDays;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 5.0),
                elevation: 0,
                color: _color,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CarlendarEventWidget(
                              dayOffset: dayOffset,
                              date: date,
                              events: snapshot.data[date]
                                ..sort((x, y) => x.begin.compareTo(y.begin)),
                            ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Day $dayOffset',
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1,
                        ),
                        Text(
                          DateFormat('E d MMMM y').format(date),
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

class CarlendarEventWidget extends StatelessWidget {
  const CarlendarEventWidget({Key key,
    @required this.dayOffset,
    @required this.date,
    @required this.events})
      : super(key: key);

  final int dayOffset;
  final DateTime date;
  final List<ScheduledEvent> events;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GradientAppBar(
              title: Text(
                'Day $dayOffset (${DateFormat('d MMM y').format(date)})',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 1.0],
                colors: [
                  Color.fromRGBO(212, 234, 209, 1.0),
                  Color.fromRGBO(184, 213, 233, 1.0),
                ],
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.all(10.0),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ...events.map((event) =>
                        Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 5.0),
                          child: Container(
                            child: ListTile(
                              isThreeLine: true,
                              title: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  event.name,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .headline,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${event.beginTimeString} - ${event
                                        .endTimeString} at ${event
                                        .location}\n${event.details}',
                                    style: Theme
                                        .of(context)
                                        .textTheme
                                        .body1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
