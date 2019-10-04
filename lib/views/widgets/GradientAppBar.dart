import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget {
  final Widget title;
  final double barHeight;
  final Gradient gradient;

  GradientAppBar({this.title, this.barHeight: 60.0, this.gradient});

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusbarHeight),
      height: statusbarHeight + barHeight,
      child: Row(
        children: <Widget>[
          InkWell(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.arrow_back),
            ),
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0), child: title),
        ],
      ),
      decoration: BoxDecoration(
        gradient: this.gradient,
      ),
    );
  }
}
