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

void triggerBottomSheet(BuildContext context, Widget child) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return child;
    },
    elevation: 5.0,
  );
}

void triggerAlert(BuildContext context, Widget title, Widget child,
    List<Widget> actions) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: title,
        content: child,
        elevation: 10.0,
        actions: actions,
      );
    },
  );
}