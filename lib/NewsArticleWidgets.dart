import 'package:flutter/material.dart';

class NewsArticleItemSmall extends StatelessWidget {
  final Widget title;
  final Widget content;
  final Widget picture;
  final Function onTap;

  const NewsArticleItemSmall(
      {@required this.title, this.content, this.picture, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: InkWell(
        onTap: this.onTap,
        child: Container(
          height: 100.0,
          child: Row(children: [
            Container(
              width: (this.picture != null ? 100.0 : 0.0),
              child: this.picture,
            ),
            Expanded(
              child: ListTile(
                title: this.title,
                subtitle: this.content,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class NewsArticleItemLarge extends StatelessWidget {
  final Widget picture;
  final Widget child;
  final Function onTap;

  const NewsArticleItemLarge(
      {@required this.picture,
      @required this.child,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: InkWell(
        onTap: this.onTap,
        child: Container(
          child: Column(children: [
            this.picture,
            this.child,
          ]),
        ),
      ),
    );
  }
}

class NewsArticlePage extends StatelessWidget {
  final Widget title;
  final Widget content;

  const NewsArticlePage({@required this.title, this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: this.title,
      ),
      body: this.content,
    );
  }
}
