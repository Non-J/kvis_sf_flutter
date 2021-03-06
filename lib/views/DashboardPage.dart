import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kvis_sf/models/Content.dart';
import 'package:kvis_sf/views/widgets/ContentDisplay.dart';

class DashboardWidget extends StatefulWidget {
  DashboardWidget({Key key}) : super(key: key);

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: contentService.featuredContentStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          final List<Widget> contentList = snapshot.data.documents
              .map((document) => ContentDisplayFromDocumentReference(
                    contentDocument: document.reference,
                  ))
              .toList();
          return ListView(
            padding: EdgeInsets.all(10),
            children: contentList,
          );
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
