import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

enum LogInMode { notLoggedIn, anonymously, backendToken }

LogInMode logInModeParse(String str) {
  switch (str) {
    case "logInMode.anonymously":
      return LogInMode.anonymously;
      break;
    case "logInMode.backendToken":
      return LogInMode.backendToken;
      break;
    case "logInMode.notLoggedIn":
    default:
      return LogInMode.notLoggedIn;
      break;
  }
}

class AuthUser {
  // Data type for storing user information

  LogInMode logInMode;
  String username;
  String password;
  Map<String, dynamic> profile;
  String token;

  AuthUser(
      this.logInMode, this.username, this.password, this.profile, this.token);

  AuthUser.empty() : logInMode = LogInMode.notLoggedIn;
}

class AuthSystem {
  // AuthSystem is similar to firebase_auth

  // Store and get user information
  static AuthUser user;

  AuthUser get initialAuthState => user;

  String get username => user.username;

  Map<String, dynamic> get profile => user.profile;

  String get token {
    // TODO: Implement token get with expire check

    return "";
  }

  // Listening to state changes via stream
  StreamController _authStateChangedController =
      StreamController<AuthUser>.broadcast();

  Stream get onAuthStateChanged => _authStateChangedController.stream;

  // AuthSystem.instance
  static AuthSystem instance = new AuthSystem._();

  AuthSystem._();

  // SignIn and SignOut
  Future<AuthUser> signOut() async {
    AuthSystem.user = AuthUser.empty();
    _authStateChangedController.add(AuthSystem.user);
    _save();
    return Future.value(null);
  }

  Future<AuthUser> signInAnonymously(String username, String password) async {
    AuthSystem.user =
        AuthUser(LogInMode.anonymously, username, password, null, null);
    _authStateChangedController.add(AuthSystem.user);
    _save();
    return Future.value(AuthSystem.user);
  }

  Future<AuthUser> signInBackend(String username, String password) {
    throw "Not Implemented";
  }

  // State persistence
  init() {
    try {
      SharedPreferences.getInstance().then((prefs) {
        final data = prefs.getString("AuthSystem_Persistence");
        if (data == null) {
          signOut();
        } else {
          var persist = jsonDecode(data);
          switch (logInModeParse(persist["isLoggedIn"])) {
            case LogInMode.anonymously:
              signInAnonymously(persist["username"], persist["password"]);
              break;
            case LogInMode.backendToken:
              signInBackend(persist["username"], persist["password"]);
              break;
            case LogInMode.notLoggedIn:
            default:
              signOut();
              break;
          }
        }
      });
    } catch (error) {
      print(error);
      signOut();
    }
  }

  _save() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(
          "AuthSystem_Persistence",
          jsonEncode({
            "isLoggedIn": user.logInMode.toString(),
            "username": user.username,
            "password": user.password,
          }));
    });
  }
}
