import 'package:equatable/equatable.dart';

sealed class GreekPracticeEvent extends Equatable {
  const GreekPracticeEvent();

  @override
  List<Object?> get props => [];
}

class SendGreekMessage extends GreekPracticeEvent {
  final String message;

  const SendGreekMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class SwitchLanguageLevel extends GreekPracticeEvent {
  final String level;

  const SwitchLanguageLevel(this.level);

  @override
  List<Object?> get props => [level];
}

class ResetGreekConversation extends GreekPracticeEvent {
  const ResetGreekConversation();
}
