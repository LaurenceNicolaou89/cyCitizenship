import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/constants.dart';
import '../../../core/services/ai_rate_limit_service.dart';
import '../../../core/services/gemini_service.dart';
import 'ai_tutor_event.dart';
import 'ai_tutor_state.dart';

class AiTutorBloc extends Bloc<AiTutorEvent, AiTutorState> {
  static const _feature = 'ai_tutor';

  final GeminiService _geminiService;
  final AiRateLimitService _rateLimitService;
  final bool isPremium;

  /// Maximum messages retained in the UI list.
  static const int _maxMessages = 100;

  /// Sliding window size sent to the backend to limit token usage.
  static const int _geminiWindowSize = 50;

  List<AiTutorChatMessage> _messages = [];
  int _messagesUsedToday = 0;

  int get dailyLimit => isPremium
      ? AppConstants.paidAiMessagesPerDay
      : AppConstants.freeAiMessagesPerDay;

  AiTutorBloc({
    required GeminiService geminiService,
    required AiRateLimitService rateLimitService,
    this.isPremium = false,
  })  : _geminiService = geminiService,
        _rateLimitService = rateLimitService,
        super(const AiTutorInitial()) {
    on<LoadRateLimits>(_onLoadRateLimits);
    on<SendMessage>(_onSendMessage);
    on<ClearConversation>(_onClearConversation);
  }

  void _onLoadRateLimits(
    LoadRateLimits event,
    Emitter<AiTutorState> emit,
  ) {
    _messagesUsedToday = _rateLimitService.getUsageCount(_feature);
    emit(AiTutorLoaded(
      messages: List.unmodifiable(_messages),
      messagesUsedToday: _messagesUsedToday,
      dailyLimit: dailyLimit,
    ));
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<AiTutorState> emit,
  ) async {
    // Reload persisted count (handles midnight reset)
    _messagesUsedToday = _rateLimitService.getUsageCount(_feature);

    if (_messagesUsedToday >= dailyLimit) {
      emit(AiTutorLoaded(
        messages: List.unmodifiable(_messages),
        messagesUsedToday: _messagesUsedToday,
        dailyLimit: dailyLimit,
      ));
      return;
    }

    final userMessage = AiTutorChatMessage(
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
          : <AiTutorChatMessage>[];
      final windowStart = allExceptLast.length > _geminiWindowSize
          ? allExceptLast.length - _geminiWindowSize
          : 0;
      final history = allExceptLast
          .sublist(windowStart)
          .where((m) => m.role == 'user' || m.role == 'assistant')
          .map((m) => ChatMessage(
                role: m.role == 'user' ? 'user' : 'model',
                content: m.content,
              ))
          .toList();

      final response = await _geminiService.chatWithTutor(
        history,
        event.message,
      );

      final assistantMessage = AiTutorChatMessage(
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      );
      _messages = [..._messages, assistantMessage];
      _trimMessages();

      // Persist the incremented count
      _messagesUsedToday = _rateLimitService.incrementUsage(_feature);

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
