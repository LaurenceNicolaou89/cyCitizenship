import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/chat_message.dart';
import '../../../core/services/gemini_service.dart';
import 'greek_practice_event.dart';
import 'greek_practice_state.dart';

class GreekPracticeBloc
    extends Bloc<GreekPracticeEvent, GreekPracticeState> {
  final GeminiService _geminiService;
  final bool isPremium;

  /// Maximum messages retained in the UI list.
  static const int _maxMessages = 100;

  /// Sliding window size sent to the backend to limit token usage.
  static const int _geminiWindowSize = 20;

  List<ChatMessage> _messages = [];
  String _level = 'B1';
  int _messagesUsedToday = 0;
  DateTime _lastResetDate = DateTime.now();

  int get dailyLimit => isPremium ? 50 : 3;

  GreekPracticeBloc({
    required GeminiService geminiService,
    this.isPremium = false,
  })  : _geminiService = geminiService,
        super(const GreekPracticeInitial()) {
    on<SendGreekMessage>(_onSendMessage);
    on<SwitchLanguageLevel>(_onSwitchLevel);
    on<ResetGreekConversation>(_onResetConversation);
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
    SendGreekMessage event,
    Emitter<GreekPracticeState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    _checkDayReset();

    if (_messagesUsedToday >= dailyLimit) {
      emit(GreekPracticeLoaded(
        messages: List.unmodifiable(_messages),
        level: _level,
        messagesUsedToday: _messagesUsedToday,
        dailyLimit: dailyLimit,
      ));
      return;
    }

    final userMessage = ChatMessage(
      role: 'user',
      content: event.message.trim(),
      timestamp: DateTime.now(),
    );
    _messages = [..._messages, userMessage];

    emit(GreekPracticeLoading(
      messages: List.unmodifiable(_messages),
      level: _level,
    ));

    try {
      // Build history using a sliding window to limit token usage.
      // Exclude the last user message (sent separately by greekPractice).
      final allExceptLast = _messages.length > 1
          ? _messages.sublist(0, _messages.length - 1)
          : <ChatMessage>[];
      final windowStart = allExceptLast.length > _geminiWindowSize
          ? allExceptLast.length - _geminiWindowSize
          : 0;
      final history = allExceptLast
          .sublist(windowStart)
          .map((m) => ChatMessage(
                role: m.isUser ? 'user' : 'model',
                content: m.content,
                timestamp: m.timestamp,
              ))
          .toList();

      final response = await _geminiService.greekPractice(
        history,
        event.message.trim(),
        level: _level,
      );

      final assistantMessage = ChatMessage(
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      );
      _messages = [..._messages, assistantMessage];
      _trimMessages();
      _messagesUsedToday++;

      emit(GreekPracticeLoaded(
        messages: List.unmodifiable(_messages),
        level: _level,
        messagesUsedToday: _messagesUsedToday,
        dailyLimit: dailyLimit,
      ));
    } catch (e) {
      // Remove the user message that failed
      _messages = _messages.sublist(0, _messages.length - 1);
      emit(GreekPracticeError(
        message: 'Failed to get response. Please try again.',
        previousMessages: List.unmodifiable(_messages),
        level: _level,
      ));
    }
  }

  Future<void> _onSwitchLevel(
    SwitchLanguageLevel event,
    Emitter<GreekPracticeState> emit,
  ) async {
    _level = event.level;

    if (_messages.isEmpty) {
      emit(GreekPracticeInitial(level: _level));
    } else {
      emit(GreekPracticeLoaded(
        messages: List.unmodifiable(_messages),
        level: _level,
        messagesUsedToday: _messagesUsedToday,
        dailyLimit: dailyLimit,
      ));
    }
  }

  Future<void> _onResetConversation(
    ResetGreekConversation event,
    Emitter<GreekPracticeState> emit,
  ) async {
    _messages = [];
    emit(GreekPracticeInitial(level: _level));
  }

  /// Trims the message list to [_maxMessages], dropping the oldest entries.
  void _trimMessages() {
    if (_messages.length > _maxMessages) {
      _messages = _messages.sublist(_messages.length - _maxMessages);
    }
  }
}
