import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

Firestore _db = Firestore.instance;

class UserProfile {
  final FirebaseUser user;
  String userProfileType;
  Map<String, dynamic> data = {};
  StorageReference profileStorage;
  File profilePicture;

  UserProfile._(this.user);

  static UserProfile empty(FirebaseUser user) {
    return UserProfile._(user);
  }

  static Future<UserProfile> init(FirebaseUser user) async {
    UserProfile userProfile = UserProfile._(user);

    DocumentSnapshot data =
    await _db.collection('users').document(user.uid).get();
    userProfile.data.addAll(data.data);

    if (!user.isAnonymous) {
      DocumentSnapshot roleData =
      await _db.collection('user_roles').document(user.uid).get();
      userProfile.userProfileType = roleData.data['role'] ?? 'Student';
    } else {
      userProfile.userProfileType = 'Student';
    }

    userProfile.profileStorage =
        FirebaseStorage.instance.ref().child('profiles/${user.uid}');
    userProfile.profilePicture =
        File('${Directory.systemTemp.path}/profile_picture.jpg');

    final StorageReference profilePictureReference =
    userProfile.profileStorage.child('profile_picture.jpg');

    try {
      await profilePictureReference.getDownloadURL();

      final StorageFileDownloadTask profilePictureDownloadTask =
      profilePictureReference.writeToFile(userProfile.profilePicture);

      await profilePictureDownloadTask.future;
    } catch (e) {
      userProfile.profilePicture = null;
    }

    return Future.value(userProfile);
  }

  @override
  String toString() {
    return 'UserProfile{user: $user, _data: $data, profileStorage: $profileStorage, profilePicture: $profilePicture}';
  }
}

class SigningInStatus {
  SigningInStatus(this.loading, this.message);

  final bool loading;
  final String message;

  @override
  String toString() => message;
}

class AuthService {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseUser _user;
  Observable<FirebaseUser> userStream = Observable(_auth.onAuthStateChanged);

  UserProfile _profile;
  BehaviorSubject<UserProfile> _profileSubject =
  BehaviorSubject<UserProfile>.seeded(UserProfile.empty(null));

  Observable<UserProfile> get profileStream => _profileSubject.stream;

  PublishSubject<SigningInStatus> _signingInStatusSubject = PublishSubject();

  Observable<SigningInStatus> get signingInStatus =>
      _signingInStatusSubject.stream;

  AuthService() {
    userStream.listen((FirebaseUser firebaseUser) async {
      // Listen to firebase authentication stream and update the data accordingly
      _user = firebaseUser;

      if (firebaseUser != null) {
        // Currently signed in and is an actual account
        try {
          reloadProfile();
          _signingInStatusSubject
              .add(SigningInStatus(false, 'Sending you to homepage.'));
        } catch (e) {
          _signingInStatusSubject.add(
              SigningInStatus(false, 'Error retrieving user\'s profile data.'));
        }
      } else {
        // Currently not signed in
        _profileSubject.add(UserProfile.empty(firebaseUser));
        _signingInStatusSubject.add(SigningInStatus(false, 'Please sign-in'));
      }
    });
  }

  void dispose() {
    _profileSubject.close();
    _signingInStatusSubject.close();
  }

  Future signOut() async {
    if (_user != null && _user.isAnonymous) {
      return _user.delete();
    } else {
      await _auth.signOut();
      return Future.value();
    }
  }

  void signInAnonymously() async {
    _signingInStatusSubject.add(SigningInStatus(true, 'Signing in...'));

    if (_user != null) {
      // Sign out of the current account (if any)
      await signOut();
    }

    try {
      await _auth.signInAnonymously();
    } catch (err) {
      _signingInStatusSubject
          .add(SigningInStatus(false, 'Sign-in Failed.\n${err.toString()}'));
    }
  }

  void signInBackend(String username, String password) async {
    _signingInStatusSubject.add(SigningInStatus(true, 'Signing in...'));

    if (_user != null) {
      // Sign out of the current account (if any)
      await signOut();
    }

    try {
      await _auth.signInWithEmailAndPassword(
          email: username, password: password);
    } catch (err) {
      _signingInStatusSubject.add(
          SigningInStatus(false, 'Sign-in Failed.\n${err.code.toString()}'));
    }
  }

  void reloadProfile() async {
    // Publish profile data
    _profileSubject.add(UserProfile.empty(_user));
    if (!_user.isAnonymous) {
      _profile = await UserProfile.init(_user);
      _profileSubject.add(_profile);
    }
  }

  void updateProfile(Map<String, dynamic> newData) {
    if (!_user.isAnonymous) {
      DocumentReference ref = _db.collection('users').document(_user.uid);
      ref.setData(newData, merge: true);
      reloadProfile();
    }
  }
}

final AuthService authService = AuthService();
