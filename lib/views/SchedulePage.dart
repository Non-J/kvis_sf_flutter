import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kvis_sf/models/Content.dart';
import 'package:kvis_sf/views/widgets/ContentDisplay.dart';

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
      stream: contentService.fullScheduleStream,
      builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          // CONFIG: scheduleUpcomingEventsDisplayHours
          final Duration upcomingEventsDisplayBefore = Duration(hours: -2);

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
                      timeDisplayBegin: entry['begin'],
                      timeDisplayEnd: entry['end'],
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
                      entry['begin'].add(upcomingEventsDisplayBefore),
                      timeDisplayEnd: entry['begin'],
                    );
                  }).toList(),
                  Divider(height: 25.0, thickness: 3.0),
                  Text(
                    'Time shown is in the timezone of your device.\n',
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

  final Map<String, dynamic> event;
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
          title: Text(widget.event['title']),
          subtitle: Text(
              '${formatDateTimeRange(
                  widget.event['begin'], widget.event['end'])}\n${widget
                  .event['details']}'),
        ),
      ),
    );
  }
}

class CalendarDateList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: contentService.scheduleStream,
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.hasData) {
          final List<Widget> contentList = snapshot.data
              .map((document) =>
              ContentDisplayFromDocumentReference(
                contentDocument: document.reference,
              ))
              .toList();
          return Column(
            children: contentList,
          );
        }

        return Container();
      },
    );
  }
}
