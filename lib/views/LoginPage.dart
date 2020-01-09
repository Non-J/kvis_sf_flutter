import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:kvis_sf/models/Authentication.dart';
import 'package:kvis_sf/views/widgets/LegalText.dart';
import 'package:kvis_sf/views/widgets/ScrollBehaviors.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ScrollConfiguration(
            behavior: NoGlowScrollBehavior(),
            child: SingleChildScrollView(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment(0.0, 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(20.0),
                        child: Text(
                          'Welcome',
                          style: Theme
                              .of(context)
                              .textTheme
                              .display2
                              .apply(color: Color.fromRGBO(127, 206, 172, 1.0)),
                        ),
                      ),
                      Container(
                        child: Image.asset('images/ISSF2020_LOGO_NoDate.png'),
                        height: 300.0,
                        padding: EdgeInsets.all(5.0),
                      ),
                      SigninForm(),
                      LegalText(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SigninForm extends StatefulWidget {
  @override
  _SigninFormState createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  final GlobalKey<FormBuilderState> _signinFormKey =
  GlobalKey<FormBuilderState>();
  StreamSubscription _redirectSubscription;

  @override
  void initState() {
    super.initState();

    _redirectSubscription =
        authService.rawUserStream.listen((FirebaseUser user) {
      if (user != null) {
        Future(() {
          Navigator.of(context).pushReplacementNamed('/home');
        });
      }
    });
  }

  @override
  void dispose() {
    _redirectSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 300.0,
          child: FormBuilder(
            key: _signinFormKey,
            child: Column(children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: FormBuilderTextField(
                  attribute: 'username',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    filled: true,
                  ),
                  validators: [
                    FormBuilderValidators.required(
                        errorText: 'Please enter your username.'),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
                child: FormBuilderTextField(
                  attribute: 'password',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    filled: true,
                  ),
                  obscureText: true,
                  maxLines: 1,
                  validators: [
                    FormBuilderValidators.required(
                        errorText: 'Please enter Password.'),
                  ],
                ),
              ),
            ]),
          ),
        ),
        StreamBuilder(
          stream: authService.signingInStatus,
          builder:
              (BuildContext context, AsyncSnapshot<SigningInStatus> snapshot) {
            String _displayMessage = '';
            bool _lockButton = false;

            if (snapshot.hasError) {
              _displayMessage =
              'An error occured while checking sign in status.\n${snapshot.error
                  .toString()}';
            } else if (snapshot.hasData) {
              _lockButton = snapshot.data.loading;
              _displayMessage = snapshot.data.message;
            }

            return Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(20.0),
                  width: 500.0,
                  child: Text(_displayMessage,
                      textAlign: TextAlign.center,
                      style: Theme
                          .of(context)
                          .textTheme
                          .body1),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      width: 120.0,
                      height: 45.0,
                      margin: EdgeInsets.all(10.0),
                      child: RaisedButton(
                        onPressed: _lockButton
                            ? null
                            : () {
                          authService.signInAnonymously();
                        },
                        child: Text('Skip'),
                      ),
                    ),
                    Container(
                      width: 120.0,
                      height: 45.0,
                      margin: EdgeInsets.all(10.0),
                      child: RaisedButton(
                        onPressed: (_lockButton
                            ? null
                            : () {
                          _signinFormKey.currentState.save();
                          if (_signinFormKey.currentState.validate()) {
                            authService.signInBackend(
                                _signinFormKey
                                    .currentState.value['username'],
                                _signinFormKey
                                    .currentState.value['password']);
                          }
                        }),
                        child: Center(
                          child: Text('Sign in'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
