import 'package:flutter/material.dart';

import 'utils.dart';

void openAboutPage(BuildContext context) {
  triggerFullPage(
      context,
      Text("KVIS Science Fair"),
      Column(
        children: <Widget>[
          Text(
              "The highlight of KVIS is in its gaggle of geese. Beware of them as they will definitely bite when you coe close to them.")
        ],
      ));
}
