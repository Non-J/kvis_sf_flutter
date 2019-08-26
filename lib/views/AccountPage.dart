import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kvis_sf/models/GlobalState.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';

class AccountWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),

      // TODO: Waiting for design team
      child: Column(
        children: <Widget>[
          Text(
            "Account and Settings",
            style: Theme
                .of(context)
                .textTheme
                .display1,
          ),
          RaisedButton(
            onPressed: () {
              analytics.logEvent(name: "logout");
              AuthSystem.instance.signOut();
            },
            child: Text("Logout"),
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            elevation: 5.0,
            color: Colors.blueAccent,
            textColor: Colors.white,
          ),
          Text("Logged in as ${AuthSystem.instance.username}"),
        ],
      ),
    );
  }
}
