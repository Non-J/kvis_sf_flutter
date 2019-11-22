import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kvis_sf/models/Config.dart';
import 'package:kvis_sf/models/Schedule.dart';
import 'package:kvis_sf/views/ScheduleDayPage.dart';

class ScheduleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10.0),
      children: <Widget>[
        CurrentEventDisplayWidget(),
        CalendarDateList(),
      ],
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
          final Duration upcomingEventsDisplayBefore = Duration(
              hours: -(configService
                  .getValue('scheduleUpcomingEventsDisplayHours') ??
                  2));

          return Card(
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
                    return CurrentEventEntryWidget(
                      key: _key,
                      event: entry,
                      timeDisplayBegin: entry.begin,
                      timeDisplayEnd: entry.end,
                    );
                  }).toList(),
                  Divider(height: 25.0, thickness: 3.0),
                  Text(
                    'Upcoming Events',
                    style: Theme
                        .of(context)
                        .textTheme
                        .display1,
                  ),
                  ...snapshot.data.map((entry) {
                    UniqueKey _key = UniqueKey();
                    return CurrentEventEntryWidget(
                      key: _key,
                      event: entry,
                      timeDisplayBegin:
                      entry.begin.add(upcomingEventsDisplayBefore),
                      timeDisplayEnd: entry.begin,
                    );
                  }).toList(),
                  Divider(height: 25.0, thickness: 3.0),
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
          margin: EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: Center(child: CircularProgressIndicator()),
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

class CurrentEventEntryWidget extends StatefulWidget {
  @override
  _CurrentEventEntryWidgetState createState() =>
      _CurrentEventEntryWidgetState();

  final ScheduledEvent event;
  final DateTime timeDisplayBegin, timeDisplayEnd;

  CurrentEventEntryWidget({@required this.event,
    @required this.timeDisplayBegin,
    @required this.timeDisplayEnd,
    Key key})
      : super(key: key);
}

class _CurrentEventEntryWidgetState extends State<CurrentEventEntryWidget> {
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
      stream: scheduleService.eventsStream,
      builder: (context, AsyncSnapshot<List<ScheduledEvent>> snapshot) {
        if (snapshot.hasData) {
          Set<DateTime> dateSet = Set();

          snapshot.data.forEach((event) {
            for (DateTime date = event.beginDate;
            date.isBefore(event.endDate.add(Duration(days: 1)));
            date = date.add(Duration(days: 1))) {
              dateSet.add(date);
            }
          });

          final List<DateTime> dateList = dateSet.toList()
            ..sort((x, y) => x.compareTo(y));

          final DateTime firstDateTime = DateTime.fromMillisecondsSinceEpoch(
              configService.getValue('scheduleDayOffsetTime') ?? 0);
          final DateTime firstDate = DateTime(firstDateTime
              .toLocal()
              .year,
              firstDateTime
                  .toLocal()
                  .month, firstDateTime
                  .toLocal()
                  .day);

          final Map<int, Color> weekdayColor = {
            DateTime.monday: Colors.yellow.shade300.withAlpha(128),
            DateTime.tuesday: Colors.pink.shade300.withAlpha(128),
            DateTime.wednesday: Colors.green.shade300.withAlpha(128),
            DateTime.thursday: Colors.orange.shade300.withAlpha(128),
            DateTime.friday: Colors.blue.shade300.withAlpha(128),
            DateTime.saturday: Colors.purple.shade300.withAlpha(128),
            DateTime.sunday: Colors.red.shade300.withAlpha(128),
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: dateList
                .map((date) =>
                Card(
                  color: weekdayColor[date.weekday],
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ScheduleDayPage(
                                title:
                                'Day ${date
                                    .difference(firstDate)
                                    .inDays}: ${DateFormat('EEEE d MMMM y')
                                    .format(date)}',
                                displayBegin: date,
                                displayEnd: date.add(Duration(days: 1)),
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
                            'Day ${date
                                .difference(firstDate)
                                .inDays}',
                            style: Theme
                                .of(context)
                                .textTheme
                                .display1,
                          ),
                          Text(
                            DateFormat('EEEE d MMMM y').format(date),
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
                ))
                .toList(),
          );
        }

        return Container();
      },
    );
  }
}
