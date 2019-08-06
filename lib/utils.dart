import 'package:flutter/material.dart';

class FullPage extends StatelessWidget {
  final Widget title;
  final Widget child;

  const FullPage({this.title, @required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: this.title,
      ),
      body: this.child,
    );
  }
}

void triggerFullPage(BuildContext context, Widget title, Widget child) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FullPage(
                title: title,
                child: child,
              )));
}


    /*
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[Text("Test")],
        );
      },
    );
    */