import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/services/gemini_service.dart';
import 'ai_tutor_event.dart';
import 'ai_tutor_state.dart';

class AiTutorBloc extends Bloc<AiTutorEvent, AiTutorState> {
  final GeminiService _geminiService;
  final bool isPremium;

  /// Maximum messages retained in the UI list.
  static const int _maxMessages = 100;

  /// Sliding window size sent to Gemini to limit token usage.
  static const int _geminiWindowSize = 50;

  List<ChatMessage> _messages = [];
  int _messagesUsedToday = 0;
  DateTime _lastResetDate = DateTime.now();

  int get dailyLimit => isPremium ? 50 : 3;

  AiTutorBloc({
    required GeminiService geminiService,
    this.isPremium = false,
  })  : _geminiService = geminiService,
        super(const AiTutorInitial()) {
    on<SendMessage>(_onSendMessage);
    on<ClearConversation>(_onClearConversation);
  }

  void _checkDayReset() {
    final now = DateTime.now();
    if (now.day != _lastResetDate.day ||
        now.month != _lastResetDate.month ||
        now.year != _lastResetDate.year) {
      _messagesUsedToday = 0;
      _lastResetDate = now;
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<AiTutorState> emit,
  ) async {
    _checkDayReset();

    if (_messagesUsedToday >= dailyLimit) {
      emit(AiTutorLoaded(
        messages: List.unmodifiable(_messages),
        messagesUsedToday: _messagesUsedToday,
        dailyLimit: dailyLimit,
      ));
      return;
    }

    final userMessage = ChatMessage(
      role: 'user',
      content: event.message,
      timestamp: DateTime.now(),
    );
    _messages = [..._messages, userMessage];

    emit(AiTutorLoading(messages: List.unmodifiable(_messages)));

    try {
      // Build history using a sliding window to limit token usage.
      // Exclude the last user message (sent separately by chatWithTutor).
      final allExceptLast = _messages.length > 1
          ? _messages.sublist(0, _messages.length - 1)
          : <ChatMessage>[];
      final windowStart = allExceptLast.length > _geminiWindowSize
          ? allExceptLast.length - _geminiWindowSize
          : 0;
      final history = allExceptLast
          .sublist(windowStart)
          .where((m) => m.role == 'user' || m.role == 'assistant')
          .map((m) => Content(m.role == 'user' ? 'user' : 'model', [
                TextPart(m.content),
              ]))
          .toList();

      final response = await _geminiService.chatWithTutor(
        history,
        event.message,
      );

      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      );
      _messages = [..._messages, assistantMessage];
      _trimMessages();
      _messagesUsedToday++;

      emit(AiTutorLoaded(
        messages: List.unmodifiable(_messages),
        messagesUsedToday: _messagesUsedToday,
        dailyLimit: dailyLimit,
      ));
    } catch (e) {
      // Remove the user message that failed
      _messages = _messages.sublist(0, _messages.length - 1);
      emit(AiTutorError(
        message: 'Failed to get response. Please try again.',
        previousMessages: List.unmodifiable(_messages),
      ));
    }
  }

  /// Trims the message list to [_maxMessages], dropping the oldest entries.
  void _trimMessages() {
    if (_messages.length > _maxMessages) {
      _messages = _messages.sublist(_messages.length - _maxMessages);
    }
  }

  Future<void> _onClearConversation(
    ClearConversation event,
    Emitter<AiTutorState> emit,
  ) async {
    _messages = [];
    _geminiService.resetTutorSession();
    emit(AiTutorLoaded(
      messages: const [],
      messagesUsedToday: _messagesUsedToday,
      dailyLimit: dailyLimit,
    ));
  }
}
