import 'package:flutter/material.dart';
import 'package:kvis_sf/models/Authentication.dart';
import 'package:kvis_sf/views/widgets/LegalText.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile and Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              ProfileContent(),
              Divider(height: 25.0, thickness: 3.0),
              LegalText(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({
    Key key,
  }) : super(key: key);

  @override
  _ProfileContentState createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: authService.dataStream,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['isProperUser']) {
            return Column(
              children: <Widget>[
                ProfileTextContentDisplayWidget(data: snapshot.data),
                Divider(height: 25.0, thickness: 3.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/QRPage', arguments: {
                          'title': snapshot.data['name'],
                          'data': {
                            'uid': snapshot.data['firebaseUid'],
                            'name': snapshot.data['name'],
                            'school': snapshot.data['school'],
                            'country': snapshot.data['country'],
                            'role': snapshot.data['role'],
                            'time': DateTime.now().toIso8601String(),
                          }
                        });
                      },
                      child: Text('QR Code'),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                    RaisedButton(
                      onPressed: () async {
                        await authService.signOut();
                        Navigator.of(context)
                            .popUntil(ModalRoute.withName('/home'));
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text('Sign out'),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      color: Theme
                          .of(context)
                          .errorColor,
                    ),
                  ],
                ),
              ],
            );
          } else {
            // User is not signed in properly, either not signed in or signed in anonymously
            return Container(
              margin: EdgeInsets.symmetric(vertical: 50.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'Please sign in to view your profile.',
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .title,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.0),
                    child: RaisedButton(
                      onPressed: () async {
                        await authService.signOut();
                        Navigator.of(context)
                            .popUntil(ModalRoute.withName('/home'));
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                      child: Text(
                        'Sign in',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class ProfileTextContentDisplayWidget extends StatelessWidget {
  final Map<String, dynamic> data;

  ProfileTextContentDisplayWidget({@required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        data['name'] == null
            ? Container()
            : Text(
          data['name'].toString(),
          style: Theme
              .of(context)
              .textTheme
              .display1,
        ),
        ListTile(
          title: Text(
              '${data['school'] ?? 'Unaffiliated'} | ${data['country'] ??
                  'Unaffiliated'}'),
          subtitle: Text('School | Country'),
        ),
        data['sciact'] == null
            ? Container()
            : ListTile(
          title: Text(data['sciact']),
          subtitle: Text('Scientific Activities'),
        ),
        data['excursion'] == null
            ? Container()
            : ListTile(
          title: Text(data['excursion']),
          subtitle: Text('Excursion'),
        ),
        data['buddies'] == null
            ? Container()
            : ListTile(
          title: Text(data['buddies']),
          subtitle: Text('Buddies'),
        ),
        data['accomodation'] == null
            ? Container()
            : ListTile(
          title: Text(data['accomodation']),
          subtitle: Text('Accomodation'),
        ),
        data['proj_topic'] == null
            ? Container()
            : ListTile(
          title: Text(data['proj_topic']),
          subtitle: Text('Presentation Topic'),
        ),
        data['proj_location'] == null && data['proj_field'] == null
            ? Container()
            : ListTile(
          title: Text(
              '${data['proj_location'] ??
                  'To Be Announced'} | ${data['proj_field'] ?? '-'}'),
          subtitle: Text('Presentation Location | Categories'),
        ),
        data['information'] == null
            ? Container()
            : ListTile(
          title: Text(data['information']),
          subtitle: Text('Additional Information'),
        ),
      ],
    );
  }
}
