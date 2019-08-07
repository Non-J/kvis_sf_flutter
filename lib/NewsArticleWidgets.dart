import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'utils.dart';

class NewsArticleItemSmall extends StatelessWidget {
  final Widget child;
  final Widget picture;
  final Function onTap;

  const NewsArticleItemSmall({@required this.child, this.picture, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5.0,
      child: InkWell(
        onTap: this.onTap,
        child: Container(
          height: 100.0,
          child: Row(
            children: <Widget>[
              Container(
                width: (this.picture != null ? 100.0 : 0.0),
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
            this.picture,
            this.child,
          ]),
        ),
      ),
    );
  }
}

Future<List<dynamic>> getPosts() async {
  final response = await http.get("https://jsonplaceholder.typicode.com/posts");

  if (response.statusCode == 200) {
    // OK
    List<dynamic> res = [];
    res.addAll(json.decode(response.body));
    return res;
  } else {
    throw Exception('Failed to load post');
  }
}

class NewsArticleList extends StatefulWidget {
  NewsArticleList({Key key}) : super(key: key);

  @override
  _NewsArticleListState createState() => _NewsArticleListState();
}

class _NewsArticleListState extends State<NewsArticleList> {
  Future<List<dynamic>> _futurePost = getPosts();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
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
                onRefresh: () {
                  setState(() {
                    _futurePost = getPosts();
                  });
                  return _futurePost;
                },
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return NewsArticleItemSmall(
                      child: ListTile(
                        title: Text(
                          snapshot.data[index]["title"],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          snapshot.data[index]["body"],
                          maxLines: 3,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      picture: Hero(
                          tag: snapshot.data[index]["id"],
                          child: Placeholder()),
                      onTap: () {
                        triggerFullPage(
                          context,
                          Text(snapshot.data[index]["title"]),
                          Column(
                            children: <Widget>[
                              Hero(
                                  tag: snapshot.data[index]["id"],
                                  child: Placeholder()),
                              Text(snapshot.data[index]["body"]),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  itemCount: snapshot.data.length,
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
