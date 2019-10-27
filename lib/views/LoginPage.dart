import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/views/widgets/TriggerableWidgets.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseMessaging _firebaseCloudMessaging = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    _firebaseCloudMessaging.requestNotificationPermissions();

    _firebaseCloudMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        FlashNotification.TopNotification(
          context,
          title: Text(message['notification']['title'] ?? 'New Notification'),
          message: Text(message['notification']['body'] ?? ''),
        );
      },
      onResume: (Map<String, dynamic> message) async {},
      onLaunch: (Map<String, dynamic> message) async {},
    );

    authService.profile.listen((data) {
      if (data.isNotEmpty) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
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
        child: SafeArea(
          child: Center(
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
                      _LoginForm(),
                      _LegalText(),
                      RaisedButton(
                        child: Text('Debug Page'),
                        onPressed: () {
                          Navigator.pushNamed(context, '/debug');
                        },
                        color: Colors.redAccent,
                      ),
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

class _LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  StreamSubscription _loginLoadingListener, _loginMsgListener;

  bool _loggingIn = false;
  String _loginMsg = '';

  @override
  void initState() {
    super.initState();

    _loginLoadingListener = authService.loginLoading
        .listen((state) => setState(() => _loggingIn = state));

    _loginMsgListener = authService.loginMessage
        .listen((state) => setState(() => _loginMsg = state));
  }

  @override
  void dispose() {
    _loginLoadingListener.cancel();
    _loginMsgListener.cancel();

    super.dispose();
  }

  void _signIn() {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      authService.signInBackend(_formKey.currentState.value['username'],
          _formKey.currentState.value['password']);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(20.0),
          width: 500.0,
          child: Text(_loginMsg,
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .body1),
        ),
        Container(
          width: 300.0,
          child: FormBuilder(
            key: _formKey,
            child: Column(children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.0),
                child: FormBuilderTextField(
                  attribute: 'username',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    filled: true,
                    fillColor: Color.fromRGBO(255, 255, 255, 0.3),
                  ),
                  validators: [
                    FormBuilderValidators.required(
                        errorText: 'Please enter your email.'),
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
                    fillColor: Color.fromRGBO(255, 255, 255, 0.3),
                  ),
                  obscureText: true,
                  validators: [
                    FormBuilderValidators.required(
                        errorText: 'Please enter Password.'),
                  ],
                ),
              ),
            ]),
          ),
        ),
        Container(
          width: 120.0,
          height: 45.0,
          margin: EdgeInsets.all(10.0),
          child: RaisedButton(
            onPressed: (_loggingIn ? null : _signIn),
            color: Colors.blueAccent,
            textColor: Colors.white,
            child: Center(
              child: (_loggingIn
                  ? Container(
                height: 25.0,
                width: 25.0,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
                  : Text(
                'Login',
                textScaleFactor: 1.5,
              )),
            ),
          ),
        ),
      ],
    );
  }
}

class _LegalText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(20.0),
          child: RichText(
            text: TextSpan(
              style: Theme
                  .of(context)
                  .textTheme
                  .body1,
              children: [
                TextSpan(
                  text: 'By using this app, you\'ve agreed to our ',
                ),
                TextSpan(
                  text: 'Terms of Use and Privacy Policy.',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      url_launcher
                          .launch('http://110.164.80.12/ISSF16/index.php');
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
