import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String role;
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  @override
  List<Object?> get props => [role, content, timestamp];
}
