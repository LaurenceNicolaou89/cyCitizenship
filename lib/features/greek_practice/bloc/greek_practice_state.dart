import 'package:equatable/equatable.dart';

import '../../../core/models/chat_message.dart';

sealed class GreekPracticeState extends Equatable {
  const GreekPracticeState();

  @override
  List<Object?> get props => [];
}

class GreekPracticeInitial extends GreekPracticeState {
  final String level;

  const GreekPracticeInitial({this.level = 'B1'});

  @override
  List<Object?> get props => [level];
}

class GreekPracticeLoading extends GreekPracticeState {
  final List<ChatMessage> messages;
  final String level;

  const GreekPracticeLoading({
    required this.messages,
    required this.level,
  });

  @override
  List<Object?> get props => [messages, level];
}

class GreekPracticeLoaded extends GreekPracticeState {
  final List<ChatMessage> messages;
  final String level;
  final int messagesUsedToday;
  final int dailyLimit;

  const GreekPracticeLoaded({
    required this.messages,
    required this.level,
    required this.messagesUsedToday,
    required this.dailyLimit,
  });

  bool get limitReached => messagesUsedToday >= dailyLimit;

  @override
  List<Object?> get props => [messages, level, messagesUsedToday, dailyLimit];
}

class GreekPracticeError extends GreekPracticeState {
  final String message;
  final List<ChatMessage> previousMessages;
  final String level;

  const GreekPracticeError({
    required this.message,
    this.previousMessages = const [],
    this.level = 'B1',
  });

  @override
  List<Object?> get props => [message, previousMessages, level];
}
