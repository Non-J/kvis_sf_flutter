import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:kvis_sf/models/AuthenticationSystem.dart';
import 'package:kvis_sf/models/GlobalState.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      "Welcome",
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
                  // TODO: Either pull the analytics or re-enable it.
                  // _AnalyticControl(),
                ],
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

  bool _loggingIn = false;
  String _loginMsg = "";

  void _signIn() async {
    try {
      setState(() {
        _loggingIn = true;
        _loginMsg = "";
      });

      _formKey.currentState.save();
      if (_formKey.currentState.validate()) {
        analytics.logLogin(loginMethod: "Username and Password");

        await (Future.delayed(Duration(milliseconds: 2000)));

        AuthSystem.signInAnonymously(_formKey.currentState.value["username"],
            _formKey.currentState.value["password"]);
        return;
      }

      setState(() {
        _loggingIn = false;
        _loginMsg = "";
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
    return Column(
      children: <Widget>[
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
                    labelText: "Username",
                    filled: true,
                    fillColor: Color.fromRGBO(255, 255, 255, 0.3),
                  ),
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
                    labelText: "Password",
                    filled: true,
                    fillColor: Color.fromRGBO(255, 255, 255, 0.3),
                  ),
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
                "Login",
                textScaleFactor: 1.5,
              )),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(20.0),
          child: Text(_loginMsg,
              textAlign: TextAlign.center,
              style: Theme
                  .of(context)
                  .textTheme
                  .body1),
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
                  text: "By using this app, you've agreed to our ",
                ),
                TextSpan(
                  text: "Terms of Use and Privacy Policy.",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      url_launcher
                          .launch("http://110.164.80.12/ISSF16/index.php");
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

class _AnalyticControl extends StatefulWidget {
  @override
  _AnalyticControlState createState() => _AnalyticControlState();
}

class _AnalyticControlState extends State<_AnalyticControl> {
  bool _analyticsEnabled;

  @override
  void initState() {
    super.initState();
    _analyticsEnabled = AnalyticsState.instance.analyticsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Checkbox(
          value: _analyticsEnabled,
          onChanged: (value) {
            AnalyticsState.instance.analyticsEnabled = value;
            setState(() {
              _analyticsEnabled = value;
            });
          },
        ),
        RichText(
            text: TextSpan(children: [
              TextSpan(
                text: "Share Usage Statistics.\n",
                style: Theme
                    .of(context)
                    .textTheme
                    .subtitle,
              ),
              TextSpan(
                  text:
                  "Usage Statistics allows us to improve the app for next year's science fair.\nSee our privacy policy for more details.",
                  style: Theme
                      .of(context)
                      .textTheme
                      .body2)
            ])),
      ],
    );
  }
}
