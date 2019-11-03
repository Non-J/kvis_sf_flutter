import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/models/EventStreams.dart';
import 'package:kvis_sf/views/widgets/GradientAppBar.dart';
import 'package:kvis_sf/views/widgets/LegalText.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            GradientAppBar(
              title: Text(
                'Profile and Settings',
                style: Theme.of(context).textTheme.headline,
              ),
              rightAlignedButton: ProfileEditModeSwitch(),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 1.0],
                colors: [
                  Color.fromRGBO(212, 234, 209, 1.0),
                  Color.fromRGBO(184, 213, 233, 1.0),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(15.0),
                  child: ProfilePageContent(),
                ),
              ),
            ),
            LegalText(),
          ],
        ),
      ),
    );
  }
}

class ProfileEditModeSwitch extends StatefulWidget {
  @override
  _ProfileEditModeSwitchState createState() => _ProfileEditModeSwitchState();
}

class _ProfileEditModeSwitchState extends State<ProfileEditModeSwitch> {
  bool _editMode = false;

  StreamSubscription _profileSubscription;
  UserProfile _profile;

  @override
  initState() {
    super.initState();
    _profileSubscription = authService.profileStream
        .listen((state) => setState(() => _profile = state));
  }

  @override
  void dispose() {
    _profileSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null ||
        _profile.user == null ||
        _profile.user.isAnonymous) {
      return Container();
    }

    return OutlineButton(
      child: Text(
        _editMode ? 'Done' : 'Edit',
        textScaleFactor: 1.2,
      ),
      color: Colors.blueAccent,
      textColor: Colors.blueAccent,
      onPressed: () {
        setState(() {
          _editMode = !_editMode;
        });
        profileEditMode.add(_editMode);
      },
    );
  }
}

class ProfilePageContent extends StatefulWidget {
  const ProfilePageContent({
    Key key,
  }) : super(key: key);

  @override
  _ProfilePageContentState createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<ProfilePageContent> {
  StreamSubscription _profileSubscription;
  UserProfile _profile;

  @override
  initState() {
    super.initState();
    _profileSubscription = authService.profileStream
        .listen((state) => setState(() => _profile = state));
  }

  @override
  void dispose() {
    _profileSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) {
      // Data not ready
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_profile.user == null || _profile.user.isAnonymous) {
      // Not signed-in
      return Center(
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment(0.0, 0.0),
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(20.0),
                child: Text(
                  'Please sign in to view your profile.',
                  style: Theme
                      .of(context)
                      .textTheme
                      .display1,
                ),
              ),
              RaisedButton(
                onPressed: () async {
                  await authService.signOut();
                  Navigator.of(context).popUntil(ModalRoute.withName('/home'));
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text(
                  'Sign in',
                  textScaleFactor: 1.5,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 30.0,
                  vertical: 15.0,
                ),
                elevation: 5.0,
                color: Colors.blueAccent,
                textColor: Colors.white,
              ),
            ],
          ),
        ),
      );
    }

    // Signed-in and data ready
    return Column(
      children: <Widget>[
        _profile.profilePicture == null
            ? CircleAvatar(
          child: Text(
            'No Profile Picture',
            textScaleFactor: 1.5,
          ),
          radius: 120.0,
        )
            : CircleAvatar(
          backgroundImage: FileImage(_profile.profilePicture),
          radius: 120.0,
        ),
        Divider(
          height: 25.0,
          thickness: 3.0,
        ),
        ProfileEditForm(),
        Divider(
          height: 25.0,
          thickness: 3.0,
        ),
        RaisedButton(
          onPressed: () async {
            await authService.signOut();
            Navigator.of(context).popUntil(ModalRoute.withName('/home'));
            Navigator.of(context).pushReplacementNamed('/login');
          },
          child: Text('Sign out'),
          padding: EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 10.0,
          ),
          elevation: 5.0,
          color: Colors.redAccent,
          textColor: Colors.white,
        ),
      ],
    );
  }
}

class ProfileEditForm extends StatefulWidget {
  const ProfileEditForm({
    Key key,
  }) : super(key: key);

  @override
  _ProfileEditFormState createState() => _ProfileEditFormState();
}

class _ProfileEditFormState extends State<ProfileEditForm> {
  final GlobalKey<FormBuilderState> _profileFormKey =
  GlobalKey<FormBuilderState>();
  StreamSubscription _profileSubscription, _editModeSubscription;
  UserProfile _profile;
  bool _editMode = false;

  @override
  initState() {
    super.initState();

    _profileSubscription = authService.profileStream.listen((newProfile) {
      setState(() => _profile = newProfile);
    });

    _editModeSubscription = profileEditMode.listen((state) {
      setState(() => _editMode = state);
      if (!_editMode) {
        if (_profileFormKey.currentState.saveAndValidate()) {
          authService.updateProfile(_profileFormKey.currentState.value);
          return;
        }
      }
    });
  }

  @override
  void dispose() {
    _editModeSubscription.cancel();
    _profileSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null || _profile.data.isEmpty) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: FormBuilder(
        key: _profileFormKey,
        autovalidate: true,
        readOnly: !_editMode,
        initialValue: {
          ..._profile.data,
          'age': _profile.data['age'].round().toString(),
        },
        child: Column(
          children: <Widget>[
            AnimatedContainer(
                height: _editMode ? 50.0 : 0.0,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                child: Text(
                  'You are editing your profile.\nNote that some information cannot be edited.\nPlease contact your buddy if you wish to change them.',
                  style: Theme
                      .of(context)
                      .textTheme
                      .body2,
                  textAlign: TextAlign.center,
                )),
            FormBuilderTextField(
              attribute: 'name',
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Name',
              ),
              validators: [
                FormBuilderValidators.required(
                    errorText: 'Name cannot be empty.'),
              ],
            ),
            FormBuilderTextField(
              attribute: 'email',
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Email',
              ),
              validators: [
                FormBuilderValidators.email(
                    errorText: 'Email must be properly formatted'),
                FormBuilderValidators.required(
                    errorText: 'Email cannot be empty.'),
              ],
            ),
            FormBuilderDropdown(
              attribute: 'gender',
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Gender',
              ),
              items: ['Male', 'Female', 'Other', 'Prefer not to say']
                  .map((gender) =>
                  DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  ))
                  .toList(),
            ),
            FormBuilderTextField(
              attribute: 'age',
              valueTransformer: (value) => int.tryParse(value) ?? 16,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Age',
              ),
              validators: [
                FormBuilderValidators.required(
                    errorText: 'Age cannot be empty.'),
                    (val) {
                  try {
                    int parsedVal = int.parse(val);
                    if (parsedVal < 0 || parsedVal > 150) {
                      return 'Age must be in a reasonable range.';
                    }
                    return null;
                  } catch (e) {
                    return 'Age must be an integer value.';
                  }
                },
              ],
            ),
            FormBuilderTextField(
              attribute: 'status',
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Status',
              ),
              validators: [
                FormBuilderValidators.required(
                    errorText: 'Status cannot be empty.'),
              ],
              readOnly: true,
            ),
            FormBuilderTextField(
              attribute: 'school',
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'School',
              ),
            ),
            FormBuilderTextField(
              attribute: 'country',
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Country',
              ),
              validators: [
                FormBuilderValidators.required(
                    errorText: 'Country cannot be empty.'),
              ],
            ),
            FormBuilderTextField(
              attribute: 'informations',
              minLines: 3,
              maxLines: 10,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Additional Informations',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
