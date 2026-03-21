import 'package:google_generative_ai/google_generative_ai.dart';

import 'i_gemini_service.dart';

class GeminiService implements IGeminiService {
  late final GenerativeModel _model;

  static const _tutorSystemPrompt = '''
You are an expert tutor helping students prepare for the Cyprus citizenship exam.
You have deep knowledge of Cyprus history, politics, geography, culture, and daily life.
Answer questions concisely and accurately, focusing on exam-relevant information.
If asked something outside the exam scope, politely redirect to exam topics.
Always respond in the language the user writes in.
''';

  static const _smartPracticeSystemPrompt = '''
You are a Cyprus citizenship exam question generator.
Generate one multiple-choice question with exactly 4 options (A, B, C, D).
Format your response as JSON:
{"question": "...", "options": ["A. ...", "B. ...", "C. ...", "D. ..."], "correctIndex": 0, "explanation": "..."}
Focus on the requested category and difficulty level.
Respond in the requested language.
''';

  static const _greekPracticeSystemPrompt = '''
You are a Greek language conversation partner for Cyprus citizenship exam candidates.
Speak in Greek and help the user practice conversational Greek.
Provide transliterations in parentheses after Greek text.
Gently correct mistakes and explain grammar.
Adapt your level: A2 (elementary) or B1 (intermediate) as requested.
Use daily life scenarios relevant to living in Cyprus.
''';

  GeminiService({required String apiKey}) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: apiKey,
    );
  }

  @override
  Future<String> chatWithTutor(List<Content> history, String message) async {
    final chat = _model.startChat(
      history: [
        Content.text(_tutorSystemPrompt),
        ...history,
      ],
    );
    final response = await chat.sendMessage(Content.text(message));
    return response.text ?? 'Sorry, I could not generate a response.';
  }

  @override
  Future<String> generatePracticeQuestion({
    required String category,
    required String difficulty,
    required String language,
  }) async {
    final prompt =
        'Generate a $difficulty $category question for the Cyprus citizenship exam. Respond in $language.';
    final chat = _model.startChat(
      history: [Content.text(_smartPracticeSystemPrompt)],
    );
    final response = await chat.sendMessage(Content.text(prompt));
    return response.text ?? '{}';
  }

  @override
  Future<String> greekPractice(
    List<Content> history,
    String message, {
    String level = 'B1',
  }) async {
    final chat = _model.startChat(
      history: [
        Content.text('$_greekPracticeSystemPrompt\nCurrent level: $level'),
        ...history,
      ],
    );
    final response = await chat.sendMessage(Content.text(message));
    return response.text ?? 'Sorry, I could not generate a response.';
  }
}
