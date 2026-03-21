import 'package:equatable/equatable.dart';

sealed class AiPracticeEvent extends Equatable {
  const AiPracticeEvent();

  @override
  List<Object?> get props => [];
}

class GenerateQuestion extends AiPracticeEvent {
  const GenerateQuestion();
}

class SelectCategory extends AiPracticeEvent {
  final String category;

  const SelectCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class SelectAnswer extends AiPracticeEvent {
  final int index;

  const SelectAnswer(this.index);

  @override
  List<Object?> get props => [index];
}
