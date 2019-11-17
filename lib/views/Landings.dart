import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/models/Notification.dart';

class LandingWidget extends StatefulWidget {
  @override
  _LandingWidgetState createState() => _LandingWidgetState();
}

class _LandingWidgetState extends State<LandingWidget> {
  @override
  void initState() {
    super.initState();
    notificationService.requestPermission();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
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
        child: SafeArea(
          child: Center(
            child: StreamBuilder(
              stream: authService.userStream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    break;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return SelectableText(
                          'An error occured in the authenticaiton system.\n${snapshot
                              .error.toString()}');
                    } else if (snapshot.hasData) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      });
                    } else {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      });
                    }
                    break;
                }

                return CircularProgressIndicator();
              },
            ),
          ),
        ),
      ),
    );
  }
}
