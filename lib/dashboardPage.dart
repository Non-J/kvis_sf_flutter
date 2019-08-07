import 'package:flutter/material.dart';

import 'NewsArticleWidgets.dart';

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
      child: ListView(
        children: <Widget>[
          Card(
            elevation: 5.0,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text(
                    "Welcome to ISSF!",
                    textScaleFactor: 1.5,
                  ),
                )
              ],
            ),
          ),
          RaisedButton(
            onPressed: getPosts,
            child: Text("Test Network"),
          ),
        ],
      ),
    );
  }
}
