import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

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
              final colorMatch =
                  colorRegex.firstMatch(snapshot.data.data['background']);
              background = BoxDecoration(
                color: Color.fromRGBO(
                  int.tryParse(colorMatch.group(1) ?? "", radix: 16) ?? 255,
                  int.tryParse(colorMatch.group(2) ?? "", radix: 16) ?? 255,
                  int.tryParse(colorMatch.group(3) ?? "", radix: 16) ?? 255,
                  (int.tryParse(colorMatch.group(4) ?? "", radix: 16) ?? 0) /
                      255,
                ),
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

          switch (snapshot.data.data['display_size']) {
            case 'large':
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTapFunction,
                  child: Container(
                    decoration: background,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            snapshot.data.data['title'] ?? "",
                            style: Theme.of(context)
                                .textTheme
                                .display2
                                .apply(fontWeightDelta: 3),
                          ),
                          subtitle: Text(snapshot.data.data['details'] ?? ""),
                          isThreeLine: true,
                        ),
                        Container(
                          height: 300,
                        ),
                      ],
                    ),
                  ),
                ),
              );
              break;

            case 'small':
            default:
              return Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTapFunction,
                  child: Container(
                    decoration: background,
                    child: ListTile(
                      title: Text(
                        snapshot.data.data['title'] ?? "",
                        style: Theme.of(context).textTheme.title,
                      ),
                      subtitle: Text(snapshot.data.data['details'] ?? ""),
                      isThreeLine: true,
                    ),
                  ),
                ),
              );
              break;
          }
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
