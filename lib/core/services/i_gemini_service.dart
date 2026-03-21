import '../models/chat_message.dart';

abstract class IGeminiService {
  Future<String> chatWithTutor(List<ChatMessage> history, String message);
  Future<String> generatePracticeQuestion({
    required String category,
    required String difficulty,
    required String language,
  });
  Future<String> greekPractice(
    List<ChatMessage> history,
    String message, {
    String level = 'B1',
  });
}
