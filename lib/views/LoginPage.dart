import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/views/widgets/LegalText.dart';
import 'package:kvis_sf/views/widgets/ScrollBehaviors.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormBuilderState> _signinFormKey =
  GlobalKey<FormBuilderState>();

  StreamSubscription _authServiceRedirect,
      _loginLoadingListener,
      _loginMsgListener;

  bool _loggingIn = false;
  String _loginMsg = '';

  @override
  void initState() {
    super.initState();

    _loginLoadingListener = authService.loginLoading
        .listen((state) => setState(() => _loggingIn = state));

    _loginMsgListener = authService.loginMessage
        .listen((state) => setState(() => _loginMsg = state));

    _authServiceRedirect = authService.profileStream.listen((profile) {
      if (profile.user != null) {
        Future(() {
          Navigator.of(context).pushReplacementNamed('/home');
        });
      }
    });
  }

  @override
  void dispose() {
    _authServiceRedirect.cancel();
    _loginLoadingListener.cancel();
    _loginMsgListener.cancel();

    super.dispose();
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
            child: ScrollConfiguration(
              behavior: NoGrowScrollBehavior(),
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
                                .apply(
                                color: Color.fromRGBO(127, 206, 172, 1.0)),
                          ),
                        ),
                        Container(
                          child: Image.asset('images/ISSF2020_LOGO_NoDate.png'),
                          height: 300.0,
                          padding: EdgeInsets.all(5.0),
                        ),
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
                        SigninForm(
                            signinFormKey: _signinFormKey,
                            loggingInState: _loggingIn),
                        Container(
                          width: 120.0,
                          height: 45.0,
                          margin: EdgeInsets.all(10.0),
                          child: RaisedButton(
                              onPressed: _loggingIn
                                  ? null
                                  : () {
                                authService.signInAnonymously();
                              },
                              color: Colors.blueAccent,
                              textColor: Colors.white,
                              child: _loggingIn
                                  ? Container(
                                height: 25.0,
                                width: 25.0,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      Colors.white),
                                ),
                              )
                                  : Text(
                                'Skip sign-in',
                              )),
                        ),
                        GestureDetector(
                          onLongPress: () {
                            Navigator.pushNamed(context, '/debug');
                          },
                          child: LegalText(),
                        ),
                      ],
                    ),
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

class SigninForm extends StatelessWidget {
  const SigninForm({
    Key key,
    @required GlobalKey<FormBuilderState> signinFormKey,
    @required bool loggingInState,
  })
      : _signinFormKey = signinFormKey,
        _loggingInState = loggingInState,
        super(key: key);

  final GlobalKey<FormBuilderState> _signinFormKey;
  final bool _loggingInState;

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
            onPressed: (_loggingInState
                ? null
                : () {
              _signinFormKey.currentState.save();
              if (_signinFormKey.currentState.validate()) {
                authService.signInBackend(
                    _signinFormKey.currentState.value['username'],
                    _signinFormKey.currentState.value['password']);
                return;
              }
            }),
            color: Colors.blueAccent,
            textColor: Colors.white,
            child: Center(
              child: (_loggingInState
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
