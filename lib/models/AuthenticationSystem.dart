import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

enum LogInMode { notLoggedIn, anonymously, backendToken }

class AuthUser {
  LogInMode logInMode;
  String username;
  Map<String, dynamic> profile;
  String token;
}

class AuthSystem {
  static AuthUser _user = AuthUser();
  static AuthSystem instance = new AuthSystem._();

  AuthSystem._();

  static StreamController _authStateChangedController =
  StreamController<AuthUser>.broadcast();

  static Stream<AuthUser> get onAuthStateChanged =>
      _authStateChangedController.stream;

  static AuthUser get authUser => _user;

  static String get username => _user.username;

  static LogInMode get logInMode => _user.logInMode;

  static void _save() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      prefs.setString("auth_username", _user.username ?? "");
      prefs.setString("auth_token", _user.token ?? "");
      prefs.setString("auth_logInMode", _user.logInMode.toString());
    });
  }

  static void init() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      final LogInMode loadedLoginMode = LogInMode.values
          .firstWhere((e) => e.toString() == prefs.getString("auth_logInMode"));

      switch (loadedLoginMode) {
        case LogInMode.anonymously:
          _user.username = prefs.getString("auth_username");
          _user.logInMode = LogInMode.anonymously;
          _authStateChangedController.add(_user);
          break;
        case LogInMode.backendToken:
          prefs.setString("auth_username", _user.username ?? "");
          prefs.setString("auth_token", _user.token ?? "");
          _user.logInMode = LogInMode.backendToken;
          _authStateChangedController.add(_user);

          break;

        case LogInMode.notLoggedIn:
        default:
          signOut();
          break;
      }
    }).catchError((error) {
      signOut();
    });
  }

  static void signOut() {
    _user.logInMode = LogInMode.notLoggedIn;
    _authStateChangedController.add(_user);
    _save();
  }

  static void signInAnonymously(String username, String password) async {
    if (password == "debug_reject") {
      await Future.delayed(const Duration(seconds: 3));

      throw "Sign-in rejection test";
    }
    _user.logInMode = LogInMode.anonymously;
    _user.username = username;
    _authStateChangedController.add(_user);
    _save();
  }

  static void signInBackend(String username, String password) async {
    _authStateChangedController.add(_user);
    _save();
  }
}
