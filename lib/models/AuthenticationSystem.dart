import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

Firestore _db = Firestore.instance;

class SigningInStatus {
  SigningInStatus(this.loading, this.message);

  final bool loading;
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  final Map<String, dynamic> _defaultProfileData = {
    'role': 'Student',
    'isProperUser': false,
    'isDefaultProfile': true,
  };

  static FirebaseAuth _auth = FirebaseAuth.instance;

  // Firebase user stuff
  FirebaseUser _user;
  BehaviorSubject<FirebaseUser> _userSubject = BehaviorSubject.seeded(null);

  Observable<FirebaseUser> get userStream => _userSubject.stream;

  Observable<FirebaseUser> get rawUserStream =>
      Observable(_auth.onAuthStateChanged);

  // For locking UI buttons are display sign in result
  PublishSubject<SigningInStatus> _signingInStatusSubject = PublishSubject();

  Observable<SigningInStatus> get signingInStatus =>
      _signingInStatusSubject.stream;

  // Profile stuff
  StorageReference profileStorage;

  BehaviorSubject<Map<String, dynamic>> _dataSubject = BehaviorSubject();

  Observable<Map<String, dynamic>> get dataStream => _dataSubject.stream;

  // Initialize streams
  AuthService() {
    _userSubject.addStream(_auth.onAuthStateChanged);
    _dataSubject.addStream(
      rawUserStream.switchMap((FirebaseUser firebaseUser) {
        profileStorage = null;

        if (firebaseUser == null) {
          // Not logged in
          return Observable.just(_defaultProfileData);
        } else if (firebaseUser.isAnonymous) {
          // Anonymous login
          return Observable.just(_defaultProfileData);
        }

        profileStorage = FirebaseStorage.instance
            .ref()
            .child('profiles/${firebaseUser.uid}');

        return Observable.combineLatest2(
            _db
                .collection('users_immutable')
                .document(firebaseUser.uid)
                .snapshots(),
            _db.collection('users').document(firebaseUser.uid).snapshots(),
                (DocumentSnapshot dataImmutable, DocumentSnapshot data) {
              Map<String, dynamic> _result = _defaultProfileData;
              _result.addAll(data.data ?? {});
              _result.addAll(dataImmutable.data ?? {});
              _result['isProperUser'] = !firebaseUser.isAnonymous;
              _result['isDefaultProfile'] = false;
              return _result;
            });
      }).onErrorReturn(_defaultProfileData),
      cancelOnError: false,
    );
  }

  void dispose() {
    _userSubject.close();
    _dataSubject.close();
    _signingInStatusSubject.close();
  }

  Future signOut() async {
    if (_user != null && _user.isAnonymous) {
      return _user.delete();
    } else {
      return _auth.signOut();
    }
  }

  void signInAnonymously() async {
    if (_user != null) {
      // Sign out of the current account (if any)
      await signOut();
    }

    _signingInStatusSubject.add(SigningInStatus(true, 'Signing in...'));

    try {
      await _auth.signInAnonymously();
      _signingInStatusSubject
          .add(SigningInStatus(false, 'Sending you to homepage.'));
    } catch (err) {
      _signingInStatusSubject
          .add(SigningInStatus(false, 'Sign-in Failed.\n${err.toString()}'));
    }
  }

  void signInBackend(String username, String password) async {
    if (_user != null) {
      // Sign out of the current account (if any)
      await signOut();
    }

    _signingInStatusSubject.add(SigningInStatus(true, 'Signing in...'));

    try {
      await _auth.signInWithEmailAndPassword(
          email: username, password: password);
      _signingInStatusSubject
          .add(SigningInStatus(false, 'Sending you to homepage.'));
    } catch (err) {
      _signingInStatusSubject.add(
          SigningInStatus(false, 'Sign-in Failed.\n${err.code.toString()}'));
    }
  }

  Future<File> getProfilePicture() async {
    File _output = File('${Directory.systemTemp.path}/profile_picture.jpg');

    try {
      await this
          .profileStorage
          .child('profile_picture.jpg')
          .writeToFile(_output)
          .future;
    } catch (e) {
      return null;
    }

    return _output;
  }
}

final AuthService authService = AuthService();
