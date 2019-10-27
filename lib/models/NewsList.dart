import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

enum OpenMode { plaintext, markdown, webView, openBrowser }

class NewsArticle {
  final String id;
  final String title;
  final String content;
  final String thumbnailUrl;
  final String webUrl;
  final OpenMode openMode;

  NewsArticle(this.id, this.title, this.content, this.thumbnailUrl, this.webUrl,
      this.openMode);
}

Future<List<NewsArticle>> getNewsArticles(String targetUrl) async {
  final response = await http.get(targetUrl);

  if (response.statusCode == 200) {
    // OK
    List<NewsArticle> res = [];

    for (final article in json.decode(response.body)) {
      res.add(NewsArticle(article['id'].toString(), article['title'],
          article['body'], null, null, OpenMode.plaintext));
    }

    return res;
  } else {
    throw Exception('Failed to load news articles.');
  }
}
