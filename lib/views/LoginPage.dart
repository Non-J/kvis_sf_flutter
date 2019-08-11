import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'package:kvis_sf/models/GlobalState.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';

class LoginPage extends StatefulWidget {
  @override
  createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  bool _loggingIn = false;
  String _loginMsg = "";

  void _signIn() async {
    try {
      setState(() {
        _loggingIn = true;
        _loginMsg = "Logging in...";
      });

      _formKey.currentState.save();
      if (_formKey.currentState.validate()) {
        analytics.logLogin(loginMethod: "Username and Password");
        await AuthSystem.instance.signInAnonymously(
            _formKey.currentState.value["username"],
            _formKey.currentState.value["password"]);
        return;
      }

      setState(() {
        _loggingIn = false;
        _loginMsg = "Please make sure you have filled in your credentials.";
      });
    } catch (error) {
      setState(() {
        _loggingIn = false;
        _loginMsg =
            "Unable to login.\n Please make sure your credentials are correct.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: FittedBox(
            alignment: Alignment(0.0, 0.0),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(20.0),
                  child: Text(
                    "Please Login",
                    style: Theme.of(context).textTheme.display1,
                  ),
                ),
                Container(
                  width: 300.0,
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(10.0),
                        child: FormBuilderTextField(
                          attribute: "username",
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Username"),
                          validators: [
                            FormBuilderValidators.required(
                                errorText: "Please enter Username."),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(10.0),
                        child: FormBuilderTextField(
                          attribute: "password",
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Password"),
                          obscureText: true,
                          validators: [
                            FormBuilderValidators.required(
                                errorText: "Please enter Password."),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
                Container(
                  width: 120.0,
                  height: 40.0,
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
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              "Login",
                              textScaleFactor: 1.5,
                            )),
                    ),
                  ),
                ),
                Container(
                  height: 45.0,
                  margin: EdgeInsets.all(25.0),
                  child: Text(
                    _loginMsg,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
