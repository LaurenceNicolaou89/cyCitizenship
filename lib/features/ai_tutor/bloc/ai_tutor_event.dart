import 'package:equatable/equatable.dart';

sealed class AiTutorEvent extends Equatable {
  const AiTutorEvent();

  @override
  List<Object?> get props => [];
}

class SendMessage extends AiTutorEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class ClearConversation extends AiTutorEvent {
  const ClearConversation();
}
