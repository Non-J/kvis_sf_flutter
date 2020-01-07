import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class ContentDisplay extends StatelessWidget {
  final RegExp colorRegex = RegExp(
      r'^#([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})?$');

  final DocumentReference contentDocument;

  ContentDisplay({@required this.contentDocument});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: contentDocument.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          var onTapFunction;

          switch (snapshot.data.data['content_type']) {
            case 'url_webview':
              onTapFunction = () {
                url_launcher.launch(snapshot.data.data['content'],
                    forceWebView: true);
              };
              break;
            case 'url_external':
              onTapFunction = () {
                url_launcher.launch(snapshot.data.data['content']);
              };
              break;
            case 'list_content':
              onTapFunction = () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) => ListContentDisplayPage(
                      contentDocument: contentDocument,
                    ),
                  ),
                );
              };
              break;
            case 'markdown':
              break;
            case 'plain_text':
              onTapFunction = () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        PlaintextContentDisplayPage(
                      contentDocument: contentDocument,
                    ),
                  ),
                );
              };
              break;
            default:
              onTapFunction = null;
              break;
          }

          BoxDecoration background = BoxDecoration();

          if (snapshot.data.data['background'] != null) {
            if (colorRegex.hasMatch(snapshot.data.data['background'])) {
              background = BoxDecoration(
                color: HexColor.fromHex(snapshot.data.data['background']),
              );
            } else {
              background = BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  image: Image.network(snapshot.data.data['background']).image,
                ),
              );
            }
          }

          TextStyle titleTextStyle = Theme
              .of(context)
              .textTheme
              .title;
          TextStyle detailsTextStyle = Theme
              .of(context)
              .textTheme
              .subtitle;

          if (snapshot.data.data['text_color'] != null) {
            titleTextStyle = titleTextStyle.apply(
                color: HexColor.fromHex(snapshot.data.data['text_color']));
            detailsTextStyle = detailsTextStyle.apply(
                color: HexColor.fromHex(snapshot.data.data['text_color']));
          }
          if (snapshot.data.data['title_fontweight'] != null) {
            titleTextStyle = titleTextStyle.apply(
                fontWeightDelta:
                snapshot.data.data['title_fontweight'].toInt());
          }
          if (snapshot.data.data['detail_fontweight'] != null) {
            detailsTextStyle = detailsTextStyle.apply(
                fontWeightDelta:
                snapshot.data.data['detail_fontweight'].toInt());
          }

          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTapFunction,
              child: Container(
                decoration: background,
                height: snapshot.data.data['height'] == null
                    ? null
                    : snapshot.data.data['height'].toDouble(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ListTile(
                    title: Text(
                      snapshot.data.data['title'] ?? '',
                      style: titleTextStyle,
                      textScaleFactor: snapshot.data.data['title_scale'] == null
                          ? 1.0
                          : snapshot.data.data['title_scale'].toDouble(),
                    ),
                    subtitle: Text(
                      snapshot.data.data['details'] ?? '',
                      style: detailsTextStyle,
                      textScaleFactor:
                      snapshot.data.data['detail_scale'] == null
                          ? 1.0
                          : snapshot.data.data['detail_scale'].toDouble(),
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
            ),
          );
        }

        return Card(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class ListContentDisplayPage extends StatelessWidget {
  final DocumentReference contentDocument;

  ListContentDisplayPage({@required this.contentDocument});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: contentDocument.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        Widget childContent = Center(child: CircularProgressIndicator());

        if (snapshot.hasData) {
          final List<Widget> contentList = snapshot.data.data['content']
              .map<Widget>((document) => ContentDisplay(
                    contentDocument: document,
                  ))
              .toList();
          childContent = ListView(
            padding: EdgeInsets.all(10),
            children: contentList,
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
                snapshot.hasData ? (snapshot.data.data['title'] ?? "") : ""),
          ),
          body: SafeArea(
            child: childContent,
          ),
        );
      },
    );
  }
}

class PlaintextContentDisplayPage extends StatelessWidget {
  final DocumentReference contentDocument;

  PlaintextContentDisplayPage({@required this.contentDocument});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: contentDocument.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        Widget childContent = Center(child: CircularProgressIndicator());

        if (snapshot.hasData) {
          childContent = SingleChildScrollView(
            padding: EdgeInsets.all(15),
            child: SelectableText(
              snapshot.data.data['content'].toString(),
              style:
                  Theme.of(context).textTheme.body1.apply(fontSizeFactor: 1.2),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
                snapshot.hasData ? (snapshot.data.data['title'] ?? "") : ""),
          ),
          body: SafeArea(
            child: childContent,
          ),
        );
      },
    );
  }
}
