import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

String formatDateTimeRange(DateTime begin, DateTime end) {
  DateTime beginDate = DateTime(
      begin
          .toLocal()
          .year, begin
      .toLocal()
      .month, begin
      .toLocal()
      .day);
  DateTime endDate =
  DateTime(end
      .toLocal()
      .year, end
      .toLocal()
      .month, end
      .toLocal()
      .day);
  String beginText = (beginDate == endDate
      ? DateFormat('Hm').format(begin.toLocal())
      : '${DateFormat('d/MMM').format(begin.toLocal())} ${DateFormat('Hm')
      .format(begin.toLocal())}');
  String endText = (beginDate == endDate
      ? DateFormat('Hm').format(end.toLocal())
      : '${DateFormat('d/MMM').format(end.toLocal())} ${DateFormat('Hm').format(
      end.toLocal())}');
  return '$beginText - $endText';
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
    } else {
      buffer.write(hexString.substring(7));
      buffer.write(hexString.substring(1, 7));
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}'
      '${alpha.toRadixString(16).padLeft(2, '0')}';
}

class ContentDisplayFromDocumentReference extends StatelessWidget {
  final DocumentReference contentDocument;

  ContentDisplayFromDocumentReference({@required this.contentDocument});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: contentDocument.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.data != null) {
            return ContentDisplay(
              content: snapshot.data.data,
              contentDocument: contentDocument,
            );
          } else {
            return Container();
          }
        }

        return Card(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class ContentDisplay extends StatelessWidget {
  static RegExp colorRegex = RegExp(
      r'^#([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})?$');

  const ContentDisplay({
    Key key,
    @required this.content,
    this.contentDocument,
  }) : super(key: key);

  final DocumentReference contentDocument;
  final Map content;

  @override
  Widget build(BuildContext context) {
    var onTapFunction;

    switch (content['content_type']) {
      case 'url_webview':
        onTapFunction = () {
          url_launcher.launch(content['content'], forceWebView: true);
        };
        break;
      case 'url_external':
        onTapFunction = () {
          url_launcher.launch(content['content']);
        };
        break;
      case 'ref_content':
        onTapFunction = () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  RefContentDisplayPage(
                    contentDocument: contentDocument,
                  ),
            ),
          );
        };
        break;
      case 'list_content':
        onTapFunction = () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  ListContentDisplayPage(
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
                    content: content['content'] == null
                        ? 'None'
                        : content['content'].toString(),
                    title:
                    content['title'] == null ? '' : content['title'].toString(),
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

    if (content['background'] != null) {
      if (colorRegex.hasMatch(content['background'])) {
        background = BoxDecoration(
          color: HexColor.fromHex(content['background']),
        );
      } else {
        background = BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            alignment: Alignment.center,
            image: Image
                .network(content['background'])
                .image,
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

    if (content['text_color'] != null) {
      titleTextStyle =
          titleTextStyle.apply(color: HexColor.fromHex(content['text_color']));
      detailsTextStyle = detailsTextStyle.apply(
          color: HexColor.fromHex(content['text_color']));
    }
    if (content['title_fontweight'] != null) {
      titleTextStyle = titleTextStyle.apply(
          fontWeightDelta: content['title_fontweight'].toInt());
    }
    if (content['detail_fontweight'] != null) {
      detailsTextStyle = detailsTextStyle.apply(
          fontWeightDelta: content['detail_fontweight'].toInt());
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTapFunction,
        child: Container(
          decoration: background,
          height:
          content['height'] == null ? null : content['height'].toDouble(),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: ListTile(
              title: Text(
                content['title'] ?? '',
                style: titleTextStyle,
                textScaleFactor: content['title_scale'] == null
                    ? 1.0
                    : content['title_scale'].toDouble(),
              ),
              subtitle: Text(
                '${content['content_type'] == 'schedule' ? formatDateTimeRange(
                    (content['begin'] is Timestamp
                        ? content['begin'].toDate()
                        : DateTime.now()), (content['end'] is Timestamp
                    ? content['end'].toDate()
                    : DateTime.now())) + '\n' : ''}${content['details'] ?? ''}',
                style: detailsTextStyle,
                textScaleFactor: content['detail_scale'] == null
                    ? 1.0
                    : content['detail_scale'].toDouble(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RefContentDisplayPage extends StatelessWidget {
  final DocumentReference contentDocument;

  RefContentDisplayPage({@required this.contentDocument});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: contentDocument.snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        Widget childContent = Center(child: CircularProgressIndicator());

        if (snapshot.hasData) {
          final List<Widget> contentList = snapshot.data.data['content']
              .map<Widget>((document) =>
              ContentDisplayFromDocumentReference(
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
          final List<Widget> contentList =
          snapshot.data.data['content'].map<Widget>((document) {
            if (document is DocumentReference) {
              return ContentDisplayFromDocumentReference(
                  contentDocument: document);
            } else {
              return ContentDisplay(content: document);
            }
          }).toList();
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
  final String content, title;

  PlaintextContentDisplayPage({@required this.content, @required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: SelectableText(
            content,
            style: Theme
                .of(context)
                .textTheme
                .body1
                .apply(fontSizeFactor: 1.2),
          ),
        ),
      ),
    );
  }
}
