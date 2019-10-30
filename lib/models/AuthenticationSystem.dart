import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';

class UserProfile {
  static Firestore _db = Firestore.instance;

  final FirebaseUser user;
  Map<String, dynamic> data = {};
  StorageReference profileStorage;
  File profilePicture;

  UserProfile._(this.user);

  static UserProfile empty() {
    return UserProfile._(null);
  }

  static Future<UserProfile> init(FirebaseUser user) async {
    UserProfile userProfile = UserProfile._(user);

    DocumentSnapshot data =
    await _db.collection('users').document(user.uid).get();
    userProfile.data.addAll(data.data);

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

  bool get isEmpty => (user == null);

  @override
  String toString() {
    return 'UserProfile{user: $user, _data: $data, profileStorage: $profileStorage, profilePicture: $profilePicture}';
  }
}

class AuthService {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static Firestore _db = Firestore.instance;

  FirebaseUser _currentUser;
  Observable<FirebaseUser> user = Observable(_auth.onAuthStateChanged);
  BehaviorSubject<UserProfile> profile =
  BehaviorSubject<UserProfile>.seeded(UserProfile.empty());
  PublishSubject<bool> loginLoading = PublishSubject();
  PublishSubject<String> loginMessage = PublishSubject();

  AuthService() {
    user.listen((FirebaseUser firebaseUser) async {
      _currentUser = firebaseUser;
      if (_currentUser != null) {
        try {
          profile.add(await UserProfile.init(_currentUser));
          loginLoading.add(false);
          loginMessage.add('Sending you to homepage.');
        } catch (e) {
          loginLoading.add(false);
          loginMessage.add('Error retrieving user\'s profile data.');
        }
      } else {
        profile.add(UserProfile.empty());
        loginLoading.add(false);
        loginMessage.add('Please sign-in');
      }
    });
  }

  void signOut() {
    _auth.signOut();
  }

  Future<FirebaseUser> signInAnonymously(String username, String password) async {
    throw 'This sign-in method has been disabled.';
  }

  Future<FirebaseUser> signInBackend(String username, String password) async {
    loginLoading.add(true);
    loginMessage.add('');
    try {
      AuthResult signIn = await _auth.signInWithEmailAndPassword(
          email: username, password: password);
      return signIn.user;
    } catch (err) {
      loginLoading.add(false);
      switch (err.code) {
        case 'ERROR_INVALID_EMAIL':
          loginMessage.add('Make sure your username is correct.');
          break;
        case 'ERROR_USER_NOT_FOUND':
          loginMessage.add('Make sure your credentials are correct.');
          break;
        case 'ERROR_WRONG_PASSWORD':
          loginMessage.add('Make sure your credentials are correct.');
          break;
        default:
          loginMessage.add('Sign-in Failed.\n${err.toString()}');
          break;
      }
      return null;
    }
  }

  Future<void> reloadProfile() async {
    profile.add(await UserProfile.init(_currentUser));
    return Future.value();
  }

  Future<void> updateProfile(Map<String, dynamic> newData) {
    DocumentReference ref = _db.collection('users').document(_currentUser.uid);
    ref.setData(newData, merge: true);

    return reloadProfile();
  }
}

final AuthService authService = AuthService();
