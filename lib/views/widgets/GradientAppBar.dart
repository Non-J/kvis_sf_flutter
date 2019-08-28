import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget {
  final Widget title;
  final double barHeight;
  final Gradient gradient;

  GradientAppBar({this.title, this.barHeight: 50.0, this.gradient});

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusbarHeight),
      height: statusbarHeight + barHeight,
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(15.0),
            child: InkWell(
              child: Icon(Icons.arrow_back),
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          title,
        ],
      ),
      decoration: BoxDecoration(
        gradient: this.gradient,
      ),
    );
  }
}
