import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget {
  final Widget title;
  final double barHeight;
  final Gradient gradient;
  final Widget rightAlignedButton;

  GradientAppBar(
      {this.title,
      this.barHeight: 60.0,
      this.gradient,
      this.rightAlignedButton});

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusbarHeight),
      height: statusbarHeight + barHeight,
      child: Row(
        children: <Widget>[
          BackButton(),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0), child: title),
          Spacer(),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              child: rightAlignedButton),
        ],
      ),
      decoration: BoxDecoration(
        gradient: this.gradient,
      ),
    );
  }
}
