import 'package:equatable/equatable.dart';

// Re-export ChatMessage from shared location for backward compatibility
export '../../../core/models/chat_message.dart';

import '../../../core/models/chat_message.dart';

class AiTutorChatMessage extends Equatable {
  final String role;
  final String content;
  final DateTime timestamp;

  const AiTutorChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  @override
  List<Object?> get props => [role, content, timestamp];
}

sealed class AiTutorState extends Equatable {
  const AiTutorState();

  @override
  List<Object?> get props => [];
}

class AiTutorInitial extends AiTutorState {
  const AiTutorInitial();
}

class AiTutorLoading extends AiTutorState {
  final List<AiTutorChatMessage> messages;

  const AiTutorLoading({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class AiTutorLoaded extends AiTutorState {
  final List<AiTutorChatMessage> messages;
  final int messagesUsedToday;
  final int dailyLimit;

  const AiTutorLoaded({
    required this.messages,
    required this.messagesUsedToday,
    required this.dailyLimit,
  });

  bool get limitReached => messagesUsedToday >= dailyLimit;

  @override
  List<Object?> get props => [messages, messagesUsedToday, dailyLimit];
}

class AiTutorError extends AiTutorState {
  final String message;
  final List<AiTutorChatMessage> previousMessages;

  const AiTutorError({
    required this.message,
    this.previousMessages = const [],
  });

  @override
  List<Object?> get props => [message, previousMessages];
}
