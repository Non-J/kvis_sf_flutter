import 'dart:async';

import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FlashNotificationOverlay extends StatelessWidget {
  final Widget child;

  FlashNotificationOverlay({@required this.child});

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => child,
        ),
      ],
    );
  }
}

class FlashNotification {
  static Duration _transitionDuration = const Duration(milliseconds: 250);

  static Future<T> SimpleDialog<T>(
    BuildContext context, {
    @required Widget title,
    @required Widget message,
  }) {
    return showFlash<T>(
      context: context,
      persistent: false,
      transitionDuration: _transitionDuration,
      builder: (_, controller) {
        return Flash.dialog(
          controller: controller,
          backgroundColor: Colors.white,
          margin: const EdgeInsets.only(left: 40.0, right: 40.0),
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          child: FlashBar(
            title: title,
            message: message,
          ),
        );
      },
    );
  }

  static Future<T> TopNotification<T>(
    BuildContext context, {
    @required Widget title,
    @required Widget message,
    Duration duration,
  }) {
    return showFlash<T>(
      context: context,
      duration: duration,
      persistent: true,
      transitionDuration: _transitionDuration,
      builder: (_, controller) => Flash(
        controller: controller,
        backgroundColor: Colors.white,
        boxShadows: [BoxShadow(blurRadius: 4)],
        style: FlashStyle.grounded,
        position: FlashPosition.top,
        child: FlashBar(
          title: title,
          message: message,
          primaryAction: FlatButton(
            onPressed: () => controller.dismiss(),
            child: Text('Dismiss', style: TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }

  static Future<T> TopNotificationCritical<T>(
    BuildContext context, {
    @required Widget title,
    @required Widget message,
  }) {
    return showFlash<T>(
      context: context,
      persistent: false,
      transitionDuration: _transitionDuration,
      builder: (_, controller) => Flash(
        controller: controller,
        backgroundColor: Colors.white,
        boxShadows: [BoxShadow(blurRadius: 4)],
        barrierBlur: 1.0,
        barrierColor: Colors.black38,
        barrierDismissible: false,
        style: FlashStyle.grounded,
        position: FlashPosition.top,
        child: FlashBar(
          title: title,
          message: message,
          primaryAction: FlatButton(
            onPressed: () => controller.dismiss(),
            child: Text('Dismiss', style: TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

typedef ActionCallback = void Function(FlashController controller);
