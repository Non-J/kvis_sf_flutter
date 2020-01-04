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
              /*
              NOTE: PROFILE PICTURE

              FutureBuilder<File>(
                future: authService.getProfilePicture(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      break;
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.hasData) {
                        return CircleAvatar(
                          backgroundImage: FileImage(snapshot.data),
                          radius: 120.0,
                        );
                      } else {
                        return CircleAvatar(
                          child: Text(
                            'No Profile Picture',
                          ),
                          radius: 120.0,
                        );
                      }
                      break;
                  }

                  return CircleAvatar(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    radius: 120.0,
                  );
                },
              ),
              Divider(height: 25.0, thickness: 3.0),

               */
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
                    /*
                    RaisedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/profileEditor',
                            arguments: snapshot.data);
                      },
                      child: Text('Edit'),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                    ),
                    */
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
        ListTile(
          title: Text(data['name'] ?? 'No Name'),
          subtitle: Text('Name'),
        ),
        ListTile(
          title: Text(
              '${data['age'] ?? 'Unknown'} | ${data['gender'] ??
                  'Prefer not to say'} | ${data['role'] ?? 'Visitor'}'),
          subtitle: Text('Age | Gender | Status'),
        ),
        ListTile(
          title: Text(
              '${data['school'] ?? 'None'} | ${data['country'] ?? 'None'}'),
          subtitle: Text('School | Country'),
        ),
        ListTile(
          title: Text(data['information'] ?? 'None'),
          subtitle: Text('Additional Information'),
        ),
      ],
    );
  }
}
