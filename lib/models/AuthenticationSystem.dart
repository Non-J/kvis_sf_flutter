import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

  StreamController _authStateChangedController =
  StreamController<AuthUser>.broadcast();

  Stream<AuthUser> get onAuthStateChanged => _authStateChangedController.stream;

  AuthUser get authUser => _user;

  String get username => _user.username;

  LogInMode get logInMode => _user.logInMode;

  void _save() {
    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      prefs.setString("auth_username", _user.username ?? "");
      prefs.setString("auth_token", _user.token ?? "");
      prefs.setString("auth_logInMode", _user.logInMode.toString());
    });
  }

  void init() {
    try {
      SharedPreferences.getInstance().then((SharedPreferences prefs) {
        final LogInMode loadedLoginMode = LogInMode.values.firstWhere(
                (e) => e.toString() == prefs.getString("auth_logInMode"));

        switch (loadedLoginMode) {
          case LogInMode.anonymously:
            _user.username = prefs.getString("auth_username");
            _user.logInMode = LogInMode.anonymously;
            break;
          case LogInMode.backendToken:
            prefs.setString("auth_username", _user.username ?? "");
            prefs.setString("auth_token", _user.token ?? "");
            _user.logInMode = LogInMode.backendToken;

            break;

          case LogInMode.notLoggedIn:
          default:
            _user.logInMode = LogInMode.notLoggedIn;
            break;
        }

        _authStateChangedController.add(_user);
      });
    } catch (error) {
      // Failed to load; assume not logged in.
      signOut();
    }
  }

  void signOut() {
    _user.logInMode = LogInMode.notLoggedIn;
    _authStateChangedController.add(_user);
    _save();
  }

  void signInAnonymously(String username, String password) async {
    if (password == "debug_reject") {
      await Future.delayed(const Duration(seconds: 3));

      throw "Sign-in rejection test";
    }
    _user.logInMode = LogInMode.anonymously;
    _user.username = username;
    _authStateChangedController.add(_user);
    _save();
  }

  void signInBackend(String username, String password) async {
    _save();
  }
}
