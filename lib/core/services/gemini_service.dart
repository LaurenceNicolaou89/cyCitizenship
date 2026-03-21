import 'package:cloud_functions/cloud_functions.dart';

/// Message structure for chat history sent to Cloud Functions.
class ChatMessage {
  final String role;
  final String content;

  const ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toMap() => {'role': role, 'content': content};
}

import '../utils/prompt_sanitizer.dart';

class GeminiService {
  final FirebaseFunctions _functions;

  GeminiService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  /// Chat with the AI tutor. [history] is the conversation so far,
  /// [message] is the new user message.
  Future<String> chatWithTutor(
    List<ChatMessage> history,
    String message,
  ) async {
    final sanitized = PromptSanitizer.sanitize(message);
    final callable = _functions.httpsCallable('chatWithTutor');
    final result = await callable.call<Map<String, dynamic>>({
      'messages': history.map((m) => m.toMap()).toList(),
      'message': sanitized,
    });
    return (result.data['response'] as String?) ??
        'Sorry, I could not generate a response.';
  }

  /// Generate a practice question for the given category/difficulty/language.
  Future<String> generatePracticeQuestion({
    required String category,
    required String difficulty,
    required String language,
  }) async {
    final callable = _functions.httpsCallable('generatePracticeQuestion');
    final result = await callable.call<Map<String, dynamic>>({
      'category': category,
      'difficulty': difficulty,
      'language': language,
    });
    return (result.data['response'] as String?) ?? '{}';
  }

  /// Greek language practice chat. [history] is the conversation so far,
  /// [message] is the new user message, [level] is A2 or B1.
  Future<String> greekPractice(
    List<ChatMessage> history,
    String message, {
    String level = 'B1',
  }) async {
    final sanitized = PromptSanitizer.sanitize(message);
    final callable = _functions.httpsCallable('greekPractice');
    final result = await callable.call<Map<String, dynamic>>({
      'messages': history.map((m) => m.toMap()).toList(),
      'message': sanitized,
      'level': level,
    });
    return (result.data['response'] as String?) ??
        'Sorry, I could not generate a response.';
  }

  /// Reset the tutor chat session (e.g. when starting a new conversation).
  /// No-op for Cloud Functions backend — sessions are server-managed.
  void resetTutorSession() {}

  /// Reset the Greek practice session.
  /// No-op for Cloud Functions backend — sessions are server-managed.
  void resetGreekSession() {}

  /// Reset all cached sessions.
  /// No-op for Cloud Functions backend — sessions are server-managed.
  void resetAllSessions() {
    resetTutorSession();
    resetGreekSession();
  }
}
