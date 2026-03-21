import 'package:shared_preferences/shared_preferences.dart';

/// Persists daily AI message usage counts in SharedPreferences.
///
/// Key pattern: `ai_messages_{feature}_count` and `ai_messages_{feature}_date`
/// Count resets automatically when the stored date differs from today.
class AiRateLimitService {
  static const _prefix = 'ai_messages';

  final SharedPreferences _prefs;

  AiRateLimitService(this._prefs);

  /// Returns the number of messages used today for [feature].
  /// Resets to 0 if the stored date is not today.
  int getUsageCount(String feature) {
    final storedDate = _prefs.getString(_dateKey(feature));
    final today = _todayString();

    if (storedDate != today) {
      // Date changed — reset count
      _prefs.setInt(_countKey(feature), 0);
      _prefs.setString(_dateKey(feature), today);
      return 0;
    }

    return _prefs.getInt(_countKey(feature)) ?? 0;
  }

  /// Increments the usage count for [feature] by 1 and persists it.
  /// Returns the new count.
  int incrementUsage(String feature) {
    final today = _todayString();
    final storedDate = _prefs.getString(_dateKey(feature));

    int count;
    if (storedDate != today) {
      count = 1;
      _prefs.setString(_dateKey(feature), today);
    } else {
      count = (_prefs.getInt(_countKey(feature)) ?? 0) + 1;
    }

    _prefs.setInt(_countKey(feature), count);
    return count;
  }

  String _countKey(String feature) => '${_prefix}_${feature}_count';
  String _dateKey(String feature) => '${_prefix}_${feature}_date';

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
