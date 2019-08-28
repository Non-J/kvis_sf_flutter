import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

const api_endpoint = "https://somewhere.example.com";

final FirebaseAnalytics analytics = FirebaseAnalytics();

class AnalyticsState {
  static bool _analyticsEnabled;

  static void init() async {
    /*
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      _analyticsEnabled = prefs.getBool("analytics_enabled") ?? true;
      analytics.setAnalyticsCollectionEnabled(_analyticsEnabled);
    } catch (error) {
      _analyticsEnabled = true;
      analytics.setAnalyticsCollectionEnabled(_analyticsEnabled);
    }
     */

    _analyticsEnabled = false;
    analytics.setAnalyticsCollectionEnabled(_analyticsEnabled);
  }

  bool get analyticsEnabled => _analyticsEnabled;

  set analyticsEnabled(bool value) {
    analytics.logEvent(
        name: "toggle_analytics", parameters: {"value": value.toString()});
    _analyticsEnabled = value;
    analytics.setAnalyticsCollectionEnabled(_analyticsEnabled);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("analytics_enabled", value);
    });
  }

  static AnalyticsState instance = new AnalyticsState._();

  AnalyticsState._();
}
