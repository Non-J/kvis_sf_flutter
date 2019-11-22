import 'package:flutter/material.dart';
import 'package:kvis_sf/models/Schedule.dart';

class ScheduleDayPage extends StatelessWidget {
  const ScheduleDayPage(
      {Key key,
      @required this.title,
      @required this.displayBegin,
      @required this.displayEnd})
      : super(key: key);

  final String title;
  final DateTime displayBegin, displayEnd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: scheduleService.eventsStream,
          builder: (context, AsyncSnapshot<List<ScheduledEvent>> snapshot) {
            if (snapshot.hasData) {
              return ListView(
                padding: EdgeInsets.all(10.0),
                children: snapshot.data
                    .where((event) => !(event.begin.isAfter(displayEnd) ||
                        event.end.isBefore(displayBegin)))
                    .map(
                      (event) => Card(
                        child: ListTile(
                          title: Text(
                            event.name,
                            textScaleFactor: 1.2,
                          ),
                          subtitle: Text(
                            '${event.beginTimeString} - ${event.endTimeString} at ${event.location}\n${event.details}',
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            }

            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
