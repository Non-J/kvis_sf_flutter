import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics();

class GlobalState {
  // Store and get data
  final Map<dynamic, dynamic> _data = {};

  set(key, value) {
    _data[key] = value;
    _stateChangedController.add(_data);
  }

  setPersist(key, value) {
    // TODO: Implement this
    throw "Not Implemented: GlobalState.setPersist";
  }

  get(key) {
    return _data[key];
  }

  init() {
    // TODO: Implement this: Initial recall of persistence state
    throw "Not Implemented: GlobalState.init";
  }

  get state => _data;

  // Listening to state changes via stream
  StreamController _stateChangedController = StreamController.broadcast();

  Stream get onStateChanged => _stateChangedController.stream;

  // AuthSystem.instance
  static GlobalState instance = new GlobalState._();

  GlobalState._();
}
