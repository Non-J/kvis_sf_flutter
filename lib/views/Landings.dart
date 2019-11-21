import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kvis_sf/models/Authentication.dart';

class LandingWidget extends StatefulWidget {
  @override
  _LandingWidgetState createState() => _LandingWidgetState();
}

class _LandingWidgetState extends State<LandingWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: StreamBuilder(
            stream: authService.rawUserStream,
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
    );
  }
}
