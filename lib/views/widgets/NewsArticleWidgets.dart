import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kvis_sf/models/NewsList.dart';

class NewsArticleItemSmall extends StatelessWidget {
  final Widget child;
  final Widget picture;
  final Function onTap;
  final double height;
  final double pictureWidth;

  const NewsArticleItemSmall(
      {@required this.child,
      this.picture,
      this.onTap,
      this.height = 100.0,
      this.pictureWidth = 100.0});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: InkWell(
        onTap: this.onTap,
        child: Container(
          height: this.height,
          child: Row(
            children: <Widget>[
              Container(
                width: (this.picture != null ? this.pictureWidth : 0.0),
                child: this.picture,
              ),
              Expanded(
                child: this.child,
              ),
            ],
          ),
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
      {@required this.picture, @required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: InkWell(
        onTap: this.onTap,
        child: Container(
          child: Column(children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: this.picture,
            ),
            this.child,
          ]),
        ),
      ),
    );
  }
}

class NewsArticleList extends StatefulWidget {
  NewsArticleList({Key key}) : super(key: key);

  @override
  _NewsArticleListState createState() => _NewsArticleListState();
}

class _NewsArticleListState extends State<NewsArticleList> {
  // TODO:
  //  Implement offline check and cache;
  //  should be implemented in Model;
  //  Redo drawing implementation to reduce garbage;
  //  Maybe Add a header?
  Future<List<NewsArticle>> _futurePost =
      getNewsArticles('https://jsonplaceholder.typicode.com/posts?userId=2');

  Future _refreshArticles() {
    setState(() {
      _futurePost = getNewsArticles(
          'https://jsonplaceholder.typicode.com/posts?userId=2');
    });
    return _futurePost;
  }

  void _openArticlePlaintext(BuildContext context, String title, Widget body,
      {Widget hero}) {
    /*triggerFullPage(
      context,
      Text(title),
      Column(
        children: <Widget>[
          hero,
          body,
        ],
      ),
    );
    
     */
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NewsArticle>>(
      future: _futurePost,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
            break;

          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('An error occured: ${snapshot.error}');
            } else {
              return RefreshIndicator(
                onRefresh: _refreshArticles,
                child: ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    return NewsArticleItemSmall(
                      child: ListTile(
                        title: Text(
                          snapshot.data[index].title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.title,
                        ),
                        subtitle: Text(
                          snapshot.data[index].content,
                          maxLines: 3,
                          overflow: TextOverflow.fade,
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                      picture: Hero(
                          tag: snapshot.data[index].id, child: Placeholder()),
                      onTap: () {
                        if (snapshot.data[index].openMode ==
                            OpenMode.plaintext) {
                          _openArticlePlaintext(
                              context,
                              snapshot.data[index].title,
                              Container(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  snapshot.data[index].content,
                                  style: Theme.of(context).textTheme.body1,
                                ),
                              ),
                              hero: Placeholder());
                        }
                      },
                    );
                  },
                ),
              );
            }
            break;
        }

        return null;
      },
    );
  }
}
