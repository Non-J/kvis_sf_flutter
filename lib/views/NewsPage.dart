import 'package:flutter/material.dart';

import 'package:kvis_sf/views/widgets/NewsArticleWidgets.dart';

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
      child: NewsArticleList(),
    );
  }
}
