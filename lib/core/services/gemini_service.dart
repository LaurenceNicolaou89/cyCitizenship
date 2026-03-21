import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  final String _apiKey;

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

  /// Dedicated models with systemInstruction set, avoiding per-message overhead.
  late final GenerativeModel _tutorModel;
  late final GenerativeModel _practiceModel;
  late final GenerativeModel _greekModel;

  /// Cached chat sessions, reused across messages within the same conversation.
  ChatSession? _tutorSession;
  ChatSession? _greekSession;

  /// Track the Greek level so we can reset the session when it changes.
  String? _greekSessionLevel;

  GeminiService({required String apiKey}) : _apiKey = apiKey {
    _tutorModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_tutorSystemPrompt),
    );
    _practiceModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_smartPracticeSystemPrompt),
    );
    _greekModel = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_greekPracticeSystemPrompt),
    );
  }

  /// Send a message to the AI tutor, reusing the cached session.
  ///
  /// The [history] parameter is only used to seed the session when it is first
  /// created (or after a reset). Subsequent calls reuse the existing session
  /// which already contains the full conversation history.
  Future<String> chatWithTutor(List<Content> history, String message) async {
    _tutorSession ??= _tutorModel.startChat(history: history);
    final response = await _tutorSession!.sendMessage(Content.text(message));
    return response.text ?? 'Sorry, I could not generate a response.';
  }

  /// Generate a practice question. Each call is independent so no session
  /// caching is needed — but systemInstruction still saves tokens.
  Future<String> generatePracticeQuestion({
    required String category,
    required String difficulty,
    required String language,
  }) async {
    final prompt =
        'Generate a $difficulty $category question for the Cyprus citizenship exam. Respond in $language.';
    final chat = _practiceModel.startChat();
    final response = await chat.sendMessage(Content.text(prompt));
    return response.text ?? '{}';
  }

  /// Send a message in the Greek practice conversation, reusing the cached
  /// session. If the [level] changes, the session is automatically reset.
  Future<String> greekPractice(
    List<Content> history,
    String message, {
    String level = 'B1',
  }) async {
    // Reset session if the level has changed.
    if (_greekSession == null || _greekSessionLevel != level) {
      _greekSessionLevel = level;
      _greekSession = _greekModel.startChat(
        history: [
          Content.text('Current level: $level'),
          ...history,
        ],
      );
    }
    final response = await _greekSession!.sendMessage(Content.text(message));
    return response.text ?? 'Sorry, I could not generate a response.';
  }

  /// Reset the tutor chat session (e.g. when starting a new conversation).
  void resetTutorSession() {
    _tutorSession = null;
  }

  /// Reset the Greek practice session.
  void resetGreekSession() {
    _greekSession = null;
    _greekSessionLevel = null;
  }

  /// Reset all cached sessions.
  void resetAllSessions() {
    resetTutorSession();
    resetGreekSession();
  }
}
