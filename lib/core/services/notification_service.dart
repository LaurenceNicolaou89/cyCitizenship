import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _messaging.getToken();
      if (token != null) {
        _fcmToken = token;
      }

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        if (_userId != null) {
          _saveTokenToFirestore(_userId!, newToken);
        }
      });
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  String? _fcmToken;
  String? _userId;
  void Function(String route)? onNavigate;

  String? get fcmToken => _fcmToken;

  Future<void> setUserId(String userId) async {
    _userId = userId;
    if (_fcmToken != null) {
      await _saveTokenToFirestore(userId, _fcmToken!);
    }
  }

  Future<void> _saveTokenToFirestore(String userId, String token) async {
    await _db.collection('users').doc(userId).update({
      'fcmToken': token,
    });
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Foreground messages are handled by the app UI
    // Could show a local notification or in-app banner
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final route = message.data['route'];
    if (route != null && onNavigate != null) {
      onNavigate!(route);
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  Future<void> subscribeToExamReminders() async {
    await subscribeToTopic('exam_reminders');
  }

  Future<void> subscribeToDailyQuestions() async {
    await subscribeToTopic('daily_questions');
  }

  Future<void> unsubscribeFromAll() async {
    await unsubscribeFromTopic('exam_reminders');
    await unsubscribeFromTopic('daily_questions');
  }
}
