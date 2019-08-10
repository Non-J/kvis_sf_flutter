import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:kvis_sf/views/widgets/TriggerableWidgets.dart';

class AccountWidget extends StatefulWidget {
  AccountWidget({Key key}) : super(key: key);

  @override
  _AccountWidgetState createState() => _AccountWidgetState();
}

class _AccountWidgetState extends State<AccountWidget> {
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
              FirebaseAuth.instance.signOut();
            },
            child: Text("Logout"),
            padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
            elevation: 5.0,
            color: Colors.blueAccent,
            textColor: Colors.white,
          )
        ],
      ),
    );
  }
}
