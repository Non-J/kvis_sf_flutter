import 'package:flutter/material.dart';

class DashboardWidget extends StatefulWidget {
  DashboardWidget({Key key}) : super(key: key);

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),

      // TODO: Waiting for design team
      child: Text(
        "Dashboard",
        style: Theme.of(context).textTheme.display1,
      ),
    );
  }
}
