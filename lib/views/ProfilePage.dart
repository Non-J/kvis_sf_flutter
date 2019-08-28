import 'package:flutter/material.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/models/GlobalState.dart';
import 'package:kvis_sf/views/widgets/GradientAppBar.dart';

void triggerProfilePage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileWidget(),
    ),
  );
}

class ProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            GradientAppBar(
              title: Text(
                "Profile and Settings",
                style: Theme.of(context).textTheme.headline,
              ),
              barHeight: 60.0,
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
            Text(
              "Profile and Settings",
              style: Theme.of(context).textTheme.display1,
            ),
            RaisedButton(
              onPressed: () {
                analytics.logEvent(name: "logout");
                AuthSystem.signOut();
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: Text("Logout"),
              padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              elevation: 5.0,
              color: Colors.blueAccent,
              textColor: Colors.white,
            ),
            Text("Logged in as ${AuthSystem.username}"),
          ],
        ),
      ),
    );
  }
}
