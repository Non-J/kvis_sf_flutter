import 'package:flutter/material.dart';

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

      // TODO: Waiting for design team
      child: Text(
        "Schedule",
        style: Theme
            .of(context)
            .textTheme
            .display1,
      ),
    );
  }
}
