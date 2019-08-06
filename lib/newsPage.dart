import 'package:flutter/material.dart';

import 'NewsArticleWidgets.dart';
import 'utils.dart';

class NewsWidget extends StatefulWidget {
  NewsWidget({Key key}) : super(key: key);

  @override
  _NewsWidgetState createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.0),
      child: ListView(
        children: <Widget>[
          NewsArticleItemSmall(
            title: Text("Small News Article Item Test"),
            content: Text("Click to open content. This is subtitle."),
            picture: Hero(tag: "abc", child: Placeholder()),
            onTap: () {
              triggerFullPage(
                  context, Text("News Article Header"), Hero(tag: "abc", child: Placeholder()));
            },
          ),
        ],
      ),
    );
  }
}
