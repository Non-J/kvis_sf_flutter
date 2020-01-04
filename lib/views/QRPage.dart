import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String title =
        Map.from(ModalRoute.of(context).settings.arguments)['title'];
    final dynamic data =
        Map.from(ModalRoute.of(context).settings.arguments)['data'].toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code${title != null ? ': $title' : ''}'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.symmetric(vertical: 20.0),
                child: (title != null
                    ? Text(
                        title,
                        style: Theme.of(context).textTheme.display1,
                      )
                    : null),
              ),
              Container(
                child: QrImage(
                  data: data,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.all(25.0),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
