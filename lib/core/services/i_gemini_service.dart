import 'package:google_generative_ai/google_generative_ai.dart';

abstract class IGeminiService {
  Future<String> chatWithTutor(List<Content> history, String message);
  Future<String> generatePracticeQuestion({
    required String category,
    required String difficulty,
    required String language,
  });
  Future<String> greekPractice(
    List<Content> history,
    String message, {
    String level = 'B1',
  });
}
