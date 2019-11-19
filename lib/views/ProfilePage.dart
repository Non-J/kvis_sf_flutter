import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/views/widgets/GradientAppBar.dart';
import 'package:kvis_sf/views/widgets/LegalText.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GradientAppBar(
              title: Text(
                'Profile and Settings',
                style: Theme.of(context).textTheme.headline,
              ),
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
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    FutureBuilder<File>(
                      future: authService.getProfilePicture(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                          case ConnectionState.waiting:
                            break;
                          case ConnectionState.active:
                          case ConnectionState.done:
                            if (snapshot.hasData) {
                              return CircleAvatar(
                                backgroundImage: FileImage(snapshot.data),
                                radius: 120.0,
                              );
                            } else {
                              return CircleAvatar(
                                child: Text(
                                  'No Profile Picture',
                                ),
                                radius: 120.0,
                              );
                            }
                            break;
                        }

                        return CircleAvatar(
                          child: CircularProgressIndicator(
                            valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                          radius: 120.0,
                        );
                      },
                    ),
                    Divider(
                      height: 25.0,
                      thickness: 3.0,
                    ),
                    ProfileContent(),
                    Divider(
                      height: 25.0,
                      thickness: 3.0,
                    ),
                    LegalText(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({
    Key key,
  }) : super(key: key);

  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.dataStream,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['isProperUser']) {
            return Column(
              children: <Widget>[
                SelectableText(snapshot.data.toString()),
                Divider(
                  height: 25.0,
                  thickness: 3.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {},
                      child: Text('Edit'),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      elevation: 5.0,
                      color: Colors.blueAccent,
                      textColor: Colors.white,
                    ),
                    RaisedButton(
                      onPressed: () async {
                        await authService.signOut();
                        Navigator.of(context)
                            .popUntil(ModalRoute.withName('/home'));
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text('Sign out'),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      elevation: 5.0,
                      color: Colors.redAccent,
                      textColor: Colors.white,
                    ),
                  ],
                ),
              ],
            );
          } else {
            // User is not signed in properly, either not signed in or signed in anonymously
            return Container(
              margin: EdgeInsets.symmetric(vertical: 50.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Please sign in to view your profile.',
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .title,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: RaisedButton(
                      onPressed: () async {
                        await authService.signOut();
                        Navigator.of(context)
                            .popUntil(ModalRoute.withName('/home'));
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text(
                        'Sign in',
                      ),
                      elevation: 5.0,
                      color: Colors.blueAccent,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
