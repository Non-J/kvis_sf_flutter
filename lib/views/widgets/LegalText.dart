import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

class LegalText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(15.0),
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.body1,
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
