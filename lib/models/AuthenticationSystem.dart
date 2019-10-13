import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;

  Observable<FirebaseUser> user;
  Observable<Map<String, dynamic>> profile;
  PublishSubject<bool> loginLoading;
  PublishSubject<String> loginMessage;

  AuthService() {
    user = Observable(_auth.onAuthStateChanged);

    loginLoading = PublishSubject();
    loginMessage = PublishSubject();

    profile = user.switchMap((FirebaseUser u) {
      if (u != null) {
        return _db
            .collection('users')
            .document(u.uid)
            .snapshots()
            .map((snap) => snap.data);
      } else {
        return Observable.just({});
      }
    });
  }

  void signOut() {
    _auth.signOut();
    loginMessage.add("Signed-out");
  }

  Future<FirebaseUser> signInAnonymously(String username,
      String password) async {
    throw "This sign-in method has been disabled.";
  }

  Future<FirebaseUser> signInBackend(String username, String password) async {
    loginLoading.add(true);
    try {
      AuthResult signIn = await _auth.signInWithEmailAndPassword(
          email: username, password: password);
      updateUserData(signIn.user);
      loginLoading.add(false);
      return signIn.user;
    } catch (err) {
      loginLoading.add(false);
      switch (err.code) {
        case 'ERROR_INVALID_EMAIL':
          loginMessage.add("Make sure your username is correct.");
          break;
        case 'ERROR_USER_NOT_FOUND':
          loginMessage.add("Make sure your credentials are correct.");
          break;
        case 'ERROR_WRONG_PASSWORD':
          loginMessage.add("Make sure your credentials are correct.");
          break;
        default:
          loginMessage.add("Sign-in Failed.\n${err.toString()}");
          break;
      }
      return null;
    }
  }

  void updateUserData(FirebaseUser user) async {
    DocumentReference ref = _db.collection('users').document(user.uid);

    return ref.setData({
      'uid': user.uid,
      'email': user.email,
    }, merge: true);
  }
}

final AuthService authService = AuthService();
