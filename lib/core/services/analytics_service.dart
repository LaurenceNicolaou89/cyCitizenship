import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> logExamCompleted({
    required int score,
    required int total,
    required bool passed,
  }) async {
    await _analytics.logEvent(
      name: 'exam_completed',
      parameters: {
        'score': score,
        'total': total,
        'passed': passed,
        'percentage': (score / total * 100).round(),
      },
    );
  }

  Future<void> logFeatureUsed(String feature) async {
    await _analytics.logEvent(
      name: 'feature_used',
      parameters: {'feature': feature},
    );
  }

  Future<void> logSubscriptionPurchased() async {
    await _analytics.logEvent(name: 'subscription_purchased');
  }

  Future<void> setUserProperties({
    String? language,
    bool? isPremium,
    String? examRoute,
  }) async {
    if (language != null) {
      await _analytics.setUserProperty(name: 'language', value: language);
    }
    if (isPremium != null) {
      await _analytics.setUserProperty(
        name: 'is_premium',
        value: isPremium.toString(),
      );
    }
    if (examRoute != null) {
      await _analytics.setUserProperty(name: 'exam_route', value: examRoute);
    }
  }
}
