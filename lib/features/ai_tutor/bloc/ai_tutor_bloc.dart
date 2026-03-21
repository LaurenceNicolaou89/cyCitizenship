import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/gemini_service.dart';
import 'ai_tutor_event.dart';
import 'ai_tutor_state.dart';

class AiTutorBloc extends Bloc<AiTutorEvent, AiTutorState> {
  final GeminiService _geminiService;
  final bool isPremium;

  List<AiTutorChatMessage> _messages = [];
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

    final userMessage = AiTutorChatMessage(
      role: 'user',
      content: event.message,
      timestamp: DateTime.now(),
    );
    _messages = [..._messages, userMessage];

    emit(AiTutorLoading(messages: List.unmodifiable(_messages)));

    try {
      // Build history from all messages except the last user message
      final history = _messages.length > 1
          ? _messages
              .sublist(0, _messages.length - 1)
              .where((m) => m.role == 'user' || m.role == 'assistant')
              .map((m) => ChatMessage(
                    role: m.role == 'user' ? 'user' : 'model',
                    content: m.content,
                  ))
              .toList()
          : <ChatMessage>[];

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

  Future<void> _onClearConversation(
    ClearConversation event,
    Emitter<AiTutorState> emit,
  ) async {
    _messages = [];
    emit(AiTutorLoaded(
      messages: const [],
      messagesUsedToday: _messagesUsedToday,
      dailyLimit: dailyLimit,
    ));
  }
}
