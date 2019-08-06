import 'package:flutter/material.dart';

import 'aboutPage.dart';

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
        child: Column(
          children: <Widget>[
            Card(
              elevation: 5.0,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text(
                      "Username Here",
                      style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("Students"),
                        Text("School Name"),
                        Text("Teacher's Name")
                      ],
                    ),
                  )
                ],
              ),
            ),
            Card(
              child: ListView(
                physics: ClampingScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text("Profile"),
                  ),
                  ListTile(
                      leading: Icon(Icons.settings), title: Text("Settings")),
                  ListTile(
                      leading: Icon(Icons.report),
                      title: Text("Report Problems")),
                  ListTile(
                      leading: Icon(Icons.monetization_on),
                      title: Text("Sponsors")),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text("About"),
                    onTap: () {
                      openAboutPage(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
