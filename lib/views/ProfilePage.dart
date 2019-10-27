import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/views/widgets/GradientAppBar.dart';

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
            ProfilePageContent(),
          ],
        ),
      ),
    );
  }
}

class ProfilePageContent extends StatelessWidget {
  const ProfilePageContent({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Profile and Settings',
          style: Theme
              .of(context)
              .textTheme
              .display1,
        ),
        RaisedButton(
          onPressed: () {
            authService.signOut();
            SchedulerBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(
                  context, Navigator.defaultRouteName);
            });
          },
          child: Text('Logout'),
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          elevation: 5.0,
          color: Colors.blueAccent,
          textColor: Colors.white,
        ),
        ProfileDisplay(),
      ],
    );
  }
}

class ProfileDisplay extends StatefulWidget {
  const ProfileDisplay({
    Key key,
  }) : super(key: key);

  @override
  _ProfileDisplayState createState() => _ProfileDisplayState();
}

class _ProfileDisplayState extends State<ProfileDisplay> {
  Map<String, dynamic> _profile;

  @override
  initState() {
    super.initState();

    authService.profile.listen((state) => setState(() => _profile = state));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Logged in as ${_profile.toString()}'),
        RaisedButton(
          child: Text('Debug Page'),
          onPressed: () {
            Navigator.pushNamed(context, '/debug');
          },
          color: Colors.redAccent,
        ),
      ],
    );
  }
}